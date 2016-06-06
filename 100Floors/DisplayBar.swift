//
//  DisplayBar.swift
//  100Floors
//
//  Created by Sid Mani on 1/5/16.
//
//

import UIKit

class ReallyBigDisplayBar: UIProgressView {
    private let redVal:CGFloat = 0.2
    private let yellowVal:CGFloat = 0.7

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.transform = CGAffineTransformMakeScale(1, 12.0)
        self.layer.borderColor = UIColor(colorLiteralRed: 0.85, green: 0.85, blue: 0.85, alpha: 0.8).CGColor
        self.layer.borderWidth = 0.1
    }
    
    func setProgressWithBounce(progress:CGFloat) {
        var color:UIColor
        if progress <= redVal {
            color = UIColor.redColor()
        }
        else if progress < yellowVal {
            color = UIColor(red: 255, green: (progress-0.2)/0.3, blue: 0, alpha: 1.0)
        }
        else {
            color = UIColor(red: CGFloat(2-2*progress), green: 255, blue: 0, alpha: 1.0)
        }
        UIView.animateWithDuration(0.3, animations: {()->Void in
            self.transform = CGAffineTransformMakeScale(1.5, 24)
            self.progressTintColor = color

        })

        self.setProgress(Float(progress), animated: true)
        UIView.animateWithDuration(0.3, animations: {()->Void in
            self.transform = CGAffineTransformMakeScale(1, 12)
        })
    }
}

class VerticalDisplayBar: UIProgressView {
    private let redVal:CGFloat = 0.2
    private let yellowVal:CGFloat = 0.7
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        self.layer.borderColor = UIColor(colorLiteralRed: 0.85, green: 0.85, blue: 0.85, alpha: 0.8).CGColor
        self.layer.borderWidth = 0.1
    }
    
    func setProgressWithBounce(progress:CGFloat) {
        var color:UIColor
        if progress <= redVal {
            color = UIColor.redColor()
        }
        else if progress < yellowVal {
            color = UIColor(red: 255, green: (progress-0.2)/0.3, blue: 0, alpha: 1.0)
        }
        else {
            color = UIColor(red: CGFloat(2-2*progress), green: 255, blue: 0, alpha: 1.0)
        }
        UIView.animateWithDuration(0.3, animations: {()->Void in
            self.transform = CGAffineTransformMakeScale(1.5, 24)
            self.progressTintColor = color
            
        })
        
        self.setProgress(Float(progress), animated: true)
        UIView.animateWithDuration(0.3, animations: {()->Void in
            self.transform = CGAffineTransformMakeScale(1, 12)
        })
    }
}