//
//  JoystickControl.swift
//  100Floors
//
//  Created by Sid Mani on 1/2/16.
//
//

import UIKit
import SpriteKit

class JoystickControl:UIView{
    let center_img_view = UIImageView(image: UIImage(named: "joystick_center"))
    let ring_img_view = UIImageView(image: UIImage(named: "joystick_ring"))
    let ring_size: Float = 50
    // MARK: Initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubview(center_img_view)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.locationInView(self)
            //center_img_view.center = currentPoint
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.locationInView(self)
            let distance = hypotf(Float(currentPoint.x - 50), Float(currentPoint.y-50))
            print(distance)
            if (distance < ring_size) {
            center_img_view.center = currentPoint
            }
            else
            {
                let angle = atan2(currentPoint.y-50, currentPoint.x-50)
                let x:CGFloat = CGFloat(ring_size) * cos(angle)
                let y:CGFloat = CGFloat(ring_size) * sin(angle)
                center_img_view.center = CGPoint(x: x+CGFloat(ring_size), y:  y+CGFloat(ring_size))
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.locationInView(self)
            center_img_view.center = CGPoint(x: CGFloat(ring_size), y: CGFloat(ring_size))
        }
    }
    
}
