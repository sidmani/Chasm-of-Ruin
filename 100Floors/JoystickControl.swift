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
    let progressView = UIView()
    let ringLayer = CAShapeLayer()
    let stickLayer = CAShapeLayer()
    let progressLayer = CAShapeLayer()

    var currentPoint = CGPoint(x:0, y:0)
    var angle: CGFloat = 0
    var distance: CGFloat = 0
    var displacement:CGVector {
        return CGVectorMake(stickView.center.x, -1*stickView.center.y)
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
        //setup progress view
        let progressPath = UIBezierPath(arcCenter: CGPoint(x:center_offset, y: center_offset), radius: ring_size+14, startAngle: CGFloat(0), endAngle: CGFloat(M_PI) * 2, clockwise: true)
        progressLayer.path = progressPath.CGPath
        progressLayer.fillColor = UIColor(colorLiteralRed: 0.85, green: 0, blue: 0, alpha: 0.7).CGColor
        //set up double tap gesture
        let tap = UITapGestureRecognizer(target: self, action: "doubleTapped")
        tap.numberOfTapsRequired = 2
        self.addGestureRecognizer(tap)
        let tap_single = UITapGestureRecognizer(target: self, action: "singleTapReset")
        tap_single.numberOfTapsRequired = 1
        self.addGestureRecognizer(tap_single)
        //add layer to views
        ringView.layer.addSublayer(ringLayer)
        stickView.layer.addSublayer(stickLayer)
        progressView.layer.addSublayer(progressLayer)
        
        //add views to main view
        self.addSubview(progressView)
        self.addSubview(ringView)
        self.addSubview(stickView)
    }
    ///////////////
    ///////////////
    ///////////////
    func singleTapReset() {
        stickView.center = CGPointMake(0, 0)
        currentPoint = CGPoint(x:0, y:0)
        distance = 0
    }
    
    func doubleTapped() {
        stickView.center = CGPointMake(0, 0)
        currentPoint = CGPoint(x:0, y:0)
        distance = 0
        GameLogic.doubleTapTrigger(self)

    }
    ///////////////
    ///////////////
    ///////////////
    func setProgress(toValue:CGFloat, withColorAdjust:CGFloat->CGColor) {
        progressLayer.strokeEnd = toValue * CGFloat(M_PI) * 2
        progressLayer.strokeColor = withColorAdjust(toValue)
    }
    ///////////////
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
                distance = ring_size
                angle = atan2(currentPoint.y, currentPoint.x)
                stickView.center = CGPoint(x: (ring_size * cos(angle)), y:  (ring_size * sin(angle))) //this can be optimized further
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
                distance = ring_size
                angle = atan2(currentPoint.y, currentPoint.x)
                stickView.center = CGPoint(x: (ring_size * cos(angle)), y:  (ring_size * sin(angle)))
            }
        }
        super.touchesMoved(touches, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
            stickView.center = CGPoint(x: 0, y: 0)
            currentPoint = CGPoint(x:0, y:0)
            distance = 0
            angle = 0
        super.touchesEnded(touches, withEvent: event)
    }
    
    
}
