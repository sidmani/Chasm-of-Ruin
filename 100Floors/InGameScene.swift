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
    var currentMap:SKATiledMap?
    var character = SKNode()
    var nonCharNodes = SKNode()
        var mapObjects = SKNode()
        var map = SKNode()
        var projectiles = SKNode()
        var enemies = SKNode()

    override func didMoveToView(view: SKView) {
        self.physicsWorld.gravity = CGVectorMake(0,0)
        map.zPosition = 0
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
        nonCharNodes.addChild(map)
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
        if (currentMap != nil) {
        currentMap!.removeFromParent()
        }
        for node in enemies.children {
            node.removeFromParent()
        }
        for node in projectiles.children {
            node.removeFromParent()
        }
        currentLevel = newLevel
        currentMap = (currentLevel!.map)
        map.addChild(currentMap!)
        //end loading screen
        character.hidden = false
        nonCharNodes.hidden = false
        
    }
    ////////
    override func update(currentTime: CFTimeInterval) {
        //cull unnecessary tiles
        if (currentMap != nil) {
            let mapLoc = currentMap!.indexForPoint(nonCharNodes.position)
            let newLoc = mapCenterLoc-mapLoc
            currentMap!.cullAroundIndexX(Int(newLoc.x), indexY: Int(newLoc.y), columnWidth: mapTilesWidth-1, rowHeight: mapTilesHeight-1)
            }
        //////////////
        GameLogic.update()
        //////////////

    }
    
    func addProjectile(p:Projectile)
    {
        projectiles.addChild(p)
    }
    func addEnemy(e:Enemy) {
        enemies.addChild(e)
    }
    func addMapObject(m:MapObject) {
        mapObjects.addChild(m)
    }
    
    
}
