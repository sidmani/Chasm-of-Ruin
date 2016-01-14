//
//  ItemContainer.swift
//  100Floors
//
//  Created by Sid Mani on 1/13/16.
//
//

import UIKit

class ItemContainer:UIView {
    var containerView:UIView
    required init?(coder aDecoder: NSCoder) {
        containerView = UIView()
        let rectanglePath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 60, height: 60), cornerRadius: 8)
        let rectangleLayer = CAShapeLayer()
        rectangleLayer.path = rectanglePath.CGPath
        rectangleLayer.fillColor = UIColor(colorLiteralRed: 0.85, green: 0.85, blue: 0.85, alpha: 0.5).CGColor
        rectangleLayer.strokeColor = UIColor(colorLiteralRed: 0.85, green: 0.85, blue: 0.85, alpha: 0.8).CGColor
        rectangleLayer.lineWidth = 2.0
        containerView.layer.addSublayer(rectangleLayer)
        
        super.init(coder: aDecoder)
        self.addSubview(containerView)
        self.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
    }
}

class ItemContainerCircular:UIView {
    
}