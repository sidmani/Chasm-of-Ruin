//
//  InGameScene.swift
//  100Floors
//
//  Created by Sid Mani on 1/2/16.
//
//


import SpriteKit

class InGameScene: SKScene, SKPhysicsContactDelegate {
    private var currentLevel:Level?
    private var oldLoc:CGPoint = CGPointZero
    var mainCamera = SKCameraNode()
    var nonCharNodes = SKNode()
       // var projectiles = SKNode()
       // var enemies = SKNode()
    override func didMoveToView(view: SKView) {
        self.physicsWorld.gravity = CGVectorMake(0,0)
        self.physicsWorld.contactDelegate = self
        self.camera = mainCamera
        self.camera!.position = thisCharacter.position
        self.camera!.xScale = 0.3
        self.camera!.yScale = 0.3
        GameLogic.setGameState(.InGame)
        GameLogic.setup(self)
        nonCharNodes.physicsBody = SKPhysicsBody()
        nonCharNodes.physicsBody!.affectedByGravity = false
        nonCharNodes.physicsBody!.friction = 0
        
        //////////////////////////////////////////
        //////////////////////////////////////////
        addChild(nonCharNodes)
        addChild(thisCharacter)
    }

    func didBeginContact(contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == PhysicsCategory.Interactive && contact.bodyB.categoryBitMask == PhysicsCategory.ThisPlayer) {
            GameLogic.withinInteractDistance(contact.bodyA.node as! Interactive)
            return
        }
        else if (contact.bodyB.categoryBitMask == PhysicsCategory.Interactive && contact.bodyA.categoryBitMask == PhysicsCategory.ThisPlayer) {
            GameLogic.withinInteractDistance(contact.bodyB.node as! Interactive)
            return
        }
        else if ((contact.bodyA.categoryBitMask == PhysicsCategory.ThisPlayer && contact.bodyB.categoryBitMask == PhysicsCategory.EnemyProjectile)) {
            thisCharacter.struckByProjectile(contact.bodyB.node! as! Projectile)
            return
        }
        else if (contact.bodyB.categoryBitMask == PhysicsCategory.ThisPlayer && contact.bodyA.categoryBitMask == PhysicsCategory.EnemyProjectile) {
            thisCharacter.struckByProjectile(contact.bodyA.node! as! Projectile)
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == PhysicsCategory.Interactive && contact.bodyB.categoryBitMask == PhysicsCategory.ThisPlayer || contact.bodyB.categoryBitMask == PhysicsCategory.Interactive && contact.bodyA.categoryBitMask == PhysicsCategory.ThisPlayer) {
            GameLogic.exitedInteractDistance()
            return
        }
    }
    
    override func didFinishUpdate() {
        oldLoc = camera!.position
        camera!.position = CGPointMake(floor(thisCharacter.position.x*6)/6, floor(thisCharacter.position.y*6)/6)
    }
    
    func setLevel(newLevel:Level)
    {
        thisCharacter.hidden = true
        nonCharNodes.hidden = true
        //TODO: trigger loading screen
        GameLogic.setGameState(.LoadingScreen)
        for node in nonCharNodes.children {
            node.removeFromParent()
        }
        currentLevel = newLevel
        nonCharNodes.addChild(currentLevel!)
        thisCharacter.position = currentLevel!.tileEdge * currentLevel!.startLoc
        //end loading screen
        GameLogic.setGameState(.InGame)
        thisCharacter.hidden = false
        nonCharNodes.hidden = false
        
    }
    
    func getLevel() -> Level? {
        return currentLevel
    }
    
    ////////
    override func update(currentTime: CFTimeInterval) {
        if (GameLogic.getCurrentState() == GameStates.InGame) {
            camera!.position = oldLoc //reset position to floating-point value for SKPhysics
            if (currentLevel != nil) {
                let mapLoc = currentLevel!.indexForPoint(thisCharacter.position)
                currentLevel!.cull(Int(mapLoc.x), y: Int(mapLoc.y), width: currentLevel!.mapWidth+2, height: currentLevel!.mapHeight+2) //Remove tiles that are off-screen
            }
            GameLogic.update(currentTime)
        }
    }
 
   
    func addObject(node:SKNode) {
        if (node.parent == nil) {
            nonCharNodes.addChild(node)
        }
    }

}
