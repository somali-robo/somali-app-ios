//
//  ChatRoom.swift
//  Somali
//
//  Created by 古川信行 on 2016/11/09.
//  Copyright © 2016年 ux-xu. All rights reserved.
//

import Foundation

class Chatroom{
    var _id:String?    
    var name:String?
    var members:[Member] = []
    var messages:[Message] = []
    var createdAt:String?
    
    required init(id:String, fields:NSDictionary?) {
        self._id = id
        self.update(fields: fields)
    }
    
    func update(fields:NSDictionary?) {
        if let name = fields?.value(forKey: "name") as? String {
            self.name = name
        }
/*
        if let members = fields?.value(forKey: "members") as? [Device] {
            self.members = members
        }
        if let messages = fields?.value(forKey: "messages") as? [Message] {
            self.messages = messages
        }
 */
        if let createdAt = fields?.value(forKey: "createdAt") as? String {
            self.createdAt = createdAt
        }
    }
}
