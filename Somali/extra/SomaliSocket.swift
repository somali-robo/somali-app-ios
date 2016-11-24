//
//  SomaliSocket.swift
//  Somali
//
//  Created by 古川信行 on 2016/10/30.
//  Copyright © 2016年 ux-xu. All rights reserved.
//

import Foundation
import SIOSocket

class SomaliSocket{
    var socket:SIOSocket! = nil
    
    //Socket.io
    let SOCKET_URL:String = "ws://192.168.11.64:8080"
    //let SOCKET_URL:String = "ws://192.168.1.178:8080"
    //let SOCKET_URL:String = "ws://somali-server.herokuapp.com:8080"
    
    var roomId:String?
    
    // 接続
    func connect(roomId:String, fromId:String, on:@escaping ([Any]?)->Void) {
        self.roomId = roomId
        
        // ここがソケット通信するところ
        SIOSocket.socket(withHost: SOCKET_URL) { (socket: SIOSocket?) in
            self.socket = socket
            
            self.socket.onConnect = {() in
                print("onConnect")
                
                //connectedを送信する
                self.sendConnected(fromId:fromId)
            }
            
            self.socket.onReconnect = { (attempts: Int) in
               print("onReconnect")
            }
            
            self.socket.onDisconnect = {() in
                print("onDisconnect")
            }
            
            // メッセージの初期化
            self.socket.on("connect", callback:{ (data:[Any]?) in
                print("connect")
                print(data)
            })
            
            // メッセージを受信
            self.socket.on("message", callback:{(data:[Any]?)  in
                //コールバック通知
                on(data)
            })
        }
    }
    
    //切断処理をする
    func disconnect(){
        socket.close();
    }
    
    private func sendConnected(fromId:String){
        let args:NSDictionary = ["roomId":self.roomId!,"fromId":fromId]
        send(event:"connected",args:args)
    }
    
    /** メッセージ送信
    */
    func sendMessage(fromId:String, message:Message) {
        let value = "{\"from\":\"\(fromId)\",\"type\":\"\(message.type)\",\"value\":\"\(message.value!)\",\"createdAt\":\"\(message.createdAt!)\"}";
        let args:NSDictionary = ["roomId":self.roomId!,"fromId":fromId,"value":value]
        send(event:"message",args:args)
    }
    
    /** メッセージ送信
    */
    private func send(event:String,args:NSDictionary) {
        self.socket.emit(event, args: [args])
    }
}
