//
//  JoystickControl.swift
//  100Floors
//
//  Created by Sid Mani on 1/2/16.
//
//

import UIKit
import SpriteKit

class JoystickControl:UIControl{
    let ring_size: CGFloat = 25
    let center_offset:CGFloat = 50
    
    let ringView = UIView()
    let stickView = UIView()

    let ringLayer = CAShapeLayer()
    let stickLayer = CAShapeLayer()

    var currentPoint = CGPoint(x:0, y:0)
   /* var angle: CGFloat {
        return atan2(currentPoint.y, currentPoint.x)
    }*/
    var distance: CGFloat = 0
    var displacement:CGVector {
        if (distance == 0) {
            return CGVector(dx: 0, dy: 0)
        }
        return CGVectorMake(stickView.center.x/distance, -stickView.center.y/distance)
    }

    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        //set up paths
        let ringPath = UIBezierPath(arcCenter: CGPoint(x: center_offset,y: center_offset), radius: ring_size+15, startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        ringLayer.path = ringPath.CGPath
        ringLayer.fillColor = UIColor.clearColor().CGColor
        ringLayer.strokeColor = UIColor(colorLiteralRed: 0.80, green: 0.80, blue: 0.80, alpha: 0.65).CGColor
        ringLayer.lineWidth = 2.0
        
        let stickPath = UIBezierPath(arcCenter: CGPoint(x: center_offset,y: center_offset), radius: ring_size, startAngle: CGFloat(0), endAngle:CGFloat(M_PI) * 2, clockwise: true)
        stickLayer.path = stickPath.CGPath
        stickLayer.fillColor = UIColor(colorLiteralRed: 0.85, green: 0.85, blue: 0.85, alpha: 0.8).CGColor
        stickLayer.strokeColor = UIColor(colorLiteralRed: 0.85, green: 0.85, blue: 0.85, alpha: 0.8).CGColor
        stickLayer.lineWidth = 2.0
        //add layer to views
        ringView.layer.addSublayer(ringLayer)
        stickView.layer.addSublayer(stickLayer)
        //add views to main view
        self.addSubview(ringView)
        self.addSubview(stickView)
    }
    ///////////////
    ///////////////


    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            currentPoint = touch.locationInView(self)
            currentPoint = CGPoint(x: currentPoint.x - center_offset, y: currentPoint.y - center_offset)
            distance = hypot(currentPoint.x, currentPoint.y)
            if (distance < ring_size) {
                stickView.center = currentPoint
            }
            else
            {
                stickView.center = ring_size*CGPointMake(currentPoint.x/distance, currentPoint.y/distance)
                distance = ring_size
            }
        }
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            currentPoint = touch.locationInView(self)
            
            currentPoint = CGPoint(x: currentPoint.x - center_offset, y: currentPoint.y - center_offset)
            distance = hypot(currentPoint.x, currentPoint.y)
            if (distance < ring_size) {
                stickView.center = currentPoint
            }
            else
            {
                stickView.center = ring_size*CGPointMake(currentPoint.x/distance, currentPoint.y/distance)
                distance = ring_size
            }
        }
        super.touchesMoved(touches, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
            stickView.center = CGPoint(x: 0, y: 0)
            currentPoint = CGPoint(x:0, y:0)
            distance = 0
        super.touchesEnded(touches, withEvent: event)
    }
}
