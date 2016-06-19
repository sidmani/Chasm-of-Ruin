//
//  Effects.swift
//  100Floors
//
//  Created by Sid Mani on 3/31/16.
//
//

import Foundation
import SpriteKit

class CountdownTimer:SKLabelNode {
    private var timeSinceUpdate:Double = 0
    private var currTime:Int
    private var timer:NSTimer?
    private let finalText:String
    init(time:Int, endText:String) {
        currTime = time
        finalText = endText
        super.init()
        verticalAlignmentMode = .Center
        fontName = "Optima"
        fontSize = 72
        fontColor = UIColor.redColor()
        text  = "\(currTime)"
        zPosition = 100
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(runTimer), userInfo: nil, repeats: true)
    }
    func runTimer() {
        if (currTime > 0) {
            self.text = "\(currTime)"
        }
        else if (currTime == 0) {
            self.text = finalText
        }
        else {
            //do some animation
            //callback
            timer?.invalidate()
            self.removeFromParent()
        }
        currTime -= 1
    }
}

class StatUpdatePopup:SKNode {
    
    init(color:SKColor, text:String, velocity:CGVector, zoomRate:CGFloat) {
        super.init()
        self.zPosition = BaseLevel.LayerDef.Effects
        let labelNode = SKLabelNode()
        labelNode.text = text
        labelNode.setScale(0.2)
        labelNode.fontColor = color
        labelNode.fontSize = 20
        labelNode.fontName = "AvenirNext-Heavy"
        self.addChild(labelNode)
        labelNode.runAction(SKAction.group([SKAction.moveBy(velocity, duration: 1), SKAction.scaleBy(zoomRate, duration: 1)]), completion: {[unowned self]  in self.removeFromParent()})
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
}