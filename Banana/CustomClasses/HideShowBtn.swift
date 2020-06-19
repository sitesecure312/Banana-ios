//
//  HideShowBtn.swift
//  Banana
//
//  Created by musharraf on 4/25/16.
//  Copyright © 2016 StarsDev. All rights reserved.
//

import UIKit

protocol HideShowBtnDelegate : class
{
    func buttonTapped(btn: HideShowBtn)
}

class HideShowBtn: UIButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    
    
    var delegate: HideShowBtnDelegate?
    var toggle = false
    var section: Int?
    
    override func drawRect(rect: CGRect)
    {
        // Drawing code
        self.addTarget(self, action: #selector(self.btnTapped(_:)), forControlEvents: .TouchUpInside)
    }
    
    @IBAction func btnTapped(sender: HideShowBtn)
    {
        if let d = delegate
        {
            d.buttonTapped(self)
        }
    }
    

}
