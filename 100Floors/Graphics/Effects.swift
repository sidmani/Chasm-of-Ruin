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

class PixelEffect:SKSpriteNode {
    enum Alignment:Int {
        case Bottom=0, Center=1
    }
    
    private static let EffectDict:[String:(numFrames:Int, surround:Bool, onTop:Bool, alignment:Alignment)] = [
        "Block" : (11, false, true, .Center),
        "BloodSplatterA" : (9, false, true, .Center),
        "BloodSplatterB" : (9, false, true, .Center),
        "BloodSplatterC" : (7, false, true, .Center),
        "BloodSplatterD" : (7, false, true, .Center),
        "Heal1" : (11, true, false, .Bottom),
        "WarpB" : (9, false, true, .Bottom),
        "EarthC" : (8, false, true, .Bottom)
    ]
    
    private var textureArray:[SKTexture] = []
    private let surround:Bool
    private let numFrames:Int
    private let onTop:Bool
     let completion:() -> ()
    let alignment: Alignment
    
    init(baseFilename:String, numFrames:Int, surround:Bool = false, onTop:Bool = false, alignment: Alignment = .Bottom, completion:()->() = {}) {
        self.surround = surround
        self.completion = completion
        self.onTop = onTop
        self.numFrames = numFrames
        self.alignment = alignment
        if (!surround) {
            for i in 0..<numFrames {
                let newTexture = SKTextureAtlas(named: "\(baseFilename)").textureNamed("\(baseFilename)\(i)")
                newTexture.filteringMode = .Nearest
                textureArray.append(newTexture)
            }
            super.init(texture: textureArray[0], color: UIColor.clearColor(), size: textureArray[0].size())
        }
        else {
            for i in 0..<numFrames {
                let newTexture = SKTextureAtlas(named: "\(baseFilename)").textureNamed("\(baseFilename)Back\(i)")
                newTexture.filteringMode = .Nearest
                textureArray.append(newTexture)
            }
            for i in 0..<numFrames {
                let newTexture = SKTextureAtlas(named: "\(baseFilename)").textureNamed("\(baseFilename)Fore\(i)")
                newTexture.filteringMode = .Nearest
                textureArray.append(newTexture)
            }
            super.init(texture: nil, color: UIColor.clearColor(), size: CGSizeZero)
        }
        self.hidden = true
    }
    
    convenience init(name:String, completion:() -> () = {}) {
        let def = PixelEffect.EffectDict[name]!
        self.init(baseFilename:name, numFrames: def.numFrames, surround: def.surround, onTop: def.onTop, alignment: def.alignment, completion: completion)
    }
    
    func runAnimation() {
        self.hidden = false
        if (!surround) {
            self.zPosition = (onTop ? 0.01 : -0.01)
            runAction(SKAction.animateWithTextures(textureArray, timePerFrame: 0.05), completion: {[unowned self] in
                self.completion()
                self.removeFromParent()})
        }
        else {
            let belowNode = SKSpriteNode(texture: textureArray[0], color: UIColor.clearColor(), size: textureArray[0].size())
            let aboveNode = SKSpriteNode(texture: textureArray[numFrames], color: UIColor.clearColor(), size: textureArray[numFrames].size())
            switch (alignment) {
            case .Bottom:
                aboveNode.position.y = aboveNode.size.height/2
                belowNode.position.y = belowNode.size.height/2
            default: break
            }
            aboveNode.zPosition = 0.51
            belowNode.zPosition = -0.51
            self.addChild(aboveNode)
            self.addChild(belowNode)
            aboveNode.runAction(SKAction.animateWithTextures(Array(textureArray[numFrames..<2*numFrames]), timePerFrame: 0.05))
            belowNode.runAction(SKAction.animateWithTextures(Array(textureArray[0..<numFrames]), timePerFrame: 0.05), completion: {[unowned self] in
                self.completion()
                self.removeFromParent()})
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
}

//class IndicatorArrow:SKShapeNode, Updatable {
//    private var direction:CGVector
//    private let center:CGPoint
//    init(color:UIColor, radius:CGFloat, center:CGPoint) {
//        super.init
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func update(deltaT: Double) {
//        
//    }
//}
