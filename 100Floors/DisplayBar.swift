//
//  DisplayBar.swift
//  100Floors
//
//  Created by Sid Mani on 1/5/16.
//
//

import UIKit

class DisplayBar: UIProgressView {
    
    let redVal:Float = 0.2
    let yellowVal:Float = 0.5
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.transform = CGAffineTransformMakeScale(1.0, 3.0)
        self.setProgress(0.5, animated: false)
    }
    
    func updateVal(newVal:Float)
    {
        self.setProgress(newVal, animated: false)
        if newVal <= redVal {
            self.progressTintColor = UIColor.redColor()
        }
        else if newVal <= yellowVal {
            self.progressTintColor = UIColor.yellowColor()
        }
        else {
            self.progressTintColor = UIColor.greenColor()
        }
    }
}