//
//  PendingRequestCell.swift
//  Banana
//
//  Created by musharraf on 5/2/16.
//  Copyright © 2016 StarsDev. All rights reserved.
//

import UIKit

protocol PendingRequestCellDelegate : class
{
    func viewProfilePressedOfPendingRequestCell(cell: PendingRequestCell)
    func acceptPressedOfPendingRequestCell(cell: PendingRequestCell)
    func messagePressedOfPendingRequestCell(cell: PendingRequestCell)
    func rejectPressedOfPendingRequestCell(cell: PendingRequestCell)
}

class PendingRequestCell: UITableViewCell
{
    var delegate: PendingRequestCellDelegate?

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
    
    @IBAction func acceptPressed(sender: UIButton)
    {
        if let d = delegate
        {
            print("owner at index \(sender.tag) tapped")
            d.acceptPressedOfPendingRequestCell(self)
        }
    }
    
    @IBAction func messagePressed(sender: UIButton)
    {
        if let d = delegate
        {
            print("owner at index \(sender.tag) tapped")
            d.messagePressedOfPendingRequestCell(self)
        }
    }
    
    @IBAction func rejectPressed(sender: UIButton)
    {
        if let d = delegate
        {
            print("owner at index \(sender.tag) tapped")
            d.rejectPressedOfPendingRequestCell(self)
        }
    }
    
    @IBAction func viewProfileTapped(sender: UIButton)
    {
        if let d = delegate
        {
            d.viewProfilePressedOfPendingRequestCell(self)
        }
    }
}
