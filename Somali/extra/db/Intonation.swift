//
//  Intonation.swift
//  Somali
//
//  Created by 古川信行 on 2016/11/11.
//  Copyright © 2016年 ux-xu. All rights reserved.
//

import Foundation

class Intonation {
    var id:String?
    var calm:String?
    var anger:String?
    var joy:String?
    var sorrow:String?
    var energy:String?
    var createdAt:String?
 
    init(calm:String,anger:String,joy:String,sorrow:String,energy:String, createdAt:String){
        self.calm = calm
        self.anger = anger
        self.joy = joy
        self.sorrow = sorrow
        self.energy = energy
        self.createdAt = createdAt
    }
    
    
    func setId(id:String) {
        self.id = id
    }
}
