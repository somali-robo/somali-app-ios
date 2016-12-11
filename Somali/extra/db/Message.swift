//
//  Message.swift
//  Somali
//
//  Created by 古川信行 on 2016/10/18.
//  Copyright © 2016年 ux-xu. All rights reserved.
//

import Foundation

enum MessageType: String {
    case TEXT = "text"
    case WAV = "wav"
    case ALERT = "alert"
}

class Message {
    var _id:String?
    var from:Member?
    var type:String?
    var value:String?
    var empath:[String:String]?
    var createdAt:String?
    
    required init(id:String, fields:NSDictionary?) {
        self._id = id
        self.update(fields: fields)
    }
    
    func update(fields:NSDictionary?) {
        if let from = fields?.value(forKey: "from") as? Member {
            self.from = from
        }
        
        if let type = fields?.value(forKey: "type") as? String {
            self.type = type
        }
        
        if let value = fields?.value(forKey: "value") as? String {
            self.value = value
        }
        
        if let empath = fields?.value(forKey: "empath") as? [String:String] {
            self.empath = empath
        }
        
        if let createdAt = fields?.value(forKey: "createdAt") as? String {
            self.createdAt = createdAt
        }
    }
}
