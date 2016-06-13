//
//  InGameScene.swift
//  100Floors
//
//  Created by Sid Mani on 1/2/16.
//
//


import SpriteKit

let screenSize = UIScreen.mainScreen().bounds

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
        static let Spawner:UInt32 = 0b1000000
    }
    
    private var currentLevel:BaseLevel?
    private var oldLoc:CGPoint = CGPointZero
    private var oldTime:CFTimeInterval = 0
    private var mainCamera = SKCameraNode()
    
    private var nonCharNodes = SKNode()
    
    var currentGroundBag:ItemBag?
    
    override func didMoveToView(view: SKView) {
        self.physicsWorld.gravity = CGVectorMake(0,0)
        self.physicsWorld.contactDelegate = self
        self.scaleMode = .AspectFill
        self.camera = mainCamera
        self.camera!.position = thisCharacter.position
        self.camera!.setScale(0.2)
        nonCharNodes.name = "nonCharNodes"
        //////////////////////////////////////////
    //    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(setLevel), name: "setLevel", object: nil)
        //////////////////////////////////////////
        addChild(nonCharNodes)
        addChild(thisCharacter)
    }

    func didBeginContact(contact: SKPhysicsContact) {
        /////// player contacts interactive object
        if (contact.bodyA.categoryBitMask == PhysicsCategory.Interactive) {
          //  GameLogic.enteredDistanceOf(contact.bodyA.node as! Interactive)
            let object = contact.bodyA.node as! Interactive
            if (object.autotrigger) { object.trigger() }
            object.displayPopup(true)
            if (object is ItemBag) {currentGroundBag = (object as! ItemBag)}
            return
        }
        else if (contact.bodyB.categoryBitMask == PhysicsCategory.Interactive) {
           // GameLogic.enteredDistanceOf(contact.bodyB.node as! Interactive)
            let object = contact.bodyB.node as! Interactive
            if (object.autotrigger) { object.trigger() }
            object.displayPopup(true)
            if (object is ItemBag) {currentGroundBag = (object as! ItemBag)}
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
        ////// character enters spawner radius
        else if (contact.bodyA.categoryBitMask == PhysicsCategory.Spawner) {
            (contact.bodyA.node as! Spawner).playerIsInRadius(true)
        }
        else if (contact.bodyB.categoryBitMask == PhysicsCategory.Spawner) {
            (contact.bodyB.node as! Spawner).playerIsInRadius(true)
        }
        
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == PhysicsCategory.Interactive && contact.bodyB.categoryBitMask == PhysicsCategory.ThisPlayer) {
          //  GameLogic.exitedDistanceOf(contact.bodyA.node as! Interactive)
            let object = contact.bodyA.node as! Interactive
            object.displayPopup(false)
            if (object is ItemBag && (object as! ItemBag) == currentGroundBag) { currentGroundBag = nil }
        }
        else if (contact.bodyB.categoryBitMask == PhysicsCategory.Interactive && contact.bodyA.categoryBitMask == PhysicsCategory.ThisPlayer) {
            // GameLogic.exitedDistanceOf(contact.bodyB.node as! Interactive)
            let object = contact.bodyB.node as! Interactive
            object.displayPopup(false)
            if (object is ItemBag && (object as! ItemBag) == currentGroundBag) { currentGroundBag = nil }
        }
        ////// character exits spawner radius
        else if (contact.bodyA.categoryBitMask == PhysicsCategory.Spawner) {
            (contact.bodyA.node as! Spawner).playerIsInRadius(false)
        }
        else if (contact.bodyB.categoryBitMask == PhysicsCategory.Spawner) {
            (contact.bodyB.node as! Spawner).playerIsInRadius(false)
        }
    }
    
    override func didFinishUpdate() {
        oldLoc = self.camera!.position
        camera!.position = CGPointMake(floor(thisCharacter.position.x*10)/10, floor(thisCharacter.position.y*10)/10)
    }
    
    @objc func setLevel(level:BaseLevel)
    {
        thisCharacter.hidden = true
        nonCharNodes.hidden = true
        nonCharNodes.removeAllChildren()
        currentLevel = level
        nonCharNodes.addChild(currentLevel!)
        thisCharacter.position = currentLevel!.tileEdge * currentLevel!.startLoc
       // if (introScreen) {
            //TODO: trigger intro screen
      //  }
        thisCharacter.hidden = false
        nonCharNodes.hidden = false
        
    }
    
    ////////
    override func update(currentTime: CFTimeInterval) {
        let deltaT = (currentTime-oldTime)*1000
        oldTime = currentTime
        if (deltaT < 100) {
            camera!.position = oldLoc //reset position to floating-point value for SKPhysics
            if (currentLevel != nil) {
                let newWidth = Int(currentLevel!.mapSizeOnScreen.width*camera!.xScale)+2
                let newHeight = Int(currentLevel!.mapSizeOnScreen.height*camera!.yScale)+2
                let mapLoc = currentLevel!.indexForPoint(thisCharacter.position)
                currentLevel!.cull(Int(mapLoc.x), y: Int(mapLoc.y), width: newWidth, height: newHeight) //Remove tiles that are off-screen
            }
            thisCharacter.update(deltaT)
            for node in nonCharNodes.children {
                if let nodeToUpdate = node as? Updatable {
                    nodeToUpdate.update(deltaT)
                }
            }
        }
    }
 
   
    func addObject(node:SKNode) {
        if (node.parent == nil) {
            if let obj = node as? MapObject {
                currentLevel?.objects.addChild(obj)
            }
            else {
                nonCharNodes.addChild(node)
            }
        }
    }
    
}
