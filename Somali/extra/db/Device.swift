//
//  Device.swift
//  Somali
//
//  Created by 古川信行 on 2016/11/08.
//  Copyright © 2016年 ux-xu. All rights reserved.
//

import Foundation

class Device : Member{
    var serialCode:String
    
    init(serialCode:String,name:String,createdAt:String){
        self.serialCode = serialCode
        super.init(name: name,createdAt: createdAt,memberType:MemberType.DEVICE)
    }
}
