//
//  LevelContainer.swift
//  100Floors
//
//  Created by Sid Mani on 6/10/16.
//
//

import Foundation
//
//  ItemContainer.swift
//  100Floors
//
//  Created by Sid Mani on 1/13/16.
//
//
import UIKit
class LevelContainer:UICollectionViewCell {
    
    
    private let containerView:UIView = UIView()
    private let rectangleLayer = CAShapeLayer()
    
    private let levelView = UIImageView()
    var level:Int = -10
    private var centerPoint = CGPointZero
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        centerPoint =  CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
        let rectanglePath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.width), cornerRadius: 12)
        rectangleLayer.path = rectanglePath.CGPath
        setSelectedTo(false)
        rectangleLayer.lineWidth = 2.0
        containerView.layer.addSublayer(rectangleLayer)
        levelView.bounds = self.bounds
        levelView.userInteractionEnabled = false
        levelView.center = centerPoint
        levelView.contentMode = .ScaleAspectFit
        levelView.layer.magnificationFilter = kCAFilterNearest
        
        ////////////////////////////
        self.addSubview(containerView)
        self.addSubview(levelView)
    }
    
    
    func setSelectedTo(val:Bool) {
        if (val) {
            rectangleLayer.fillColor = ColorScheme.fillColorSelected.CGColor
            rectangleLayer.strokeColor = ColorScheme.strokeColorSelected.CGColor
        }
        else {
            rectangleLayer.fillColor = ColorScheme.fillColor.CGColor
            rectangleLayer.strokeColor = ColorScheme.strokeColor.CGColor
        }
    }
    
    func setLevelTo(l:Int) {
        level = l
        //TODO: somehow get level thumbnail from level name
        //then add it to the UIImageView
        
    }

    
}