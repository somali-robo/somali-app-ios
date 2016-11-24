//
//  ServiceInfo.swift
//  Somali
//
//  Created by 古川信行 on 2016/11/08.
//  Copyright © 2016年 ux-xu. All rights reserved.
//

import Foundation

class ServiceInfo {
    var name:String
    var socketPort:Int?
    var createdAt:String
    
    init(name:String,socketPort:Int,createdAt:String){
        self.name = name
        self.socketPort = socketPort
        self.createdAt = createdAt
    }
}
