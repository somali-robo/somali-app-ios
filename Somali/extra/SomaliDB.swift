//
//  SomaliDB.swift
//  Somali
//
//  Created by 古川信行 on 2016/10/18.
//  Copyright © 2016年 ux-xu. All rights reserved.
//

import Foundation
import Alamofire

class SomaliDB {
    //let API_BASE = "http://192.168.1.178:3000"
    let API_BASE = "http://192.168.11.64:3000"
    //let API_BASE = "https://somali-server.herokuapp.com"
    let API_SERVICE_INFOS:String = "/api/service_infos"
    let API_DEVICES:String = "/api/devices"
    let API_OWNERS:String = "/api/owners"
    let API_CHAT_ROOMS:String = "/api/chat_rooms"
    let API_MESSAGES:String = "/api/messages"
    
    
    //エラーをコールバックする
    private func callbackError(response:DataResponse<Any>, callback:@escaping (Any?,Error?)->Void){
        let statusCode = response.response?.statusCode
        let msg = response.result.value
        print("code:\(statusCode) \(msg)")
        let error:Error = NSError(domain: "com.ux-xu.Somali", code: statusCode!, userInfo: ["NSLocalizedDescriptionKey":msg])
        callback(nil,error)
    }
    
    /** メッセージ一覧を取得
 　　*/
    open func getMessages(_ callback:@escaping (Dictionary<String,AnyObject>?,Error?)->Void){
        Alamofire.request(API_MESSAGES)
            .responseJSON { response in
                if let JSON = response.result.value {
                    print("JSON \(JSON)")
                    callback(JSON as? Dictionary<String,AnyObject>,nil)
                }
                else{
                    print("Error withopennse")
                    self.callbackError(response:response,callback: callback as! (Any?, Error?) -> Void)
                }
        }
    }
    
    //ServiceInfo を取得する
    func getServiceInfo(callback:@escaping (ServiceInfo?,Error?)->Void){
        
        let url = "\(API_BASE)\(API_SERVICE_INFOS)"
        Alamofire.request(url, method: .get, parameters: nil)
            .responseJSON { response in
                let json = response.result.value as! NSDictionary
                
                if let data = json["data"] as? NSArray {
                    print(data)
                    let r = data[0] as! NSDictionary
                    
                    let name = r["name"] as! String
                    let socketPort = r["socketPort"] as! Int
                    let createdAt = r["createdAt"] as! String

                    let serviceInfo:ServiceInfo = ServiceInfo(name: name,socketPort: socketPort,createdAt: createdAt)
                    callback(serviceInfo,nil)
                }
                else{
                    print("Error with response")
                    self.callbackError(response:response,callback: callback as! (Any?, Error?) -> Void)
                }
        }
    }
    
    
    //デバイス一覧を取得
    func getDevices(callback:@escaping ([Device]?,Error?)->Void){
        
        let url = "\(API_BASE)\(API_DEVICES)"
        print("\(url)")
        Alamofire.request(url, method: .get, parameters: nil)
            .responseJSON { response in
                
                let json = response.result.value as! NSDictionary
                
                if let data = json["data"] as? NSArray {
                    print(data)
                    
                    var result:[Device] = []
                    for d in data {
                        if let d = d as? NSDictionary{
                            let id = d["_id"] as! String
                            let serialCode = d["serialCode"] as! String
                            let name = d["name"] as! String
                            let createdAt = d["createdAt"] as! String
                            
                            let device = Device(serialCode: serialCode,name: name,createdAt: createdAt)
                            device.setId(id: id)
                            result.append(device)
                        }
                    }
                    callback(result,nil)
                }
                else{
                    print("Error with response")
                    self.callbackError(response:response,callback: callback as! (Any?, Error?) -> Void)
                }
        }
    }
    
    
    //デバイス
    func getDevice(device:Device, callback:@escaping (Device?,Error?)->Void){
        let url = "\(API_BASE)\(API_DEVICES)/\(device.id!)"
        print("url \(url)")
        Alamofire.request(url, method: .get, parameters: nil)
            .responseJSON { response in
                let json = response.result.value as! NSDictionary
                
                if let d = json["data"] as? NSDictionary {
                    print(d)
                    
                    var result:Device? = nil
                    let id = d["_id"] as! String
                    let serialCode = d["serialCode"] as! String
                    let name = d["name"] as! String
                    let createdAt = d["createdAt"] as! String
                            
                    result = Device(serialCode: serialCode,name: name,createdAt: createdAt)
                    device.setId(id: id)
                    
                    callback(result,nil)
                }
                else{
                    print("Error with response")
                    self.callbackError(response:response,callback: callback as! (Any?, Error?) -> Void)
                }
        }
    }
    
    //デバイス追加
    func addDevice(device:Device, callback:@escaping (Device?,Error?)->Void){
        let url = "\(API_BASE)\(API_DEVICES)"
        print("\(url)")
        
        let parameters = ["serialCode":device.serialCode,
                          "name":device.name,
                          "createdAt":device.createdAt]
        print("\(parameters)")
        
        Alamofire.request(url, method: .post, parameters: parameters)
            .responseJSON { response in
                let json = response.result.value as! NSDictionary
                //print(json)
                
                if let d = json["data"] as? NSDictionary {
                    //print(d)
                    
                    let id = d["_id"] as! String
                    let serialCode = d["serialCode"] as! String
                    let name = d["name"] as! String
                    let createdAt = d["createdAt"] as! String
                        
                    let result = Device(serialCode: serialCode,name: name,createdAt: createdAt)
                    device.setId(id: id)
                    
                    callback(result,nil)
                }
                else{
                    print("Error with response")
                    self.callbackError(response:response,callback: callback as! (Any?, Error?) -> Void)
                }
        }
    }
    
    //オーナー
    func getOwner(owner:Owner, callback:@escaping (Owner?,Error?)->Void){
        let url = "\(API_BASE)\(API_OWNERS)/\(owner.id)"
        Alamofire.request(url, method: .get, parameters: nil)
            .responseJSON { response in
                let json = response.result.value as! NSDictionary
                
                if let data = json["data"] as? NSArray {
                    print(data)
                    
                    var result:Owner? = nil
                    if let d = data[0] as? NSDictionary{
                        let id = d["_id"] as! String
                        let name = d["name"] as! String
                        let createdAt = d["createdAt"] as! String
                        
                        result = Owner(id:id, name:name, createdAt:createdAt)
                    }
                    callback(result,nil)
                }
                else{
                    print("Error with response")
                    self.callbackError(response:response,callback: callback as! (Any?, Error?) -> Void)
                }
        }
    }
    
    //チャットルーム
    func getChatrooms(callback:@escaping ([Chatroom]?,Error?)->Void){
        let url = "\(API_BASE)\(API_CHAT_ROOMS)"
        print("\(url)")
        
        Alamofire.request(url, method: .get, parameters: nil)
            .responseJSON { response in
                let json = response.result.value as! NSDictionary
                print("json -----")
                print("\(json)")
                
                if let data = json["data"] as? NSArray {
                    print("data -----")
                    print(data)
                    
                    var result:[Chatroom] = []
                    for d in data {
                        if let d = d as? NSDictionary{
                            let id = d["_id"] as! String
                            let name = d["name"] as! String
                            let createdAt = d["createdAt"] as! String
                            
                            let obj = Chatroom(name: name,createdAt: createdAt)
                            obj.setId(id: id)
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
                    self.callbackError(response:response,callback: callback as! (Any?, Error?) -> Void)
                }
        }
    }
    
    //メンバーを設定する
    private func setMembers(obj: Chatroom, members:[NSDictionary]){
        print("members -----")
        print("\(members)")
        
        members.forEach({ (m) in
            let id = m["_id"] as! String
            let name = m["name"] as! String
            let createdAt = m["createdAt"] as! String
            var memberType:Member.MemberType = Member.MemberType.OWNER
            if let serialCode = m["serialCode"] {
                //Device
                memberType = Member.MemberType.DEVICE
            }
            
            let member = Member(name:name,createdAt:createdAt,memberType:memberType)
            member.id = id
            obj.members.append(member)
        });     
    }
    
    private func setMessages(obj:Chatroom, messages:[NSDictionary]){
        print("messages -----")
        print("\(messages)")
        
        messages.forEach({ (m) in
            
            let from = m["from"] as! NSDictionary
            print("from")
            print("\(from)")
            
            var member:Member?
            if let d = from["device"] {
                let device = d as! NSDictionary
                let name = device["name"] as! String
                let createdAt = device["createdAt"] as! String
                member = Member(name:name, createdAt:createdAt, memberType:Member.MemberType.DEVICE)
            }
            else if let o = from["owner"] {
                let owner = o as! NSDictionary
                let name = owner["name"] as! String
                let createdAt = owner["createdAt"] as! String
                member = Member(name:name,createdAt:createdAt,memberType:Member.MemberType.OWNER)
            }
            
            print("member")
            print("\(member)")
            if let f = member {
                let value = m["value"] as! String
                let createdAt = m["createdAt"] as! String
                let msg = Message(from:f, type:Message.MessageType.TEXT, value:value, createdAt:createdAt)
                print("append msg")
                print("\(msg)")
                
                obj.messages.append(msg)
            }
        })
    }
    
}
