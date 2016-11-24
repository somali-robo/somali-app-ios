//
//  ChatRoom.swift
//  Somali
//
//  Created by 古川信行 on 2016/11/09.
//  Copyright © 2016年 ux-xu. All rights reserved.
//

import Foundation


class Chatroom {
    var id:String?
    var name:String?
    var members:[Member] = []
    var messages:[Message] = []
    var createdAt:String
    
    init(name:String, createdAt:String){
        self.name = name
        self.createdAt = createdAt
    }
    
    func setId(id:String) {
        self.id = id
    }
}
