//
//  Popup.swift
//  100Floors
//
//  Created by Sid Mani on 4/2/16.
//
//

import Foundation
import SpriteKit

class PopUp:SKNode {
    private var mainObject:Interactive
    init(image:String, size:CGSize, parent:Interactive) {
        mainObject = parent
        super.init()

        let tile = SKShapeNode()
        tile.antialiased = false
        tile.path = CGPathCreateWithRoundedRect(CGRectMake(self.position.x, self.position.y+size.height/2, size.width, size.height), size.width/8, size.height/8, nil)
        tile.strokeColor = UIColor(colorLiteralRed: 51, green: 51, blue: 51, alpha: 0.8)
        tile.fillColor = UIColor(colorLiteralRed: 102, green: 102, blue: 102, alpha: 0.8)
        tile.userInteractionEnabled = false
        addChild(tile)
        
        let imgNode = SKSpriteNode(imageNamed: image)
        imgNode.size = size
        imgNode.texture?.filteringMode = .Nearest
        imgNode.position = CGPointMake(tile.position.x + imgNode.size.width/2, tile.position.y + imgNode.size.height)
        imgNode.userInteractionEnabled = false
        addChild(imgNode)
        
        userInteractionEnabled = true
        zPosition = BaseLevel.LayerDef.PopUps
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        mainObject.trigger()
    }
    
}