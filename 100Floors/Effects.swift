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
    private var finalText:String
    init(time:Int, endText:String) {
        currTime = time
        finalText = endText
        super.init()
        verticalAlignmentMode = .Center
        fontName = "Optima"
        fontSize = 72
        fontColor = UIColor.redColor()
        self.text  = "\(currTime)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(runTimer), userInfo: nil, repeats: true)
    }
    func runTimer() {
            currTime -= 1
            if (currTime > 0) {
                self.text = "\(currTime)"
            }
            else if (currTime == 0) {
                self.text = finalText
            }
            else {
                //do some animation
                //callback
                GameLogic.timerCallback()
                timer?.invalidate()
                self.removeFromParent()
            }
    }
}