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
    var character = SKNode()
    var nonCharNodes = SKNode()
        var projectiles = SKNode()
        var enemies = SKNode()
    override func didMoveToView(view: SKView) {
        self.physicsWorld.gravity = CGVectorMake(0,0)
        self.physicsWorld.contactDelegate = self
        GameLogic.setup()
        nonCharNodes.physicsBody = SKPhysicsBody()
        nonCharNodes.physicsBody!.affectedByGravity = false
        nonCharNodes.physicsBody!.friction = 0
        
        //////////////////////////////////////////
        character.addChild(thisCharacter)
        character.zPosition = 5
        //////////////////////////////////////////
        
        nonCharNodes.addChild(enemies)
        nonCharNodes.addChild(projectiles)
        addChild(nonCharNodes)
        addChild(character)
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
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == PhysicsCategory.Interactive && contact.bodyB.categoryBitMask == PhysicsCategory.ThisPlayer || contact.bodyB.categoryBitMask == PhysicsCategory.Interactive && contact.bodyA.categoryBitMask == PhysicsCategory.ThisPlayer) {
            GameLogic.exitedInteractDistance()
            return
        }
    }
    
    func setLevel(newLevel:Level)
    {
        character.hidden = true
        nonCharNodes.hidden = true
        //Hide controls
        //TODO: trigger loading screen 
        for node in enemies.children {
            node.removeFromParent()
        }
        for node in projectiles.children {
            node.removeFromParent()
        }
        currentLevel?.removeFromParent()
        currentLevel = newLevel
        nonCharNodes.addChild(currentLevel!)
        setCharPosition(tileEdge * newLevel.startLoc)
        //end loading screen
        //show controls
        character.hidden = false
        nonCharNodes.hidden = false
        
    }
    func setCharPosition(atPoint:CGPoint) {
        nonCharNodes.position = CGPointMake(screenSize.width/2 - atPoint.x, screenSize.height/2 - atPoint.y)
    }
    func getPositionOnMap(ofNode:SKNode) -> CGPoint {
        return currentLevel!.convertPoint(currentLevel!.position, fromNode: ofNode)
    }
    ////////
    override func update(currentTime: CFTimeInterval) {
        //cull unnecessary tiles
        if (currentLevel != nil) {
            let mapLoc = currentLevel!.indexForPoint(nonCharNodes.position)
            let newLoc = mapCenterLoc-mapLoc
            currentLevel!.cull(Int(newLoc.x), y: Int(newLoc.y), width: mapTilesWidth-1, height: mapTilesHeight-1)
            }
        //////////////
        GameLogic.update()
        //////////////

    }
    func getCurrentLevel() -> Level {
        return currentLevel!
    }
    func addProjectile(p:Projectile)
    {
        if (p.parent == nil) {
        projectiles.addChild(p)
        }
    }
    func addEnemy(e:Enemy) {
        if (e.parent == nil) {
        enemies.addChild(e)
        }
    }
}
