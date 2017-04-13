//
//  ChatroomViewController.swift
//  Somali
//
//  Created by 古川信行 on 2016/11/08.
//  Copyright © 2016年 ux-xu. All rights reserved.
//

import Foundation
import UIKit

class ChatroomViewController:UIViewController, UITableViewDelegate, UITableViewDataSource{
    let somaliDB:SomaliDB = SomaliDB(apiHost: Config.API_HOST)
    
    var device:Member?
    
    var chatrooms:[Chatroom] = []
    var nextVc:ChatViewController?
    
    @IBOutlet weak var tableView: UITableView!
    
    //デバイス削除ボタン
    var btnDeviceDelete: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //デバイス削除ボタン
        btnDeviceDelete = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.trash, target: self, action: #selector(ChatroomViewController.clickBtnDeviceDelete))
        self.navigationItem.setRightBarButtonItems([btnDeviceDelete!], animated: true)
        
        tableView.delegate = self
        tableView.dataSource = self
        reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //チャットルーム一覧をロードする
    func reloadData(){
        somaliDB.getChatrooms(serialCode:(device?.serialCode)!) { (chatrooms, error) in
            print("chatrooms \(chatrooms)")
            if let e = error {
                print("error \(e)")
                return;
            }
            
            //一覧が取得できた
            self.chatrooms = chatrooms!
            print("chatrooms.count \(self.chatrooms.count)")
            
            //テーブルビューを更新
            self.tableView.reloadData()
        }
    }
    
    //選択したデバイスを設定
    func setDevice(device:Member){
        self.device = device
    }
    
    // セルの行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatrooms.count
    }
    
    // 行の表示
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ChatroomTableCell = tableView.dequeueReusableCell(withIdentifier: "ChatroomTableCell", for: indexPath) as! ChatroomTableCell
        
        //行にデータを表示させる
        cell.setCell(chatroom: chatrooms[indexPath.row])
        
        return cell
    }
    
    //画面移動
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueChat") {
            //チャットルーム画面へ遷移させる
            self.nextVc = (segue.destination as? ChatViewController)!
        }
    }
    
    // セルがタップされた時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath:IndexPath) {
        print("didSelectRowAt")
        //選択したデバイスを取得してチャットルーム画面に設定する
        self.nextVc?.setChatroom(chatroom: chatrooms[indexPath.row])
        self.nextVc?.fromId = "QkrZARioaGobLvNa8"
    }
    
    //デバイス削除処理
    func clickBtnDeviceDelete(){
        print("clickBtnDeviceDelete")
        let confirmAlert: UIAlertController = UIAlertController(title: "確認", message: "デバイスを初期化しますが、よろしいですか？", preferredStyle:  UIAlertControllerStyle.alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
            print("OK")
            //デバイス削除処理
            self.somaliDB.getChatrooms(serialCode:(self.device?.serialCode)!) { (chatrooms, error) in
                print("chatrooms \(chatrooms)")
                if let e = error {
                    print("error \(e)")
                    return;
                }
                for chatroom in chatrooms! {
                    self.somaliDB.deleteChatroom(roomId: chatroom._id!, callback: { (result, err) in
                        print("deleteChatroom \(result) \(err)")
                    })
                }
            }
            
            print("device \(self.device)")
            self.somaliDB.deleteDevice(device: self.device!, callback: { (result, err) in
                print("deleteDevice \(result) \(err)")
              
                //削除後にデバイスの電源を入れ直すアラートを表示
                let alert: UIAlertController = UIAlertController(title: "確認", message: "デバイスを初期化しました。電源を入れ直してください", preferredStyle:  UIAlertControllerStyle.alert)
                let btnOkAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
                    (action: UIAlertAction!) -> Void in
                    //一覧をリロード
                    self.reloadData()
                    
                    //TODO デバイス一覧に戻ってリロード
                })
                alert.addAction(btnOkAction)
                self.present(alert, animated: true, completion: nil)
            })
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler:{
            (action: UIAlertAction!) -> Void in
            print("Cancel")
        })
        confirmAlert.addAction(cancelAction)
        confirmAlert.addAction(defaultAction)
        
        present(confirmAlert, animated: true, completion: nil)
    }
    
}
