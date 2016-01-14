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
    var ringView:UIView
    var stickView:UIView
    let ring_size: CGFloat = 25
    let center_offset:CGFloat = 50
    
    // MARK: Properties
    var currentPoint = CGPoint(x:0, y:0)
    var angle: CGFloat {
        get {
           return atan2(currentPoint.y, currentPoint.x)
        }
    }
    var distance: CGFloat = 0
    var abs_distance: CGFloat {
        get{
            return min(distance, ring_size)
        }
    }
    
    
    // MARK: Initialization
    required init?(coder aDecoder: NSCoder) {
        let ringLayer = CAShapeLayer()
        let stickLayer = CAShapeLayer()
        ringView = UIView()
        stickView = UIView()

        super.init(coder: aDecoder)
        
        //set up paths
        let ringPath = UIBezierPath(arcCenter: CGPoint(x: center_offset,y: center_offset), radius: ring_size+15, startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        ringLayer.path = ringPath.CGPath
        ringLayer.fillColor = UIColor.clearColor().CGColor
        ringLayer.strokeColor = UIColor(colorLiteralRed: 0.80, green: 0.80, blue: 0.80, alpha: 0.65).CGColor
        ringLayer.lineWidth = 2.0
        
        let stickPath = UIBezierPath(arcCenter: CGPoint(x: center_offset,y: center_offset), radius: ring_size, startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
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
                let _angle = angle
                stickView.center = CGPoint(x: (ring_size * cos(_angle)), y:  (ring_size * sin(_angle))) //this can be optimized further
            }
        }
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
                let _angle = angle
                stickView.center = CGPoint(x: (ring_size * cos(_angle)), y:  (ring_size * sin(_angle)))
            }
            self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (touches.first != nil) {
            stickView.center = CGPoint(x: 0, y: 0)
            currentPoint = CGPoint(x:0, y:0)
            distance = 0
        }
    }
    
}
