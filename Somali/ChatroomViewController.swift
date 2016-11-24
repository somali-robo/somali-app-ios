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
    let somaliDB:SomaliDB = SomaliDB()
    
    var device:Device?
    
    var chatrooms:[Chatroom] = []
    var nextVc:ChatViewController?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        somaliDB.getChatrooms { (chatrooms, error) in
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
    func setDevice(device:Device){
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
    
    
}
