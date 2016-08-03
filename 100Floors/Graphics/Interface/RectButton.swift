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
        rectangleLayer.fillColor = ColorScheme.fillColor.cgColor
        rectangleLayer.masksToBounds = true

        self.layer.cornerRadius = 14
        self.layer.borderColor = ColorScheme.strokeColorSelected.cgColor
        self.layer.borderWidth = 2.0
        self.layer.addSublayer(rectangleLayer)
        
        self.addTarget(self, action: #selector(touchDown), for: .touchDown)
        self.addTarget(self, action: #selector(touchUp), for: .touchUpInside)
        self.addTarget(self, action: #selector(touchUp), for: .touchUpOutside)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = min(self.bounds.height/2, 14)
        let rectanglePath = UIBezierPath(rect: self.bounds)
        rectangleLayer.path = rectanglePath.cgPath

        rectangleLayer.cornerRadius = min(self.bounds.height/2 - 4, 10)
        rectangleLayer.bounds = CGRect(x: 4, y: 4, width: self.bounds.width-8, height: self.bounds.height-8)
        rectangleLayer.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
    }
    
    @objc private func touchDown() {
        rectangleLayer.fillColor = ColorScheme.fillColorSelected.cgColor
    }
    
    @objc private func touchUp() {
        rectangleLayer.fillColor = ColorScheme.fillColor.cgColor
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
        progressFillLayer.path = UIBezierPath(rect: self.bounds).cgPath
        progressFillLayer.bounds = self.bounds
        progressFillLayer.fillColor = UIColor.green.cgColor
        rectangleLayer.mask = progressFillLayer
    }
    
    
    
    func setProgress(_ to: CGFloat, animated:Bool = false, withDuration:Double = 0.25) {
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
    
    
    func setEnabledTo(_ to:Bool) {
        self.isEnabled = to
        if (to) {
            self.alpha = 1
        }
        else {
            self.alpha = 0.3
        }
    }
}
