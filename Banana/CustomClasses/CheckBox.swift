//
//  Checkbox.swift
//  Banana
//
//  Created by musharraf on 6/7/16.
//  Copyright © 2016 Stars Developer. All rights reserved.
//

import UIKit

class CheckBox: UIButton {
    // Images
    let uncheckedImage = UIImage(named: "checkbox_unchecked")! as UIImage
    let checkedImage = UIImage(named: "checkbox_checked")! as UIImage
    
    // Bool property
    var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                self.setImage(checkedImage, forState: .Normal)
            } else {
                self.setImage(uncheckedImage, forState: .Normal)
            }
        }
    }

    override func awakeFromNib() {
        self.addTarget(self, action: "buttonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        self.isChecked = false
    }

    func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
            
        }
    }
}