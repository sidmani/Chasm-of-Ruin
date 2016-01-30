//
//  InGameScene.swift
//  100Floors
//
//  Created by Sid Mani on 1/2/16.
//
//
//TODO: restructure this class (update and didSimulatePhysics)


import SpriteKit
var nonSelfNodes:SKNode = SKNode()
var mapNodes:SKNode = SKNode()
var nonMapNodes:SKNode = SKNode()
//       var enemies = SKNode()
var selfNodes = SKNode()

class InGameScene: SKScene {
    var currFrame:Int = 0
    override func didMoveToView(view: SKView) {

        self.physicsWorld.gravity = CGVectorMake(0,0)
        currentMap = Map(mapName: "Map1") //load map
        mapNodes.addChild(currentMap!)
        mapNodes.zPosition = 0
        //  nonMapNodes.addChild(enemies)
        
        
        nonSelfNodes.addChild(mapNodes)
        nonSelfNodes.addChild(nonMapNodes)
        nonSelfNodes.physicsBody = SKPhysicsBody()
        nonSelfNodes.physicsBody!.affectedByGravity = false
        nonSelfNodes.physicsBody!.friction = 0
        
        //////////////////////////////////////////
        thisCharacter.absoluteLoc = CGPoint(x: 0, y: 0)
        selfNodes.addChild(thisCharacter)
        selfNodes.zPosition = 5
        //////////////////////////////////////////
        addChild(nonSelfNodes)
        addChild(selfNodes)
    }
    
    //override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    
    //}
    
    func setLevel(newLevel:Level)
    {
        //remove all nodes
        //display loading screen
        //load new nodes
        //end loading screen
        //addChild()
    }
    ////////
    override func update(currentTime: CFTimeInterval) {
        //cull unnecessary tiles
        let mapLoc = currentMap!.indexForPoint(nonSelfNodes.position)
        let newLoc = mapCenterLoc-mapLoc
        currentMap!.cullAroundIndexX(Int(newLoc.x), indexY: Int(newLoc.y), columnWidth: mapTilesWidth+4, rowHeight: mapTilesHeight+3)
        //////////////
        thisCharacter.updateProjectileState()
    }
    
    //////
    
    override func didSimulatePhysics() {
        updateNonSelfNodes()
        
    }
    
    //////

    func updateNonSelfNodes() {
        if (LeftJoystick!.valueChanged) {
            LeftJoystick!.valueChanged = false
            nonSelfNodes.physicsBody!.velocity = ~thisCharacter.velocity!
        }
            for i in nonMapNodes.children {
                if let spriteNode = i as? Projectile{
                    spriteNode.updateVelocity()
                    spriteNode.rangeCheck()
                }
                
            }
    
    }
    
    
}
