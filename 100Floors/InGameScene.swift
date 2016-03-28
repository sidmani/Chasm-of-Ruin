//
//  InGameScene.swift
//  100Floors
//
//  Created by Sid Mani on 1/2/16.
//
//


import SpriteKit

class InGameScene: SKScene, SKPhysicsContactDelegate {
    struct PhysicsCategory {
        static let None: UInt32 = 0
        static let All: UInt32 = UINT32_MAX
        static let FriendlyProjectile: UInt32 = 0b00001
        static let ThisPlayer: UInt32 = 0b00010
        static let Enemy: UInt32 = 0b00100
        static let Interactive: UInt32 = 0b01000
        static let EnemyProjectile: UInt32 = 0b10000
        static let MapBoundary:UInt32 = 0b100000
    }
    
    private var currentLevel:BaseLevel?
    private var oldLoc:CGPoint = CGPointZero
    private var oldTime:CFTimeInterval = 0
    private var mainCamera = SKCameraNode()
    
    var nonCharNodes = SKNode()
    
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
        /////// player contacts interactive object
        if (contact.bodyA.categoryBitMask == PhysicsCategory.Interactive && contact.bodyB.categoryBitMask == PhysicsCategory.ThisPlayer) {
            GameLogic.isWithinDistanceOf(contact.bodyA.node as? Interactive)
            return
        }
        else if (contact.bodyB.categoryBitMask == PhysicsCategory.Interactive && contact.bodyA.categoryBitMask == PhysicsCategory.ThisPlayer) {
            GameLogic.isWithinDistanceOf(contact.bodyB.node as? Interactive)
            return
        }
        ////// player is hit by projectile
        else if (contact.bodyA.categoryBitMask == PhysicsCategory.ThisPlayer && contact.bodyB.categoryBitMask == PhysicsCategory.EnemyProjectile) {
            thisCharacter.struckByProjectile(contact.bodyB.node as! Projectile)
            return
        }
        else if (contact.bodyB.categoryBitMask == PhysicsCategory.ThisPlayer && contact.bodyA.categoryBitMask == PhysicsCategory.EnemyProjectile) {
            thisCharacter.struckByProjectile(contact.bodyA.node as! Projectile)
            return
        }
        ////// projectile hits map boundary
        else if ((contact.bodyA.categoryBitMask == PhysicsCategory.EnemyProjectile || contact.bodyA.categoryBitMask == PhysicsCategory.FriendlyProjectile) && contact.bodyB.categoryBitMask == PhysicsCategory.MapBoundary) {
            (contact.bodyA.node as! Projectile).struckMapBoundary()
            return
        }
        else if ((contact.bodyB.categoryBitMask == PhysicsCategory.EnemyProjectile || contact.bodyB.categoryBitMask == PhysicsCategory.FriendlyProjectile) && contact.bodyA.categoryBitMask == PhysicsCategory.MapBoundary) {
            (contact.bodyB.node as! Projectile).struckMapBoundary()
            return
        }
        
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == PhysicsCategory.Interactive && contact.bodyB.categoryBitMask == PhysicsCategory.ThisPlayer || contact.bodyB.categoryBitMask == PhysicsCategory.Interactive && contact.bodyA.categoryBitMask == PhysicsCategory.ThisPlayer) {
            GameLogic.isWithinDistanceOf(nil)
            return
        }
    }
    
    override func didFinishUpdate() {
        oldLoc = camera!.position
        camera!.position = CGPointMake(floor(thisCharacter.position.x*6)/6, floor(thisCharacter.position.y*6)/6)
    }
    
    func setLevel(newLevel:BaseLevel)
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
    
    ////////
    override func update(currentTime: CFTimeInterval) {
        let deltaT = (currentTime-oldTime)*1000
        oldTime = currentTime
        if (GameLogic.getCurrentState() == GameStates.InGame && deltaT < 100) {
            camera!.position = oldLoc //reset position to floating-point value for SKPhysics
            if (currentLevel != nil) {
                let newWidth = Int(CGFloat(currentLevel!.mapSizeOnScreen.width)*camera!.xScale)+2
                let newHeight = Int(CGFloat(currentLevel!.mapSizeOnScreen.height)*camera!.yScale)+2
                let mapLoc = currentLevel!.indexForPoint(thisCharacter.position)
                currentLevel!.cull(Int(mapLoc.x), y: Int(mapLoc.y), width: newWidth, height: newHeight) //Remove tiles that are off-screen
            }
            GameLogic.update(deltaT) //send update methods time diff in ms
        }
    }
 
   
    func addObject(node:SKNode) {
        if (node.parent == nil) {
            if let obj = node as? MapObject {
                currentLevel?.addObject(obj)
            }
            else {
                nonCharNodes.addChild(node)
            }
        }
    }
    
}
