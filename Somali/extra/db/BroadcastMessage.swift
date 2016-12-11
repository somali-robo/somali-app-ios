//
//  BroadcastMessage.swift
//  Somali
//
//  Created by 古川信行 on 2016/12/10.
//  Copyright © 2016年 ux-xu. All rights reserved.
//

import Foundation

class BroadcastMessage {
    var _id:String?
    var name:String?
    var value:String?
    var createdAt:String?
    
    required init(id:String, fields:NSDictionary?) {
        self._id = id
        self.update(fields: fields)
    }
    
    func update(fields:NSDictionary?) {
        if let name = fields?.value(forKey: "name") as? String {
            self.name = name
        }
        if let value = fields?.value(forKey: "value") as? String {
            self.value = value
        }
        if let createdAt = fields?.value(forKey: "createdAt") as? String {
            self.createdAt = createdAt
        }
    }
}
