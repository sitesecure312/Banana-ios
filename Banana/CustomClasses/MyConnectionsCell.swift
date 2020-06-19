//
//  MyConnectionsCell.swift
//  Banana
//
//  Created by musharraf on 5/31/16.
//  Copyright © 2016 StarsDev. All rights reserved.
//

import UIKit

protocol MyConnectionsCellDelegate : class
{
    func viewProfileTappedOfCell(cell: MyConnectionsCell)
    //func viewConversationTappedOfCell(cell: MyConnectionsCell)
}

class MyConnectionsCell: UITableViewCell {

    var delegate: MyConnectionsVC?

    @IBOutlet weak var avatar_btn: UIButton!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var user_desc: UILabel!
    
    var section: Int = 0
    
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
    @IBAction func unsubscribePressed(sender: UIButton) {
        if let d = delegate
        {
            print("owner at index \(sender.tag) tapped")
            d.unsubscribePressed(self)
        }
    }
//    @IBAction func viewConversationTapped(sender: UIButton)
//    {
//        if let d = delegate
//        {
//            print("Conversation at index \(sender.tag) tapped")
//            d.viewConversationTappedOfCell(self)
//        }
//    }

}
