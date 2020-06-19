//
//  AllActivitiesCell.swift
//  Banana
//
//  Created by musharraf on 4/19/16.
//  Copyright © 2016 StarsDev. All rights reserved.
//

import UIKit
protocol AllActivitiesCellDelegate : class
{
    func buttonTappedOfCell(cell: AllActivitiesCell)
    func deleteActivityPressed(cell: AllActivitiesCell)
}

class AllActivitiesCell: UITableViewCell
{
 
    var delegate: AllActivitiesCellDelegate?
    
    @IBOutlet weak var owner_btn: UIButton!
    @IBOutlet weak var activity_challenge: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var sport_type: UILabel!
    @IBOutlet weak var date_time: UILabel!
    @IBOutlet weak var activity_delete_btn: UIButton!
    
    var section: Int = 0
    var activity_id: String = "0"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func viewProfileTapped(sender: UIButton)
    {
        if let d = delegate
        {
            print("owner at index \(sender.tag) tapped")
            d.buttonTappedOfCell(self)
        }
    }
    @IBAction func deleteActivityPressed(sender: UIButton) {
        if let d = delegate
        {
            print("owner at index \(sender.tag) tapped")
            d.deleteActivityPressed(self)
        }
    }
}
