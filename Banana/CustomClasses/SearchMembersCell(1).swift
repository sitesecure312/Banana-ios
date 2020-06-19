//
//  SearchMembersCell.swift
//  Banana
//
//  Created by musharraf on 6/1/16.
//  Copyright © 2016 StarsDev. All rights reserved.
//

import UIKit

class SearchMembersCell: UITableViewCell {

    var delegate: SearchMembersVC?
    @IBOutlet weak var avatar_btn: UIButton!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var user_desc: UILabel!
    @IBOutlet weak var connect_btn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func viewProfileTapped(sender: UIButton) {
        if let d = delegate
        {
            print("owner at index \(sender.tag) tapped")
            d.viewProfileTappedOfCell(self)
        }
    }
    @IBAction func connectTapped(sender: UIButton) {
        if let d = delegate
        {
            print("owner at index \(sender.tag) tapped")
            d.connectTapped(self)
        }
    }
}
