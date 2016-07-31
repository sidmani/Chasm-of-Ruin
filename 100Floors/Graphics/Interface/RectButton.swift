//
//  RectButton.swift
//  100Floors
//
//  Created by Sid Mani on 6/10/16.
//
//

import Foundation
import UIKit
class RectButton:UIButton {
    private let rectangleLayer = CAShapeLayer()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        rectangleLayer.fillColor = ColorScheme.fillColor.CGColor
        rectangleLayer.masksToBounds = true

        self.layer.cornerRadius = 14
        self.layer.borderColor = ColorScheme.strokeColorSelected.CGColor
        self.layer.borderWidth = 2.0
        self.layer.addSublayer(rectangleLayer)
        
        self.addTarget(self, action: #selector(touchDown), forControlEvents: .TouchDown)
        self.addTarget(self, action: #selector(touchUp), forControlEvents: .TouchUpInside)
        self.addTarget(self, action: #selector(touchUp), forControlEvents: .TouchUpOutside)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = min(self.bounds.height/2, 14)
        let rectanglePath = UIBezierPath(rect: self.bounds)
        rectangleLayer.path = rectanglePath.CGPath

        rectangleLayer.cornerRadius = min(self.bounds.height/2 - 4, 10)
        rectangleLayer.bounds = CGRectMake(4, 4, self.bounds.width-8, self.bounds.height-8)
        rectangleLayer.position = CGPointMake(self.bounds.midX, self.bounds.midY)
    }
    
    @objc private func touchDown() {
        rectangleLayer.fillColor = ColorScheme.fillColorSelected.CGColor
    }
    
    @objc private func touchUp() {
        rectangleLayer.fillColor = ColorScheme.fillColor.CGColor
    }
    
}

class ProgressRectButton:RectButton {
    private let progressFillLayer = CAShapeLayer()
    var progress:CGFloat = 1
    var resetWithLayout = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if (resetWithLayout) {
            self.setProgress(1)
        }
        progressFillLayer.position.y = self.bounds.midY
        progressFillLayer.path = UIBezierPath(rect: self.bounds).CGPath
        progressFillLayer.bounds = self.bounds
        progressFillLayer.fillColor = UIColor.greenColor().CGColor
        rectangleLayer.mask = progressFillLayer
    }
    
    
    
    func setProgress(to: CGFloat, animated:Bool = false, withDuration:Double = 0.25) {
        progress = to
        if (animated) {
            CATransaction.setAnimationDuration(withDuration)
            CATransaction.begin()
            progressFillLayer.position.x = progress * self.bounds.width - self.bounds.midX
            CATransaction.commit()
        }
        else {
            progressFillLayer.position.x = progress * self.bounds.width - self.bounds.midX
        }
    }
    
    
    func setEnabledTo(to:Bool) {
        self.enabled = to
        if (to) {
            self.alpha = 1
        }
        else {
            self.alpha = 0.3
        }
    }
}