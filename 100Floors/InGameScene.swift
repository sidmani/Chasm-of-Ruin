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
    var character = SKNode()
    var nonCharNodes = SKNode()
        var projectiles = SKNode()
        var enemies = SKNode()
    override func didMoveToView(view: SKView) {
        self.physicsWorld.gravity = CGVectorMake(0,0)
        self.physicsWorld.contactDelegate = self
        GameLogic.setGameState(.InGame)
        GameLogic.setup(self)
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
    override func didFinishUpdate() {
        oldLoc = nonCharNodes.position
        nonCharNodes.position = CGPointMake(floor(nonCharNodes.position.x*6)/6, floor(nonCharNodes.position.y*6)/6)
    }
    
    func setLevel(newLevel:Level)
    {
        character.hidden = true
        nonCharNodes.hidden = true
        //TODO: trigger loading screen
        GameLogic.setGameState(.LoadingScreen)
        for node in enemies.children {
            node.removeFromParent()
        }
        for node in projectiles.children {
            node.removeFromParent()
        }
        currentLevel?.removeFromParent()
        currentLevel = newLevel
        nonCharNodes.addChild(currentLevel!)
        setCharPosition(currentLevel!.tileEdge * currentLevel!.startLoc)
        //end loading screen
        GameLogic.setGameState(.InGame)
        character.hidden = false
        nonCharNodes.hidden = false
        
    }
    func setCharPosition(atPoint:CGPoint) {
        nonCharNodes.position = screenCenter - atPoint //this really should be fixed
        oldLoc = nonCharNodes.position
    }
    func getPositionOnMap(ofNode:SKNode) -> CGPoint {
        if (currentLevel != nil) {
        return currentLevel!.convertPoint(currentLevel!.position, fromNode: ofNode)
        }
        else {
        return CGPointZero
        }
    }
    ////////
    override func update(currentTime: CFTimeInterval) {
        if (GameLogic.getCurrentState() == GameStates.InGame) {
            nonCharNodes.position = oldLoc //reset position to floating-point value for SKPhysics
            if (currentLevel != nil) {
                let mapLoc = currentLevel!.indexForPoint(nonCharNodes.position)
                let newLoc = currentLevel!.mapCenterLoc-mapLoc
                currentLevel!.cull(Int(newLoc.x), y: Int(newLoc.y), width: currentLevel!.mapTilesWidth+3, height: currentLevel!.mapTilesHeight+3) //Remove tiles that are off-screen
            }
            GameLogic.update(currentTime)
        }

    }
    func getCurrentLevel() -> Level? {
        return currentLevel
    }
    func addProjectile(p:Projectile) {
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
