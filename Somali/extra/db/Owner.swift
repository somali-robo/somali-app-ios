//
//  Owner.swift
//  Somali
//
//  Created by 古川信行 on 2016/11/08.
//  Copyright © 2016年 ux-xu. All rights reserved.
//

import Foundation

class Owner : Member {
    var device:Device?
    
    init(id:String, name:String,createdAt:String){
        super.init(name: name,createdAt: createdAt,memberType:MemberType.OWNER)
        self.id = id
    }
    
    func setDevice(device:Device) {
        self.device = device
    }
}
