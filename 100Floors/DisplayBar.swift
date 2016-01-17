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
        self.updateVal(0.6)
    }
    
    func updateVal(newVal:Float)
    {
        self.setProgress(newVal, animated: false)
        if newVal <= redVal {
            self.progressTintColor = UIColor.redColor()
        }
        else if newVal < yellowVal {
            self.progressTintColor = UIColor(red: 255, green: CGFloat((newVal-0.2)/0.3), blue: 0, alpha: 1.0) //TODO: generalize
        }
        else {
            self.progressTintColor = UIColor(red: CGFloat(2-2*newVal), green: 255, blue: 0, alpha: 1.0)
        }
    }
}

class ReallyBigDisplayBar: DisplayBar {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.transform = CGAffineTransformMakeScale(2.5, 12.0)
        self.updateVal(0.6)
    }
}