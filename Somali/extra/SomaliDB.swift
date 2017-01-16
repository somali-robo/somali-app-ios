//
//  SomaliDB.swift
//  Somali
//
//  Created by 古川信行 on 2016/10/18.
//  Copyright © 2016年 ux-xu. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class SomaliDB {
    var apiHost:String
    let API_SERVICE_INFOS:String = "/api/service_infos"
    let API_DEVICES:String = "/api/devices"
    let API_OWNERS:String = "/api/owners"
    let API_CHAT_ROOMS:String = "/api/chat_rooms"
    let API_MESSAGES:String = "/api/messages"
    let API_BROADCAST_MESSAGES = "/api/broadcast_messages"
    
    //コンストラクタ
    init(apiHost:String){
        self.apiHost = apiHost
    }
    
    //エラーをコールバックする
    private func createError(response:DataResponse<Any>) -> Error{
        var statusCode = response.response?.statusCode
        if statusCode == nil {
            statusCode = 0
        }
        let msg = response.result.value
        print("code:\(statusCode) \(msg)")
        return NSError(domain: "com.ux-xu.Somali", code: statusCode!, userInfo: ["NSLocalizedDescriptionKey":msg])
    }
    
    /** メッセージ一覧を取得
 　　*/
    open func getMessages(_ callback:@escaping (Dictionary<String,AnyObject>?,Error?)->Void){
        Alamofire.request(API_MESSAGES)
            .responseJSON { response in
                if response.result.isFailure {
                    //データ取得に失敗
                    callback(nil,self.createError(response:response))
                    return
                }
                
                if let JSON = response.result.value {
                    print("JSON \(JSON)")
                    callback(JSON as? Dictionary<String,AnyObject>,nil)
                }
                else{
                    print("Error withopennse")
                    callback(nil,self.createError(response:response))
                }
        }
    }
    

    //デバイス一覧を取得
    func getDevices(active:Bool,callback:@escaping ([Member]?,Error?)->Void){
        //devices/active/:active
        let url = "\(self.apiHost)\(API_DEVICES)/active/\(active)"
        print("\(url)")
        Alamofire.request(url, method: .get, parameters: nil)
            .responseJSON { response in
                if response.result.isFailure {
                    //データ取得に失敗
                    callback(nil,self.createError(response:response))
                    return
                }
                
                let json = response.result.value as! NSDictionary
                
                if let data = json["data"] as? NSArray {
                    print(data)
                    
                    var result:[Member] = []
                    for d in data {
                        if let d = d as? NSDictionary{
                            let id = d["_id"] as! String
                            let serialCode = d["serialCode"] as! String
                            let name = d["name"] as! String
                            let createdAt = d["createdAt"] as! String
                            
                            let device = Member(id: id,
                                                fields: ["serialCode": serialCode,
                                                         "name":name,
                                                         "createdAt":createdAt])
                            result.append(device)
                        }
                    }
                    callback(result,nil)
                }
                else{
                    print("Error with response")
                    callback(nil,self.createError(response:response))
                }
        }
    }
    
    
    //デバイス
    func getDevice(device:Member, callback:@escaping (Member?,Error?)->Void){
        let url = "\(self.apiHost)\(API_DEVICES)/\(device._id!)"
        print("url \(url)")
        Alamofire.request(url, method: .get, parameters: nil)
            .responseJSON { response in
                if response.result.isFailure {
                    //データ取得に失敗
                    callback(nil,self.createError(response:response))
                    return
                }
                
                let json = response.result.value as! NSDictionary
                
                if let d = json["data"] as? NSDictionary {
                    print(d)
                    
                    var result:Member? = nil
                    let id = d["_id"] as! String
                    let serialCode = d["serialCode"] as! String
                    let name = d["name"] as! String
                    let createdAt = d["createdAt"] as! String
                            
                    result = Member(id: id,fields: ["serialCode": serialCode,"name":name,"createdAt":createdAt])
                    
                    callback(result,nil)
                }
                else{
                    print("Error with response")
                    callback(nil,self.createError(response:response))
                }
        }
    }
    
    //デバイスをアクティブ化
    func activeDevice(device:Member, callback:@escaping (Member?,Error?)->Void){
        let url = "\(self.apiHost)\(API_DEVICES)/serial_code/\(device.serialCode!)"
        print("\(url)")
        let params = ["name":(device.name)!]
        
        Alamofire.request(url, method: .put, parameters: params)
            .responseJSON { response in
                if response.result.isFailure {
                    //データ取得に失敗
                    callback(nil,self.createError(response:response))
                    return
                }
                
                let json = response.result.value as! NSDictionary
                //print(json)
                
                if let d = json["data"] as? NSDictionary {
                    //print(d)
                    
                    let id = d["_id"] as! String
                    let serialCode = d["serialCode"] as! String
                    let name = d["name"] as! String
                    let createdAt = d["createdAt"] as! String
                        
                    let result = Member(id: id,fields: ["serialCode": serialCode,"name":name,"createdAt":createdAt])
                    
                    callback(result,nil)
                }
                else{
                    print("Error with response")
                    callback(nil,self.createError(response:response))
                }
        }
    }
    
    //オーナー
    func getOwner(owner:Member, callback:@escaping (Member?,Error?)->Void){
        let url = "\(self.apiHost)\(API_OWNERS)/\(owner._id)"
        Alamofire.request(url, method: .get, parameters: nil)
            .responseJSON { response in
                if response.result.isFailure {
                    //データ取得に失敗
                    callback(nil,self.createError(response:response))
                    return
                }
                
                let json = response.result.value as! NSDictionary
                
                if let data = json["data"] as? NSArray {
                    print(data)
                    
                    var result:Member? = nil
                    if let d = data[0] as? NSDictionary{
                        let id = d["_id"] as! String
                        let name = d["name"] as! String
                        let createdAt = d["createdAt"] as! String
                        
                        result = Member(id: id,fields: ["name":name,"createdAt":createdAt])
                    }
                    callback(result,nil)
                }
                else{
                    print("Error with response")
                    callback(nil,self.createError(response:response))
                }
        }
    }
    
    //チャットルーム
    func getChatroom(roomId:String, callback:@escaping (Chatroom?,Error?)->Void){
        let url = "\(self.apiHost)\(API_CHAT_ROOMS)/\(roomId)"
        print("\(url)")
        
        Alamofire.request(url, method: .get, parameters: nil)
            .responseJSON { response in
                if response.result.isFailure {
                    //データ取得に失敗
                    callback(nil,self.createError(response:response))
                    return
                }
                
                let json = response.result.value as! NSDictionary
                //print("json -----")
                //print("\(json)")
                
                if let data = json["data"] as? NSDictionary {
                    //print("data -----")
                    //print(data)
                    
                    let id = data["_id"] as! String
                    let name = data["name"] as! String
                    let createdAt = data["createdAt"] as! String
                            
                    let obj = Chatroom(id: id,fields: ["name":name,"createdAt":createdAt])
                            
                    // メンバー
                    let members = data["members"] as! [NSDictionary]
                    self.setMembers(obj: obj, members:members )
                            
                    // メッセージ
                    let messages = data["messages"] as! [NSDictionary]
                    self.setMessages(obj: obj, messages:messages )
                    
                    callback(obj,nil)
                }
                else{
                    print("Error with response")
                    callback(nil,self.createError(response:response))
                }
        }
    }
    
    //チャットルーム一覧
    func getChatrooms(serialCode:String,callback:@escaping ([Chatroom]?,Error?)->Void){
        ///api/chat_rooms/members/device/:serialCode
        let url = "\(self.apiHost)\(API_CHAT_ROOMS)/members/device/\(serialCode)"
        print("\(url)")
        
        Alamofire.request(url, method: .get, parameters: nil)
            .responseJSON { response in
                if response.result.isFailure {
                    //データ取得に失敗
                    callback(nil,self.createError(response:response))
                    return
                }
                
                let json = response.result.value as! NSDictionary
                //print("json -----")
                //print("\(json)")
                
                if let data = json["data"] as? NSArray {
                    //print("data -----")
                    //print(data)
                    
                    var result:[Chatroom] = []
                    for d in data {
                        if let d = d as? NSDictionary{
                            let id = d["_id"] as! String
                            let name = d["name"] as! String
                            let createdAt = d["createdAt"] as! String
                            
                            let obj = Chatroom(id: id,fields: ["name":name,"createdAt":createdAt])

                            // メンバー
                            let members = d["members"] as! [NSDictionary]
                            self.setMembers(obj: obj, members:members )
                            
                            // メッセージ
                            let messages = d["messages"] as! [NSDictionary]
                            self.setMessages(obj: obj, messages:messages )
                            
                            result.append(obj)
                        }
                    }
                    callback(result,nil)
                }
                else{
                    print("Error with response")
                    callback(nil,self.createError(response:response))
                }
        }
    }
    
    //メンバーを設定する
    private func setMembers(obj: Chatroom, members:[NSDictionary]){
        //print("setMembers -----")
        //print("\(members)")
        
        members.forEach({ (m) in
            //print("m \(m)")
            let id = m["_id"] as! String
            let name = m["name"] as! String
            let createdAt = m["createdAt"] as! String
            
            if m["serialCode"] != nil {
                //Device
                let member = Member(id: id,fields: ["name":name,"createdAt":createdAt,"memberType":MemberType.DEVICE.rawValue])
                obj.members.append(member)
            }
            else{
                //Owner
                let member = Member(id: id,fields: ["name":name,"createdAt":createdAt,"memberType":MemberType.OWNER.rawValue])
                obj.members.append(member)
            }
        });
    }
    
    private func setMessages(obj:Chatroom, messages:[NSDictionary]){
        print("setMessages -----")
        print("\(messages)")
        
        messages.forEach({ (m) in
            if m["from"] as? String == "" {
                return
            }
            
            let from = m["from"] as! NSDictionary

            if let i = m["_id"] {
                //print("i \(i)")
                //print("from \(from)")
                //print("value \(value)")
                
                let name = from["name"] as! String
                let createdAt = from["createdAt"] as! String
                let serialCode = from["serialCode"]
                
                var memberType:MemberType = MemberType.OWNER
                if let serialCode = serialCode{
                    if serialCode as! String != "nil" {
                        memberType = MemberType.DEVICE
                    }
                }
                
                let member = Member(id: UUID().uuidString,fields: ["name":name,"createdAt":createdAt,"memberType":memberType.rawValue])
                
                let msgId = m["_id"] as! String
                let msgValue = m["value"] as! String
                let msgType = m["type"] as! String
                let msgCreatedAt = m["createdAt"] as! String
                let msg = Message(id: msgId,fields: ["from":member,"value":msgValue,"createdAt":msgCreatedAt,"type":msgType])

                obj.messages.append(msg)
            }

        })
    }
    
    //ルームにメッセージを追加
    public func putChatroomMessage(roomId:String,message:Message){
        print("posttChatroomMessage")
        
        let url = "\(self.apiHost)\(API_CHAT_ROOMS)/\(roomId)/messages"
        print("\(url)")
        
        let params = ["message":["_id":message._id!,
                                 "from":(message.from?.toJSON())!,
                                 "type":message.type!,
                                 "value":message.value!,
                                 "createdAt":message.createdAt!]];
        print("params \(params)")
        Alamofire.request(url, method: .put, parameters: params)
            .responseJSON { response in
                //let json = response.result.value as! NSDictionary
                
        }
    }
    
    //ブロードキャスト一覧を取得
    func getBroadcastMessages(callback:@escaping ([BroadcastMessage]?,Error?)->Void){
        //broadcast_message
        let url = "\(self.apiHost)\(API_BROADCAST_MESSAGES)"
        print("\(url)")
        Alamofire.request(url, method: .get, parameters: nil)
            .responseJSON { response in
                if response.result.isFailure {
                    //データ取得に失敗
                    callback(nil,self.createError(response:response))
                    return
                }
                
                let json = response.result.value as! NSDictionary
                
                if let data = json["data"] as? NSArray {
                    //print(data)
                    
                    var result:[BroadcastMessage] = []
                    for d in data {
                        if let d = d as? NSDictionary{
                            let id = d["_id"] as! String
                            let name = d["name"] as! String
                            let value = d["value"] as! String
                            let createdAt = d["createdAt"] as! String
                            
                            let broadcastMessage = BroadcastMessage(id:id,fields:["name":name,"value": value,"createdAt":createdAt])
                            result.append(broadcastMessage)
                        }
                    }
                    callback(result,nil)
                }
                else{
                    print("Error with response")
                    callback(nil,self.createError(response:response))
                }
        }
    }
}
