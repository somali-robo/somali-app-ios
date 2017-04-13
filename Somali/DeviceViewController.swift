//
//  DeviceViewController.swift
//  Somali
//
//  Created by 古川信行 on 2016/11/08.
//  Copyright © 2016年 ux-xu. All rights reserved.
//

import Foundation
import UIKit

class DeviceViewController:UIViewController, UITableViewDelegate, UITableViewDataSource {
    let somaliDB:SomaliDB = SomaliDB(apiHost: Config.API_HOST)
    
    @IBOutlet weak var tableView: UITableView!
    
    //デバイス一覧
    var devices:[Member] = []
    
    var nextVc:ChatroomViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        //一覧をロード
        reloadData()
    }
    
    //デバイス一覧をロードする
    func reloadData(){
        somaliDB.getDevices(active: true) { (devices, error) in
            print("devices \(devices)")
            if let e = error {
                print("error \(e)")
                return;
            }
            
            //デバイス一覧が取得できた
            self.devices = devices!
            
            //テーブルビューを更新
            self.tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickBtnAdd(_ sender: AnyObject) {
        print("clickBtnAdd")
        
        //シリアルコード,デバイス名 入力画面を表示
        showAddDeviceDialog { (device) in
            if let d = device {
                
                print("d \(d)")
                //デバイスをアクテイブ化
                self.somaliDB.activeDevice(device: d) { (device, error) in
                    print("addDevice \(device)")
                    //テーブルを更新する
                    self.reloadData()
                }
                
            }
        }
    }
    
    //デバイス追加ダイアログ
    func showAddDeviceDialog(callback:@escaping (Member?)->Void) {
        var txtSerialCode: UITextField?
        var txtName: UITextField?
        
        let alertController:UIAlertController = UIAlertController(title:"デバイス追加",
                                                        message: "デバイスに記載のシリアルコードとニックネームを入力してください",
                                                        preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction:UIAlertAction = UIAlertAction(title: "Cancel",
                                                       style: UIAlertActionStyle.cancel,
                                                       handler:{
                                                        (action:UIAlertAction!) -> Void in
                                                        print("Cancel")
                                                        callback(nil)
        })
        
        let defaultAction:UIAlertAction = UIAlertAction(title: "OK",
                                                        style: UIAlertActionStyle.default,
                                                        handler:{
                                                            (action:UIAlertAction!) -> Void in
                                                            print("OK")
                                                            let serialCode = (txtSerialCode?.text)!
                                                            let name = (txtName?.text)!
                                                            
                                                            print("serialCode \(serialCode) name \(name)")
                                                            //TODO: 入力チェック
                                                            
                                                            let createdAt = DateUtils.stringFromDate(date: NSDate(), format: "yyyy-MM-ddTHH:mm:ssZ")
                                                            let device = Member(id: NSUUID().uuidString,
                                                                                fields: ["serialCode": serialCode,
                                                                                         "name":name,
                                                                                         "createdAt":createdAt,
                                                                                         "memberType":MemberType.DEVICE.rawValue])
                                                            
                                                            //コールバックする
                                                            callback(device)

        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(defaultAction)
        
        alertController.addTextField(configurationHandler: {(textField:UITextField!) -> Void in
            txtSerialCode = textField
            txtSerialCode?.placeholder = "シリアルコード"

        })
        
        alertController.addTextField(configurationHandler: {(textField:UITextField!) -> Void in
            txtName = textField
            txtName?.placeholder = "ニックネーム"
        })
        
        present(alertController, animated: true, completion: nil)
    }
    
    //UITableViewDelegate ---
    
    // セルの行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    // 行の表示
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:DeviceTableCell = tableView.dequeueReusableCell(withIdentifier: "DeviceTableCell", for: indexPath) as! DeviceTableCell
        //行にデータを表示させる
        cell.setCell(device: devices[indexPath.row])

        return cell
    }
    
    
    //画面移動
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare")
        if (segue.identifier == "segueChatroom") {
            //チャットルーム画面へ遷移させる
            self.nextVc = (segue.destination as? ChatroomViewController)!
            print("nextVc \(self.nextVc)")
        }
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        if !(parent?.isEqual(self.nextVc))! {
            print("Back button pressed")
            //一覧を更新
            self.reloadData()
        }
    }
    
    // セルがタップされた時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath:IndexPath) {
        print("didSelectRowAt")
        
        //選択したデバイスを取得してチャットルーム画面に設定する
        self.nextVc?.setDevice(device: self.devices[indexPath.row])
    }
}
