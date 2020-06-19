//
//  OwnerMsgCell.swift
//  Banana
//
//  Created by musharraf on 4/27/16.
//  Copyright © 2016 StarsDev. All rights reserved.
//

import UIKit

class OwnerMsgCell: UITableViewCell
{
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var msg: UILabel!
    @IBOutlet weak var date_time: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
