//
//  BgmTableCell.swift
//  Somali
//
//  Created by 古川信行 on 2017/02/08.
//  Copyright © 2017年 ux-xu. All rights reserved.
//

import Foundation
import UIKit

class BgmTableCell:UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    //@IBOutlet weak var createdAt: UILabel!
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
    
    func setCell(bgm :Bgm) {
        self.name.text = bgm.name
        //self.createdAt.text = bgm.createdAt
        //self.iconImage.image = UIImage(named:"play75")
    }
}
