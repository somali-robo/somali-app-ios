//
//  Message.swift
//  Somali
//
//  Created by 古川信行 on 2016/10/18.
//  Copyright © 2016年 ux-xu. All rights reserved.
//

import Foundation

class Message{
    var from:Member?
    var type:MessageType
    var value:String?
    var empath:[String:String]?
    var createdAt:String?
    
    enum MessageType: String {
        case TEXT
        case WAV
        
    }
    
    init(from:Member, type:MessageType, value:String, createdAt:String){
        self.from = from
        self.type = type
        self.value = value
        self.createdAt = createdAt
    }
}
