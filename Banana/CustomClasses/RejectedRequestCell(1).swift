//
//  RejectedRequestCell.swift
//  Banana
//
//  Created by musharraf on 5/2/16.
//  Copyright © 2016 StarsDev. All rights reserved.
//

import UIKit

protocol RejectedRequestCellDelegate : class
{
    func viewProfilePressedOfRejectedRequestCell(cell: RejectedRequestCell)
    func deletePressedOfRejectedRequestCell(cell: RejectedRequestCell)
}

class RejectedRequestCell: UITableViewCell
{
    var delegate: RejectedRequestCellDelegate?
    
    @IBOutlet weak var user_btn: UIButton!
    @IBOutlet weak var user_name: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var about_me: UILabel!

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
    
    @IBAction func deletePressed(sender: UIButton)
    {
        if let d = delegate
        {
            d.deletePressedOfRejectedRequestCell(self)
        }
    }
    
    @IBAction func viewProfileTapped(sender: UIButton)
    {
        if let d = delegate
        {
            d.viewProfilePressedOfRejectedRequestCell(self)
        }
    }

}
