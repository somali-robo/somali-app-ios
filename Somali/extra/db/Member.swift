//
//  Member.swift
//  Somali
//
//  Created by 古川信行 on 2016/11/09.
//  Copyright © 2016年 ux-xu. All rights reserved.
//

import Foundation

class Member {
    var id:String?
    var memberType:MemberType
    var name:String
    var createdAt:String
    
    enum MemberType {
        case OWNER
        case DEVICE
        
        func toString () -> String {
            switch self{
            case .DEVICE:
                return "device"
            default :
                return "owner"
            }
        }
    }
    
    init(name:String,createdAt:String,memberType:MemberType){
        self.name = name
        self.createdAt = createdAt
        self.memberType = memberType;
    }
    
    func setId(id:String) {
        self.id = id
    }
}
