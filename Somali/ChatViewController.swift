//
//  ChatViewController.swift
//  Somali
//
//  Created by 古川信行 on 2016/11/08.
//  Copyright © 2016年 ux-xu. All rights reserved.
//

import Foundation

import UIKit
import JSQMessagesViewController
import SwiftyJSON
import SwiftyDropbox
import NMPopUpViewSwift

class ChatViewController: JSQMessagesViewController {
    let somaliDB:SomaliDB = SomaliDB(apiProtocol: Config.API_PROTOCOL,apiHost: Config.API_HOST)

    //アラート ポップアップ
    var alertViewController : PopUpViewControllerSwift!
    
    var messages: [JSQMessage] = []
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    var incomingAvatar: JSQMessagesAvatarImage!
    var outgoingAvatar: JSQMessagesAvatarImage!

    var chatroom :Chatroom?
    var messageCnt = 0
    var broadcastMessageCnt = 0;
    
    var fromId:String?
    
    var owner:Member?
    
    var dropboxClient:DropboxClient = DropboxClient(accessToken: Config.DROPBOX_ACCESS_TOKEN)
    
    //表示済みのMessage ID一覧
    var dispMessageIds:[String] = []
    
    //表示済みの一斉送信メッセージID
    var dispBroadcastMessageIds:[String] = []
    
    var _view:UIView? = nil
    
    var timer:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")

        //画面タイトルを空にする
        self.title = ""
        
        self.senderId = MemberType.OWNER.rawValue
        self.senderDisplayName = "オーナー"
        
        //オーナーデータを作成
        let createdAt = DateUtils.stringFromDate(date: NSDate(), format: "yyyy-MM-ddTHH:mm:ssZ")
        owner = Member(id:self.fromId!,fields: ["name":senderDisplayName,"createdAt":createdAt])
        
        //TODO: チャットルームに オーナーを追加して更新
        self.chatroom?.members.append(owner!)
        
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        if let bubbleFactory = bubbleFactory{
            //吹き出しの色
            self.incomingBubble = bubbleFactory.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
            self.outgoingBubble = bubbleFactory.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
        }
        
        self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "device75")!, diameter: 64)
        self.outgoingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "icon75")!, diameter: 64)

        //ポーリングでチャットルームのメッセージを監視する
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: BlockOperation(block: {
            print("Timer event")
            //チャットルーム
            self.somaliDB.getChatroom(roomId:(self.chatroom?._id)!) { (chatroom, error) in
                if let e = error {
                    print("error \(e)")
                    return;
                }
                //print("chatroom \(chatroom)")
                if let room = chatroom {
                    //print(" messages.count \(room.messages.count)")
                    //print(" messageCnt \(self.messageCnt)")

                    //メッセージ件数に変更があるか確認
                    if(self.messageCnt < room.messages.count){
                        //メッセージ件数に変更があった場合差分を更新
                        self.setChatroom(chatroom: room)
                        self.messageCnt = room.messages.count
                    }
                }
            }
            
            //一斉送信メッセージ
            self.somaliDB.getBroadcastMessages(){ (messages, error) in
                if let e = error {
                    print("error \(e)")
                    return;
                }
                //メッセージ件数に変更があるか確認
                if(self.broadcastMessageCnt < (messages?.count)!){
                    self.setChatroom(broadcastMessage: messages!)
                    self.broadcastMessageCnt = (messages?.count)!
                }
            }
        }), selector: #selector(Operation.main), userInfo: nil, repeats: true)

        //初期化終了時に view を設定
        self._view = self.view;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        print("viewWillDisappear()")
        //Timer停止
        self.timer?.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //画面にチャット追加
    func addMessage(senderId:String,msg:Message){
        DispatchQueue.mainSyncSafe {
            let type:String = msg.type!
            let displayName:String = msg.from!.name!

            var message:JSQMessage?
            if type == MessageType.ALERT.rawValue {
                //アラート表示
                showAlert(title:"", message: msg.value!)
            }
            else if type == MessageType.TEXT.rawValue {
                //テキストの場合
                let text = msg.value!
                message = JSQMessage(senderId: senderId, displayName: displayName, text: text)
            }
            else if type == MessageType.WAV.rawValue {
                //WAVの場合 リンク再生 表示
                let wav = JSQAudioMediaItem()
                wav.appliesMediaViewMaskAsOutgoing = false
                message = JSQMessage(senderId: senderId, displayName: displayName, media:wav)
                    
                let fileName = (msg.value)!
                dropboxDownload(fileName:fileName,audioMediaItem:wav)
            }
            
            //print("message \(message)")
            if let msg = message{
                self.messages.append(msg)
                //チャット欄の表示更新
                self.finishReceivingMessage(animated:  true)
            }
        }
    }
    
    //一斉送信メッセージ
    func addMessage(senderId:String,msg:BroadcastMessage){
        let message = JSQMessage(senderId: senderId, displayName: msg.name, text: msg.value!)
        if let msg = message{
            self.messages.append(msg)
            //チャット欄の表示更新
            self.finishReceivingMessage(animated:  true)
        }
    }
    
    //DropboxからファイルをDownloadする
    func dropboxDownload(fileName:String,audioMediaItem:JSQAudioMediaItem){
        // ダウンロード先URLを設定
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destURL = directoryURL.appendingPathComponent(fileName)
        let destination: (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
            return destURL
        }
        
        self.dropboxClient.files.download(path: "/\(fileName)", overwrite: true, destination: destination)
            .response { response, error in
                if let (metadata, url) = response {
                    //ファイルダウンローが成功した
                    //print("metadata \(metadata)")
                    //print("url \(url)")
                    //WAVの場合 リンク 表示
                    audioMediaItem.setAudioDataWith(url)
                    //チャット欄の表示更新
                    self.finishReceivingMessage(animated:  true)
                }
                else if let error = error {
                    print(error)
                }
            }
            .progress { progressData in
                print(progressData)
        }
    }
    
    //チャットルームを設定
    func setChatroom(chatroom :Chatroom) {
        print("setChatroom.messages \(chatroom.messages)")
        
        self.chatroom = chatroom
        
        //メッセージの初期値として設定する
        self.messageCnt = chatroom.messages.count
        self.messages = []
        chatroom.messages.forEach({ (elem) in
            print("elem ----")
            
            let senderId:String = (elem.from?.memberType)!
            print("senderId \(senderId) value:\((elem.value)!)")
            print("elem._id \((elem._id)!)")
            
            //差分だけ画面に追加
            var searchArray = [String]()
            searchArray = dispMessageIds.filter{$0.localizedCaseInsensitiveContains("\((elem._id)!)")}
            if searchArray.count == 0 {
                addMessage(senderId:senderId,msg:elem)
                dispMessageIds.append("\(elem._id)")
            }
        })
    }
    
    //チャットルームを設定
    func setChatroom(broadcastMessage: [BroadcastMessage]) {
        print("setChatroom broadcastMessage:\(broadcastMessage)")
        
        broadcastMessage.forEach({ (elem) in
            //差分だけ画面に追加
            var searchArray = [String]()
            searchArray = dispBroadcastMessageIds.filter{$0.localizedCaseInsensitiveContains("\((elem._id)!)")}
            if searchArray.count == 0 {
                addMessage(senderId:MemberType.SYSTEM.rawValue,msg:elem)
                dispBroadcastMessageIds.append("\(elem._id)")
            }
        })

    }
    
    @IBAction func clickBtnBack(_ sender: AnyObject) {
        print("clickBtnBack")
        
        //前画面にもどる
        self.dismiss(animated: true, completion: nil)
    }
    
    //アクセサリーボタン
    override func didPressAccessoryButton(_ sender: UIButton!) {
        print("didPressAccessoryButton")
    }
    
    //Sendボタンが押された時に呼ばれる
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        print("didPressSend")
        
        let createdAt = DateUtils.stringFromDate(date: NSDate(), format: "yyyy-MM-ddTHH:mm:ssZ")
        let message = Message(id:NSUUID().uuidString,fields:["from": owner!,"type": MessageType.TEXT.rawValue,"value":text,"createdAt": createdAt])
        
        //感情認識APIのテスト
        //let message = Message(id:NSUUID().uuidString,fields:["from": owner!,"type": MessageType.WAV.rawValue,"value":"sample.wav","createdAt": createdAt])
        
        print("message \(message)")
        
        self.somaliDB.putChatroomMessage(roomId: (self.chatroom?._id!)!,message:message)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return self.messages[indexPath.item]
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = self.messages[indexPath.item]
        if message.senderId == self.senderId {
            return self.outgoingBubble
        }
        return self.incomingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = self.messages[indexPath.item]
        if message.senderId == self.senderId {
            return self.outgoingAvatar
        }
        return self.incomingAvatar
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.messages.count)
    }
    
    //アラートを表示
    func showAlert(title:String,message:String){
        if self._view == nil {
            //初期化が終わってない場合は画面にアラートは表示しない
            return
        }
        
        let bundle = Bundle.main
        if UIScreen.main.bounds.size.width > 320 {
            if UIScreen.main.scale == 3 {
                self.alertViewController = PopUpViewControllerSwift(nibName: "AlertViewController_iPhone6Plus", bundle: bundle)
            } else {
                self.alertViewController = PopUpViewControllerSwift(nibName: "AlertViewController_iPhone6", bundle: bundle)
            }
        } else {
            self.alertViewController = PopUpViewControllerSwift(nibName: "AlertViewController", bundle: bundle)
        }
        print("self.alertViewController \(self.alertViewController)")
        self.alertViewController.title = title
        self.alertViewController.showInView(self._view, withImage: UIImage(named: "alert512"), withMessage: message, animated: true)
    
        //アラート音を鳴らす
        CommonUtil.playAlarm(fileName: "alert01")
    }
}

