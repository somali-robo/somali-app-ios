//
//  BgmViewController.swift
//  Somali
//
//  Created by 古川信行 on 2017/02/08.
//  Copyright © 2017年 ux-xu. All rights reserved.
//

import Foundation
import UIKit

class BgmViewController:UIViewController, UITableViewDelegate, UITableViewDataSource{
    let somaliDB:SomaliDB = SomaliDB(apiHost: Config.API_HOST)
    @IBOutlet weak var tableView: UITableView!
    
    var roomId:String?
    var owner:Member?
    
    //BGM一覧
    var bgms:[Bgm] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //BGM一覧取得
        somaliDB.getBgms { (bgms, err) in
            if let e = err {
                print("err \(e)")
                return;
            }
            self.bgms = bgms!
            print("bgms \(bgms)")
            
            //テーブルビューを更新
            self.tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setOwner(owner:Member){
        self.owner = owner
    }
    
    func setRoomId(roomId:String) {
        self.roomId = roomId
    }
    
    // セルの行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bgms.count
    }
    
    // 行の表示
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:BgmTableCell = tableView.dequeueReusableCell(withIdentifier: "BgmTableCell", for: indexPath) as! BgmTableCell
        
        //行にデータを表示させる
        cell.setCell(bgm: (bgms[indexPath.row]))
        
        return cell
    }
    
    // セルがタップされた時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath:IndexPath) {
        print("didSelectRowAt")
        
        //再生アイコンを初期値に設定
        for cell in tableView.visibleCells {
            let c:BgmTableCell = cell as! BgmTableCell
            c.iconImage.image = UIImage(named:"play75")
        }
        
        //再生対象だけ再生マークにする
        let cell = tableView.cellForRow(at: indexPath)
        let c:BgmTableCell = cell as! BgmTableCell
        c.iconImage.image = UIImage(named:"play75-green")

        //BGM再生停止
        self.putChatroomMessageBgm(bgm:bgms[indexPath.row], isPlay: false)
        //3秒後に実行
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            //BGMを再生
            self.putChatroomMessageBgm(bgm:self.bgms[indexPath.row], isPlay: true)
        }
    }
    

    func putChatroomMessageBgm(bgm:Bgm?, isPlay:Bool){
        print("putChatroomMessageBgm")
        var message:Message?
        let createdAt = DateUtils.stringFromDate(date: NSDate(), format: "yyyy-MM-ddTHH:mm:ss")
        
        if isPlay == false {
            //停止
            message = Message(id:NSUUID().uuidString,fields:["from": owner!,"type": MessageType.BGM.rawValue,"value":"","createdAt": createdAt])
        }
        else if isPlay == true {
            //再生
            if let b = bgm {
                message = Message(id:NSUUID().uuidString,fields:["from": owner!,"type": MessageType.BGM.rawValue,"value":b.fileName!,"createdAt": createdAt])
            }
        }
        
        print("message \(message!)")
        self.somaliDB.putChatroomMessage(roomId: self.roomId!,message:message!)
    }
    
    @IBAction func clickBtnStop(_ sender: Any) {
        print("clickBtnStop")
        
        //再生アイコンを初期値に設定
        for cell in tableView.visibleCells {
            let c:BgmTableCell = cell as! BgmTableCell
            c.iconImage.image = UIImage(named:"play75")
        }
        
        //BGM 停止
        self.putChatroomMessageBgm(bgm:nil, isPlay: false)
    }
}
