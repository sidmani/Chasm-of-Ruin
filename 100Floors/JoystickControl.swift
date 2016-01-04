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
    
    let center_img_view = UIImageView(image: UIImage(named: "joystick_center"))
    let ring_img_view = UIImageView(image: UIImage(named: "joystick_ring"))
    let ring_size: Float = 25
    let center_pos: Float = 50
    // MARK: Properties
    var angle: Float = 0
    var distance: Float = 0
    var abs_distance: Float {
        get{
            return min(distance, ring_size)
        }
    }
    
    // MARK: Initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubview(center_img_view)
        addSubview(ring_img_view)
        
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
            distance = hypotf(Float(currentPoint.x - CGFloat(center_pos)), Float(currentPoint.y-CGFloat(center_pos)))
            angle = atan2(Float(currentPoint.y)-center_pos, Float(currentPoint.x)-center_pos)
            if (distance < ring_size) {
            center_img_view.center = currentPoint
            }
            else
            {
                let x:CGFloat = CGFloat(ring_size) * CGFloat(cos(angle))
                let y:CGFloat = CGFloat(ring_size) * CGFloat(sin(angle))
                center_img_view.center = CGPoint(x: x+CGFloat(center_pos), y:  y+CGFloat(center_pos))
            }
            self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.locationInView(self)
            center_img_view.center = CGPoint(x: CGFloat(center_pos), y: CGFloat(center_pos))
        }
    }
    
}
