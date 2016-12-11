//
//  Intonation.swift
//  Somali
//
//  Created by 古川信行 on 2016/11/11.
//  Copyright © 2016年 ux-xu. All rights reserved.
//

import Foundation

class Intonation{
    var _id:String?
    var calm:String?
    var anger:String?
    var joy:String?
    var sorrow:String?
    var energy:String?
    var createdAt:String?
    
    required init(id:String, fields:NSDictionary?) {
        self._id = id
        self.update(fields: fields)
    }
    
    func update(fields:NSDictionary?) {
        if let calm = fields?.value(forKey: "calm") as? String {
            self.calm = calm
        }
        if let anger = fields?.value(forKey: "anger") as? String {
            self.anger = anger
        }
        if let joy = fields?.value(forKey: "joy") as? String {
            self.joy = joy
        }
        if let sorrow = fields?.value(forKey: "sorrow") as? String {
            self.sorrow = sorrow
        }
        if let energy = fields?.value(forKey: "energy") as? String {
            self.energy = energy
        }
        if let createdAt = fields?.value(forKey: "createdAt") as? String {
            self.createdAt = createdAt
        }
    }
}
