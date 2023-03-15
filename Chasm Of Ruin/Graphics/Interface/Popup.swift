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
    private unowned var parentObject:MapObject
    init(image:String, size:CGSize, parent:MapObject) {
        parentObject = parent
        super.init()

        let tile = SKShapeNode()
        tile.isAntialiased = false
        tile.path = CGPath(roundedRect: CGRect(x: self.position.x, y: self.position.y+size.height/2, width: size.width, height: size.height), cornerWidth: size.width/8, cornerHeight: size.height/8, transform: nil)
        tile.strokeColor = ColorScheme.strokeColor
        tile.fillColor = ColorScheme.fillColor
        tile.isUserInteractionEnabled = false
        addChild(tile)
        
        let imgNode = SKSpriteNode(imageNamed: image)
        imgNode.size = size
        imgNode.texture?.filteringMode = .nearest
        imgNode.position = CGPoint(x: tile.position.x + imgNode.size.width/2, y: tile.position.y + imgNode.size.height)
        imgNode.isUserInteractionEnabled = false
        imgNode.zPosition = 0
        addChild(imgNode)
        
        isUserInteractionEnabled = true
        zPosition = MapLevel.LayerDef.PopUps
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        (parentObject as! Interactive).trigger()
    }
    
}
