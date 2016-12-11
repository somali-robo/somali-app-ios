//
//  Owner.swift
//  Somali
//
//  Created by 古川信行 on 2016/11/08.
//  Copyright © 2016年 ux-xu. All rights reserved.
//

import Foundation

enum MemberType:String {
    case OWNER = "owner"
    case DEVICE = "device"
    case SYSTEM = "system"
}

class Member{
    var _id:String?
    var serialCode:String?
    var name:String?
    var createdAt:String?
    var memberType:String?
    var device:Member?
    
    required init(id:String, fields:NSDictionary?) {
        self._id = id
        self.update(fields: fields)
    }
    
    func update(fields:NSDictionary?) {        
        if let serialCode = fields?.value(forKey: "serialCode") as? String {
            self.serialCode = serialCode
        }
        
        if let name = fields?.value(forKey: "name") as? String {
            self.name = name
        }
        
        if let memberType = fields?.value(forKey: "memberType") as? String {
            self.memberType = memberType
        }
        
        if let createdAt = fields?.value(forKey: "createdAt") as? String {
            self.createdAt = createdAt
        }
        
        if let device = fields?.value(forKey: "device") as? Member {
            self.device = device
        }
    }
    
    func toJSON() -> Dictionary<String, Any> {
        return [
            "serialCode":self.serialCode,
            "name":self.name!,
            "createdAt":self.createdAt!,
            "device":self.device?.toJSON()
        ]
    }
}

