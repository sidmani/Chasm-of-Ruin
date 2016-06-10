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
        let rectanglePath = UIBezierPath(roundedRect: CGRect(x: 2.5, y: 2.5, width: self.bounds.width-5, height: self.bounds.height-5), cornerRadius: 10)
        rectangleLayer.path = rectanglePath.CGPath
        rectangleLayer.fillColor = UIColor(colorLiteralRed: 0.85, green: 0.85, blue: 0.85, alpha: 0.8).CGColor

        let rectangleView = UIView()
        rectangleView.layer.addSublayer(rectangleLayer)
        rectangleView.center = CGPointZero
        
        let outerRectPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height), cornerRadius: 12)
        let outerRectLayer = CAShapeLayer()
        outerRectLayer.path = outerRectPath.CGPath
        outerRectLayer.strokeColor = UIColor(colorLiteralRed: 1, green: 0.98, blue: 0.45, alpha: 0.5).CGColor
        outerRectLayer.fillColor = UIColor(colorLiteralRed: 0.85, green: 0.85, blue: 0.85, alpha: 0).CGColor
        outerRectLayer.lineWidth = 2
        let outerRectView = UIView()
        outerRectView.layer.addSublayer(outerRectLayer)
        outerRectView.center = CGPointZero
        
        self.addSubview(rectangleView)
        self.addSubview(outerRectView)
        
        self.addTarget(self, action: #selector(touchDown), forControlEvents: .TouchDown)
        self.addTarget(self, action: #selector(touchUp), forControlEvents: .TouchUpInside)
        self.addTarget(self, action: #selector(touchUp), forControlEvents: .TouchUpOutside)

        
    }
    
    @objc private func touchDown() {
        rectangleLayer.fillColor = UIColor(colorLiteralRed: 1, green: 0.98, blue: 0.45, alpha: 0.5).CGColor
    }
    
    @objc private func touchUp() {
        rectangleLayer.fillColor = UIColor(colorLiteralRed: 0.85, green: 0.85, blue: 0.85, alpha: 0.8).CGColor

    }
    
    
}