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

    private var oldTime:CFTimeInterval = 0
    private let mainCamera = SKCameraNode()
    
    private var nonCharNodes = SKNode()
    
    private var cameraBounds:(left:CGFloat, right:CGFloat, top:CGFloat, bottom:CGFloat) = (left:0, right:0, top:0 ,bottom:0)
    var currentGroundBag:ItemBag?
    
    override func didMoveToView(view: SKView) {
        self.physicsWorld.gravity = CGVectorMake(0,0)
        self.physicsWorld.contactDelegate = self
        self.scaleMode = .AspectFill
        self.camera = mainCamera
        self.camera!.position = thisCharacter.position
        self.camera!.setScale(0.2)
        self.paused = true
        //////////////////////////////////////////
        //////////////////////////////////////////
        addChild(nonCharNodes)
        addChild(thisCharacter)
    }

    func didBeginContact(contact: SKPhysicsContact) {
        /////// player contacts interactive object
        if (contact.bodyA.categoryBitMask == PhysicsCategory.Interactive) {
            let object = contact.bodyA.node as! Interactive
            if (object.autotrigger) { object.trigger() }
            object.displayPopup(true)
            if (object is ItemBag) {currentGroundBag = (object as! ItemBag)}
            return
        }
        else if (contact.bodyB.categoryBitMask == PhysicsCategory.Interactive) {
            let object = contact.bodyB.node as! Interactive
            if (object.autotrigger) { object.trigger() }
            object.displayPopup(true)
            if (object is ItemBag) {currentGroundBag = (object as! ItemBag)}
            return
        }
        ////// player is hit by projectile
        else if (contact.bodyA.categoryBitMask == PhysicsCategory.ThisPlayer && contact.bodyB.categoryBitMask == PhysicsCategory.EnemyProjectile) {
            if let projectile = contact.bodyB.node as? Projectile {
                thisCharacter.struckByProjectile(projectile)
                projectile.struckMapBoundary()
                return
            }
        }
        else if (contact.bodyB.categoryBitMask == PhysicsCategory.ThisPlayer && contact.bodyA.categoryBitMask == PhysicsCategory.EnemyProjectile) {
            if let projectile = contact.bodyA.node as? Projectile {
                thisCharacter.struckByProjectile(projectile)
                projectile.struckMapBoundary()
                return
            }
        }
        ////// projectile hits map boundary
        else if ((contact.bodyA.categoryBitMask == PhysicsCategory.EnemyProjectile || contact.bodyA.categoryBitMask == PhysicsCategory.FriendlyProjectile) && contact.bodyB.categoryBitMask == PhysicsCategory.MapBoundary) {
            if let projectile = contact.bodyA.node as? Projectile {
                projectile.struckMapBoundary()
                return
            }
        }
            
        else if ((contact.bodyB.categoryBitMask == PhysicsCategory.EnemyProjectile || contact.bodyB.categoryBitMask == PhysicsCategory.FriendlyProjectile) && contact.bodyA.categoryBitMask == PhysicsCategory.MapBoundary) {
            if let projectile = contact.bodyB.node as? Projectile {
                projectile.struckMapBoundary()
                return
            }
        }
        ////// character enters spawner radius
        else if (contact.bodyA.categoryBitMask == PhysicsCategory.Spawner) {
            (contact.bodyA.node as! Spawner).playerIsInRadius(true)
        }
        else if (contact.bodyB.categoryBitMask == PhysicsCategory.Spawner) {
            (contact.bodyB.node as! Spawner).playerIsInRadius(true)
        }
        ////// enemy hit by friendly projectile
        else if (contact.bodyA.categoryBitMask == PhysicsCategory.FriendlyProjectile && contact.bodyB.categoryBitMask == PhysicsCategory.Enemy) {
            if let projectile = contact.bodyA.node as? Projectile {
                (contact.bodyB.node as? Enemy)?.struckByProjectile(projectile)
                projectile.struckMapBoundary()
            }
            return
        }
            
        else if (contact.bodyB.categoryBitMask == PhysicsCategory.FriendlyProjectile && contact.bodyA.categoryBitMask == PhysicsCategory.Enemy) {
            if let projectile = contact.bodyB.node as?  Projectile {
                (contact.bodyA.node as? Enemy)?.struckByProjectile(projectile)
                projectile.struckMapBoundary()
                return
            }
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == PhysicsCategory.Interactive && contact.bodyB.categoryBitMask == PhysicsCategory.ThisPlayer) {
            let object = contact.bodyA.node as! Interactive
            object.displayPopup(false)
            if (object is ItemBag && (object as! ItemBag) == currentGroundBag) { currentGroundBag = nil }
        }
        else if (contact.bodyB.categoryBitMask == PhysicsCategory.Interactive && contact.bodyA.categoryBitMask == PhysicsCategory.ThisPlayer) {
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
        var newLoc = CGPointMake(floor(thisCharacter.position.x*10)/10, floor(thisCharacter.position.y*10)/10)
        newLoc.x = min(cameraBounds.right, newLoc.x)
        newLoc.x = max(cameraBounds.left, newLoc.x)
        newLoc.y = min(cameraBounds.top, newLoc.y)
        newLoc.y = max(cameraBounds.bottom, newLoc.y)
        camera!.position = newLoc

    }

    
    @objc func setLevel(level:BaseLevel)
    {
        thisCharacter.hidden = true
        nonCharNodes.hidden = true
        nonCharNodes.removeAllChildren()
        currentLevel = level
        nonCharNodes.addChild(currentLevel!)
        thisCharacter.position = CGPointMake(currentLevel!.tileEdge * currentLevel!.startLoc.x, currentLevel!.tileEdge * currentLevel!.startLoc.y)
        cameraBounds = (left: camera!.xScale*screenSize.width/2, right: (currentLevel!.mapSize.width) - camera!.xScale*(screenSize.width/2), bottom: camera!.yScale*screenSize.height/2, top: (currentLevel!.mapSize.height) - camera!.yScale*(screenSize.height/2))
        // if (introScreen) {
            //TODO: trigger intro screen
      //  }
        thisCharacter.hidden = false
        nonCharNodes.hidden = false
        self.paused = false
    }
    
    func endLevel() {
        //TODO: fill out method body
        //hide character
        //hide nodes
        //pause scene (?)
        //save data
        //display stats
        //add level index to completed levels (if not already present)
        //trigger unlock of other levels
        //wait for user to click "next" and then move back to level select screen
    }
    ////////
    override func update(currentTime: CFTimeInterval) {
        let deltaT = (currentTime-oldTime)*1000
        oldTime = currentTime
        if (deltaT < 100) {
            if (currentLevel != nil) {
                let newWidth = Int(currentLevel!.mapSizeOnScreen.width*camera!.xScale)
                let newHeight = Int(currentLevel!.mapSizeOnScreen.height*camera!.yScale)
                let mapLoc = currentLevel!.indexForPoint(thisCharacter.position)
                currentLevel!.cull(Int(mapLoc.x), y: Int(mapLoc.y), width: newWidth - 1, height: newHeight - 1) //Remove tiles that are off-screen
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
