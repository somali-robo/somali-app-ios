//
//  DeviceTableCell.swift
//  Somali
//
//  Created by 古川信行 on 2016/11/09.
//  Copyright © 2016年 ux-xu. All rights reserved.
//

import Foundation
import UIKit

class DeviceTableCell:UITableViewCell {
    
    @IBOutlet weak var serialCode: UILabel!
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
    
    func setCell(device :Member) {
        self.serialCode.text = device.serialCode
        self.name.text = device.name
        self.createdAt.text = device.createdAt
        
        self.iconImage.image = UIImage(named:"device75")
    }
}
