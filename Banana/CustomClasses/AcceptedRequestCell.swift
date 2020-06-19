//
//  AcceptedRequestCell.swift
//  Banana
//
//  Created by musharraf on 5/2/16.
//  Copyright © 2016 StarsDev. All rights reserved.
//

import UIKit

protocol AcceptedRequestCellDelegate : class
{
    func viewProfilePressedOfAcceptedRequestCell(cell: AcceptedRequestCell)
    func messagePressedOfAcceptedRequestCell(cell: AcceptedRequestCell)
    func cancelPressedOfAcceptedRequestCell(cell: AcceptedRequestCell)
}

class AcceptedRequestCell: UITableViewCell
{

    var delegate: AcceptedRequestCellDelegate?
    
    @IBOutlet weak var user_btn: UIButton!
    @IBOutlet weak var user_name: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var about_me: UILabel!
    
    var section: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func messagePressed(sender: UIButton)
    {
        if let d = delegate
        {
            d.messagePressedOfAcceptedRequestCell(self)
        }
    }
    
    @IBAction func cancelPressed(sender: UIButton)
    {
        if let d = delegate
        {
            d.cancelPressedOfAcceptedRequestCell(self)
        }
    }
    
    @IBAction func viewProfileTapped(sender: UIButton)
    {
        if let d = delegate
        {
            d.viewProfilePressedOfAcceptedRequestCell(self)
        }
    }
}
