//
//  Bgm.swift
//  Somali
//
//  Created by 古川信行 on 2017/02/01.
//  Copyright © 2017年 ux-xu. All rights reserved.
//

import Foundation

class Bgm {
    var _id:String?
    var name:String?
    var fileName:String?
    var createdAt:String?

    required init(id:String, fields:NSDictionary?) {
        self._id = id
        self.update(fields: fields)
    }
    
    func update(fields:NSDictionary?) {
        if let name = fields?.value(forKey: "name") as? String {
            self.name = name
        }
        
        if let fileName = fields?.value(forKey: "fileName") as? String {
            self.fileName = fileName
        }
        
        if let createdAt = fields?.value(forKey: "createdAt") as? String {
            self.createdAt = createdAt
        }
    }
}
