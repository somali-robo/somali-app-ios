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

class ChatViewController: JSQMessagesViewController {
    var messages: [JSQMessage] = []
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    var incomingAvatar: JSQMessagesAvatarImage!
    var outgoingAvatar: JSQMessagesAvatarImage!
    
    let somaliSocket:SomaliSocket = SomaliSocket()
    
    var chatroom :Chatroom?
    
    var fromId:String?
    
    var owner:Owner?
    
    var dropboxClient:DropboxClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
        //Dropboxへのアクセスの為 初期化
        self.dropboxClient = DropboxClient(accessToken: Config.DROPBOX_ACCESS_TOKEN)
        
        self.senderId = Member.MemberType.OWNER.toString()
        self.senderDisplayName = "オーナー"
        
        let roomId = self.chatroom?.id
        
        //オーナーデータを作成
        owner = Owner(id: self.fromId!,name: senderDisplayName,createdAt: "")
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
        
        //Socket.io 接続
        somaliSocket.connect(roomId:roomId!, fromId:self.fromId!,on:{ data in
            print("on \(data)")

            let dic = data?[0] as! NSDictionary
            //let roomId = dic["roomId"] as! String
            let fromId = dic["fromId"] as! String
            let value  = dic["value"] as! String
            
            var m:Member? = nil
            var senderId:String = self.senderId
            self.chatroom?.members.forEach({ (member) in
                print("member.id \(member.id)")
                if member.id == fromId {
                    m = member
                    if member.memberType == Member.MemberType.DEVICE {
                        senderId = Member.MemberType.DEVICE.toString()
                    }
                }
            });
            
            //受信したメーッセージを画面に追加する
            if let m = m {
                DispatchQueue.mainSyncSafe {
                    //ここで value を json に変換
                    if let dataFromString = value.data(using: .utf8, allowLossyConversion: false) {
                        let json = JSON(data: dataFromString)
                        print("json \(json)")
                        let type = json["type"].string
                        
                        var message:JSQMessage?
                        if type == Message.MessageType.TEXT.rawValue {
                            let text = json["value"].string
                            print("text \(text)")
                            message = JSQMessage(senderId: senderId, displayName: m.name, text: text)
                        }
                        else if(type == Message.MessageType.TEXT.rawValue){
                            //WAVの場合 リンク再生 表示
                            let path = json["value"].string
                            // ダウンロード先URLを設定
                            let pathComponent = "\(NSUUID().uuidString)-\(path)"
                            let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                            let destURL = directoryURL.appendingPathComponent(pathComponent)
                            let destination: (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
                                return destURL
                            }
                           
                            self.dropboxClient?.files.download(path: "/\(path)",destination: destination)
                                .response { response, error in
                                    if let (metadata, url) = response {
                                        //ファイルダウンローが成功した
                                        print("metadata \(metadata)")
                                        print("url \(url)")
                                        
                                        //WAVの場合 リンク 表示
                                        let wav = JSQAudioMediaItem()
                                        wav.setAudioDataWith(url)
                                        message = JSQMessage(senderId: senderId, displayName: m.name, media:wav)
                                        if let msg = message{
                                            self.messages.append(msg)
                                            self.finishReceivingMessage(animated:  true)
                                        }
                                    }
                                    else if let error = error {
                                        print(error)
                                    }
                                }
                                .progress { progressData in
                                    print(progressData)
                            }

                        }
                        print("message \(message)")
                        if let msg = message{
                            self.messages.append(msg)
                            self.finishReceivingMessage(animated:  true)
                        }
                        
                    }
                }
            }
        });
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear()")
        //Socket.io 切断
        somaliSocket.disconnect()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //チャットルームを設定
    func setChatroom(chatroom :Chatroom) {
        print("setChatroom.messages \(chatroom.messages)")
        
        self.chatroom = chatroom
        
        //メッセージの初期値として設定する
        self.messages = []
        chatroom.messages.forEach({ (elem) in
            print("elem")
            print("\(elem)")
            
            var senderId:String = "owner"
            if elem.from?.memberType != Member.MemberType.DEVICE {
                senderId = "device"
            }
            let message = JSQMessage(senderId: senderId, displayName: elem.from?.name, text: elem.value)
            self.messages.append(message!)
            
            self.finishReceivingMessage(animated:  true)
        })
    }
    
    @IBAction func clickBtnBack(_ sender: AnyObject) {
        print("clickBtnBack")
        
        //前画面にもどる
        self.dismiss(animated: true, completion: nil)
    }
    
    //Sendボタンが押された時に呼ばれる
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        //Socket.io サーバに送信
        let message = Message.init(from: owner!, type: .TEXT, value: text, createdAt: "2016-11-24T06:01:45.246Z")
        self.somaliSocket.sendMessage(fromId:self.fromId!, message:message)
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
}

