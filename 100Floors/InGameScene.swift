//
//  InGameScene.swift
//  100Floors
//
//  Created by Sid Mani on 1/2/16.
//
//


import SpriteKit

class InGameScene: SKScene {
    private var currentLevel:Level?
    //var currentMap:SKATiledMap? {
    //    return currentLevel?.map
    //}
    var character = SKNode()
    var nonCharNodes = SKNode()
        var mapObjects = SKNode()
        //var map = SKNode()
        var projectiles = SKNode()
        var enemies = SKNode()

    override func didMoveToView(view: SKView) {
        self.physicsWorld.gravity = CGVectorMake(0,0)
        //map.zPosition = 0
        GameLogic.setScene(self)
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
        //nonCharNodes.addChild(map)
        nonCharNodes.addChild(mapObjects)
        addChild(nonCharNodes)
        addChild(character)
    }

    
    func setLevel(newLevel:Level)
    {
        character.hidden = true
        nonCharNodes.hidden = true
        //Hide controls
        //TODO: trigger loading screen 
        if (currentLevel?.map != nil) {
        currentLevel!.map.removeFromParent()
        }
        for node in enemies.children {
            node.removeFromParent()
        }
        for node in projectiles.children {
            node.removeFromParent()
        }
        currentLevel = newLevel
        currentLevel!.map.zPosition = 0
        nonCharNodes.addChild(currentLevel!.map)
        setCharPosition(tileEdge * newLevel.startLoc)
        //end loading screen
        character.hidden = false
        nonCharNodes.hidden = false
        
    }
    func setCharPosition(atPoint:CGPoint) {
        nonCharNodes.position = CGPointMake(screenSize.width/2 - atPoint.x, screenSize.height/2 - atPoint.y)
    }
    func getPositionOnMap(ofNode:SKNode) -> CGPoint {
        return currentLevel!.map.convertPoint(currentLevel!.map.position, fromNode: ofNode)
    }
    ////////
    override func update(currentTime: CFTimeInterval) {
        //cull unnecessary tiles
        if (currentLevel != nil) {
            let mapLoc = currentLevel!.map.indexForPoint(nonCharNodes.position)
            let newLoc = mapCenterLoc-mapLoc
            currentLevel!.map.cullAroundIndexX(Int(newLoc.x), indexY: Int(newLoc.y), columnWidth: mapTilesWidth-1, rowHeight: mapTilesHeight-1)
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
    func addMapObject(m:MapObject) {
        if (m.parent == nil) {
        mapObjects.addChild(m)
        }
    }
    
    
}
