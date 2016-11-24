//
//  ChatroomTableCell.swift
//  Somali
//
//  Created by 古川信行 on 2016/11/09.
//  Copyright © 2016年 ux-xu. All rights reserved.
//

import Foundation
import UIKit

class ChatroomTableCell:UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var createdAt: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.isUserInteractionEnabled = false
    }
    
    /*
     override func setSelected(_ selected: Bool, animated: Bool) {
     super.setSelected(selected, animated: animated)
     }
     */
    
    func setCell(chatroom :Chatroom) {
        self.name.text = chatroom.name
        self.createdAt.text = chatroom.createdAt
        
        self.iconImage.image = UIImage(named:"chat75")
    }
}
