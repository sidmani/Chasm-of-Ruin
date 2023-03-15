//
//  Effects.swift
//  100Floors
//
//  Created by Sid Mani on 3/31/16.
//
//

import Foundation
import SpriteKit

class CountdownTimer:SKNode {
    private var timeSinceUpdate:Double = 0
    private var currTime:Int
    private var timer:Timer?
    private let finalText:String
    private let completion:() -> ()
    private let node = SKLabelNode()
    init(time:Int, endText:String, completion: ()->()) {
        currTime = time
        finalText = endText
        self.completion = completion
        super.init()
        
        
        node.verticalAlignmentMode = .center
        node.fontName = "AvenirNext-Heavy"
        node.fontSize = 72
        node.fontColor = UIColor.red
        node.text  = "\(currTime)"
        node.zPosition = 100
        self.addChild(node)
        node.run(SKAction.group([SKAction.fadeAlpha(to: 0.2, duration: 1), SKAction.scale(by: 2, duration: 1)]))
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimer), userInfo: nil, repeats: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func runTimer() {
        if (node.scene != nil && node.scene!.isPaused == false) {
            currTime -= 1
            if (currTime > 0) {
                node.removeAllActions()
                node.setScale(1)
                node.alpha = 1
                node.text = "\(currTime)"
                node.run(SKAction.group([SKAction.fadeAlpha(to: 0.2, duration: 1), SKAction.scale(by: 2, duration: 1)]))
            }
            else if (currTime == 0) {
                node.removeAllActions()
                node.setScale(1)
                node.alpha = 1
                node.text = finalText
                node.run(SKAction.group([SKAction.fadeAlpha(to: 0.2, duration: 1), SKAction.scale(by: 2, duration: 1)]))
            }
            else {
                //do some animation
                completion()
                timer?.invalidate()
                self.removeFromParent()
            }
        }
    }
    
    func invalidate() {
        timer?.invalidate()
    }
}

class StatUpdatePopup:SKNode {
    
    init(color:SKColor, text:String, velocity:CGVector, zoomRate:CGFloat) {
        super.init()
        self.zPosition = MapLevel.LayerDef.Effects
        let labelNode = SKLabelNode()
        labelNode.text = text
        labelNode.setScale(0.2)
        labelNode.fontColor = color
        labelNode.fontSize = 20
        labelNode.fontName = "AvenirNext-Heavy"
        self.addChild(labelNode)
        labelNode.run(SKAction.group([SKAction.move(by: velocity, duration: 1), SKAction.scale(by: zoomRate, duration: 1)]), completion: {[unowned self]  in self.removeFromParent()})
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
}

class PixelEffect:SKSpriteNode {
    enum Alignment:Int {
        case bottom=0, center=1
    }
    
    private static let EffectDict:[String:(numFrames:Int, surround:Bool, alignment:Alignment)] = [
        "Block" : (11, false, .center),
        "BloodSplatterA" : (9, false, .center),
        "BloodSplatterB" : (9, false, .center),
        "BloodSplatterC" : (7, false, .center),
        "BloodSplatterD" : (7, false, .center),
        "Box" : (5, false, .center),
        "Bubble" : (14, false, .center),
        "Circle" : (9, false, .center),
        "Claw" : (16, false, .center),
        "ConsumeA" : (13, false, .bottom),
        "ConsumeB" : (13, false, .bottom),
        "ConsumeC" : (13, false, .bottom),
        "Dark" : (9, false, .bottom),
        "EarthA" : (8, false, .bottom),
        "EarthB" : (8, false, .bottom),
        "EarthC" : (8, false, .bottom),
        "Electric" : (6, false, .center),
        "ExplodeA" : (12, false, .center),
        "ExplodeB" : (12, false, .center),
        "ExplodeC" : (12, false, .center),
        "ExplodeD" : (12, false, .center),
        "ExplodeE" : (12, false, .center),
        "FireA" : (8, false, .bottom),
        "FireB" : (8, false, .bottom),
        "FireC" : (8, false, .bottom),
        "Flame" : (5, false, .center),
        "FlameAlt" : (5, false, .center),
        "Footprints" : (8, false, .center),
        "FootprintsSand" : (2, false, .center),
        "FootprintsSandNight" : (2, false, .center),
        "Glint" : (4, false, .center),
        "Heal0" : (11, true, .bottom),
        "Heal1" : (11, true, .bottom),
        "IceA" : (9, false, .bottom),
        "IceB" : (9, false, .bottom),
        "IceC" : (9, false, .bottom),
        "Lightning" : (4, false, .bottom),
        "NuclearA" : (6, false, .center),
        "NuclearB" : (6, false, .center),
        "NuclearC" : (8, false, .center),
        "NuclearD" : (8, false, .center),
        "Path" : (4, false, .center),
        "Poison" : (8, false, .bottom),
        "Puff" : (7, false, .center),
        "SelectA" : (3, false, .center),
        "SelectB" : (8, false, .center),
        "ShieldA" : (9, false, .center),
        "ShieldB" : (9, false, .center),
        "ShieldC" : (9, false, .center),
        "ShieldD" : (9, false, .center),
        "Sick" : (4, false, .center),
        "SlashA" : (7, false, .center),
        "SlashB" : (7, false, .center),
        "Sleep" : (6, false, .center),
        "SleepFlip" : (6, false, .center),
        "SlimeSplatterA" : (9, false, .center),
        "SlimeSplatterB" : (9, false, .center),
        "SlimeSplatterC" : (7, false, .center),
        "SlimeSplatterD" : (7, false, .center),
        "SparkA" : (10, false, .bottom),
        "SparkB" : (10, false, .bottom),
        "Square0" : (18, false, .bottom),
        "Square1" : (18, false, .bottom),
        "Star" : (9, false, .center),
        "TeleportA" : (7, false, .center),
        "TeleportB" : (12, false, .center),
        "TeleportC" : (9, false, .bottom),
        "TouchA" : (5, false, .center),
        "TouchB" : (5, false, .center),
        "WarpA" : (9, false, .bottom),
        "WarpB" : (9, false, .bottom),
        "Water" : (10, false, .bottom),
        "Web" : (12, true, .center)
    ]
    
    private var textureArray:[SKTexture] = []
    private let surround:Bool
    private let numFrames:Int
     let completion:() -> ()
    let alignment: Alignment
    
    init(baseFilename:String, numFrames:Int, surround:Bool = false, alignment: Alignment = .bottom, completion:()->() = {}) {
        self.surround = surround
        self.completion = completion
        self.numFrames = numFrames
        self.alignment = alignment
        if (!surround) {
            for i in 0..<numFrames {
                let newTexture = SKTextureAtlas(named: "\(baseFilename)").textureNamed("\(baseFilename)\(i)")
                newTexture.filteringMode = .nearest
                textureArray.append(newTexture)
            }
            super.init(texture: textureArray[0], color: UIColor.clear, size: textureArray[0].size())
        }
        else {
            for i in 0..<numFrames {
                let newTexture = SKTextureAtlas(named: "\(baseFilename)").textureNamed("\(baseFilename)Back\(i)")
                newTexture.filteringMode = .nearest
                textureArray.append(newTexture)
            }
            for i in 0..<numFrames {
                let newTexture = SKTextureAtlas(named: "\(baseFilename)").textureNamed("\(baseFilename)Fore\(i)")
                newTexture.filteringMode = .nearest
                textureArray.append(newTexture)
            }
            super.init(texture: nil, color: UIColor.clear, size: CGSize.zero)
        }
        self.isHidden = true
    }
    
    convenience init(name:String, completion:() -> () = {}) {
        let def = PixelEffect.EffectDict[name]!
        self.init(baseFilename:name, numFrames: def.numFrames, surround: def.surround, alignment: def.alignment, completion: completion)
    }
    
    func runAnimation() {
        self.isHidden = false
        if (!surround) {
            self.zPosition = 0.01
            run(SKAction.animate(with: textureArray, timePerFrame: 0.1), completion: {[unowned self] in
                self.completion()
                self.removeFromParent()})
        }
        else {
            let belowNode = SKSpriteNode(texture: textureArray[0], color: UIColor.clear, size: textureArray[0].size())
            let aboveNode = SKSpriteNode(texture: textureArray[numFrames], color: UIColor.clear, size: textureArray[numFrames].size())
            switch (alignment) {
            case .bottom:
                aboveNode.position.y = aboveNode.size.height/2
                belowNode.position.y = belowNode.size.height/2
            default: break
            }
            aboveNode.zPosition = 0.51
            belowNode.zPosition = -0.51
            self.addChild(aboveNode)
            self.addChild(belowNode)
            aboveNode.run(SKAction.animate(with: Array(textureArray[numFrames..<2*numFrames]), timePerFrame: 0.05))
            belowNode.run(SKAction.animate(with: Array(textureArray[0..<numFrames]), timePerFrame: 0.05), completion: {[unowned self] in
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
        path.move(to: CGPoint(x: -1, y: 0))
        path.addLine(to: CGPoint(x: 1,y: 0))
        path.addLine(to: CGPoint(x: 0, y: 3))
        shapeNode.fillColor = UIColor.red
        shapeNode.path = path.cgPath
        shapeNode.glowWidth = 1
        shapeNode.alpha = 0.7
        shapeNode.strokeColor = UIColor.clear
        shapeNode.position = CGPoint(x: 0, y: radius)
        shapeNode.isAntialiased = false
        self.addChild(shapeNode)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setRotation(_ to:CGFloat) {
        self.zRotation = to + CGFloat(M_PI_2)
    }
}
