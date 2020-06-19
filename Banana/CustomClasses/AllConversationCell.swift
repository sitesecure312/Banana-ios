//
//  AllConversationCell.swift
//  Banana
//
//  Created by musharraf on 4/27/16.
//  Copyright © 2016 StarsDev. All rights reserved.
//

import UIKit

protocol AllConversationCellDelegate : class
{
    func viewProfileTappedOfCell(cell: AllConversationCell)
    func viewConversationTappedOfCell(cell: AllConversationCell)
}

class AllConversationCell: UITableViewCell
{
    var delegate: AllConversationCellDelegate?
    
    @IBOutlet weak var profile_btn: UIButton!
    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var activity_challenge: UILabel!
    @IBOutlet weak var date_time: UILabel!
    @IBOutlet weak var message: UILabel!
    
    @IBOutlet weak var conversation_btn: UIButton!
    
    var section: Int = 0
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func viewProfileTapped(sender: UIButton)
    {
        if let d = delegate
        {
            print("owner at index \(sender.tag) tapped")
            d.viewProfileTappedOfCell(self)
        }
    }
    
    @IBAction func viewConversationTapped(sender: UIButton)
    {
        if let d = delegate
        {
            print("Conversation at index \(sender.tag) tapped")
            d.viewConversationTappedOfCell(self)
        }
    }
    
}



