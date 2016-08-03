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
    private let ring_size: CGFloat = 25
    private let center_offset:CGFloat = 50
    
    private let ringView = UIView()
    private let stickView = UIView()

    private let ringLayer = CAShapeLayer()
    private let stickLayer = CAShapeLayer()

    var currentPoint = CGPoint.zero
   
    private var distance: CGFloat = 0
  
    var normalDisplacement:CGVector {
        if (distance == 0) {
            return CGVector(dx: 0, dy: 0)
        }
        return CGVector(dx: stickView.center.x/distance, dy: -stickView.center.y/distance)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        //set up paths
        let ringPath = UIBezierPath(arcCenter: CGPoint(x: center_offset,y: center_offset), radius: ring_size+15, startAngle: 0, endAngle:CGFloat(M_PI) * 2, clockwise: true)
        ringLayer.path = ringPath.cgPath
        ringLayer.fillColor = UIColor.clear.cgColor
        ringLayer.strokeColor = ColorScheme.strokeColor.cgColor
        ringLayer.lineWidth = 2.0
        
        let stickPath = UIBezierPath(arcCenter: CGPoint(x: center_offset,y: center_offset), radius: ring_size, startAngle: 0, endAngle:CGFloat(M_PI) * 2, clockwise: true)
        stickLayer.path = stickPath.cgPath
        stickLayer.fillColor = ColorScheme.fillColor.cgColor
        stickLayer.strokeColor = ColorScheme.strokeColor.cgColor
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


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            currentPoint = touch.location(in: self)
            currentPoint = CGPoint(x: currentPoint.x - center_offset, y: currentPoint.y - center_offset)
            distance = hypot(currentPoint.x, currentPoint.y)
            if (distance < ring_size) {
                stickView.center = currentPoint
            }
            else
            {
                stickView.center = CGPoint(x: ring_size*currentPoint.x/distance, y: ring_size*currentPoint.y/distance)
                distance = ring_size
            }
            ringLayer.strokeColor = ColorScheme.strokeColorSelected.cgColor
        }
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            currentPoint = touch.location(in: self)
            
            currentPoint = CGPoint(x: currentPoint.x - center_offset, y: currentPoint.y - center_offset)
            distance = hypot(currentPoint.x, currentPoint.y)
            if (distance < ring_size) {
                stickView.center = currentPoint
            }
            else
            {
                stickView.center = CGPoint(x: ring_size*currentPoint.x/distance, y: ring_size*currentPoint.y/distance)
                distance = ring_size
            }
        }
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetControl()
        super.touchesEnded(touches, with: event)
    }
    
    func resetControl() {
        stickView.center = CGPoint.zero
        currentPoint = CGPoint.zero
        distance = 0
        ringLayer.strokeColor = ColorScheme.strokeColor.cgColor
    }
    
    func getAngle() -> CGFloat {
        return atan2(stickView.center.y, stickView.center.x)
    }
}
