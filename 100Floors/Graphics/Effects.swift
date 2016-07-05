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
    
    private static let EffectDict:[String:(numFrames:Int, surround:Bool, alignment:Alignment)] = [
        "Block" : (11, false, .Center),
        "BloodSplatterA" : (9, false, .Center),
        "BloodSplatterB" : (9, false, .Center),
        "BloodSplatterC" : (7, false, .Center),
        "BloodSplatterD" : (7, false, .Center),
        "Box" : (5, false, .Center),
        "Bubble" : (14, false, .Center),
        "Circle" : (9, false, .Center),
        "Claw" : (16, false, .Center),
        "ConsumeA" : (13, false, .Bottom),
        "ConsumeB" : (13, false, .Bottom),
        "ConsumeC" : (13, false, .Bottom),
        "Dark" : (9, false, .Bottom),
        "EarthA" : (8, false, .Bottom),
        "EarthB" : (8, false, .Bottom),
        "EarthC" : (8, false, .Bottom),
        "Electric" : (6, false, .Center),
        "ExplodeA" : (12, false, .Center),
        "ExplodeB" : (12, false, .Center),
        "ExplodeC" : (12, false, .Center),
        "ExplodeD" : (12, false, .Center),
        "ExplodeE" : (12, false, .Center),
        "FireA" : (8, false, .Bottom),
        "FireB" : (8, false, .Bottom),
        "FireC" : (8, false, .Bottom),
        "Flame" : (5, false, .Center),
        "FlameAlt" : (5, false, .Center),
        "Footprints" : (8, false, .Center),
        "FootprintsSand" : (2, false, .Center),
        "FootprintsSandNight" : (2, false, .Center),
        "Glint" : (4, false, .Center),
        "Heal0" : (11, true, .Bottom),
        "Heal1" : (11, true, .Bottom),
        "IceA" : (9, false, .Bottom),
        "IceB" : (9, false, .Bottom),
        "IceC" : (9, false, .Bottom),
        "Lightning" : (4, false, .Bottom),
        "NuclearA" : (6, false, .Center),
        "NuclearB" : (6, false, .Center),
        "NuclearC" : (8, false, .Center),
        "NuclearD" : (8, false, .Center),
        "Path" : (4, false, .Center),
        "Poison" : (8, false, .Bottom),
        "Puff" : (7, false, .Center),
        "SelectA" : (3, false, .Center),
        "SelectB" : (8, false, .Center),
        "ShieldA" : (9, false, .Center),
        "ShieldB" : (9, false, .Center),
        "ShieldC" : (9, false, .Center),
        "ShieldD" : (9, false, .Center),
        "Sick" : (4, false, .Center),
        "SlashA" : (7, false, .Center),
        "SlashB" : (7, false, .Center),
        "Sleep" : (6, false, .Center),
        "SleepFlip" : (6, false, .Center),
        "SlimeSplatterA" : (9, false, .Center),
        "SlimeSplatterB" : (9, false, .Center),
        "SlimeSplatterC" : (7, false, .Center),
        "SlimeSplatterD" : (7, false, .Center),
        "SparkA" : (10, false, .Bottom),
        "SparkB" : (10, false, .Bottom),
        "Square0" : (18, false, .Bottom),
        "Square1" : (18, false, .Bottom),
        "Star" : (9, false, .Center),
        "TeleportA" : (7, false, .Center),
        "TeleportB" : (12, false, .Center),
        "TeleportC" : (9, false, .Bottom),
        "TouchA" : (5, false, .Center),
        "TouchB" : (5, false, .Center),
        "WarpA" : (9, false, .Bottom),
        "WarpB" : (9, false, .Bottom),
        "Water" : (10, false, .Bottom),
        "Web" : (12, true, .Center)
    ]
    
    private var textureArray:[SKTexture] = []
    private let surround:Bool
    private let numFrames:Int
     let completion:() -> ()
    let alignment: Alignment
    
    init(baseFilename:String, numFrames:Int, surround:Bool = false, alignment: Alignment = .Bottom, completion:()->() = {}) {
        self.surround = surround
        self.completion = completion
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
        self.init(baseFilename:name, numFrames: def.numFrames, surround: def.surround, alignment: def.alignment, completion: completion)
    }
    
    func runAnimation() {
        self.hidden = false
        if (!surround) {
            self.zPosition = 0.01
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

class IndicatorArrow:SKNode {
    private let shapeNode = SKShapeNode()
    init(color:UIColor, radius:CGFloat) {
        super.init()
        
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(-1, 0))
        path.addLineToPoint(CGPointMake(1,0))
        path.addLineToPoint(CGPointMake(0, 3))
        shapeNode.fillColor = UIColor.redColor()
        shapeNode.path = path.CGPath
        shapeNode.lineWidth = 0
        shapeNode.glowWidth = 1
        shapeNode.alpha = 0.7
        shapeNode.position = CGPointMake(0, radius)
        shapeNode.antialiased = false
        self.addChild(shapeNode)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setRotation(to:CGFloat) {
        self.zRotation = to + CGFloat(M_PI_2)
    }
}
