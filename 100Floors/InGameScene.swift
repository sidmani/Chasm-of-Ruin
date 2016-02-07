//
//  InGameScene.swift
//  100Floors
//
//  Created by Sid Mani on 1/2/16.
//
//


import SpriteKit

class InGameScene: SKScene {
    var character = SKNode()
    var nonCharNodes:SKNode = SKNode()
        var map:SKNode = SKNode()
        var mapObjects:SKNode = SKNode()
        var nonMapNodes:SKNode = SKNode()
            var projectiles:SKNode = SKNode()
            var enemies:SKNode = SKNode()

    override func didMoveToView(view: SKView) {

        self.physicsWorld.gravity = CGVectorMake(0,0)
        currentMap = SKATiledMap(mapName: "Map1")
        map.addChild(currentMap!)
        map.zPosition = 0
        GameLogic.setScene(self)
        nonCharNodes.physicsBody = SKPhysicsBody()
        nonCharNodes.physicsBody!.affectedByGravity = false
        nonCharNodes.physicsBody!.friction = 0
        
        //////////////////////////////////////////
        character.addChild(thisCharacter)
        character.zPosition = 5
        //////////////////////////////////////////
        
        nonMapNodes.addChild(enemies)
        nonMapNodes.addChild(projectiles)
        
        nonCharNodes.addChild(map)
        nonCharNodes.addChild(nonMapNodes)
        nonCharNodes.addChild(mapObjects)
        
        addChild(nonCharNodes)
        addChild(character)
    }

    
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
        let mapLoc = currentMap!.indexForPoint(nonCharNodes.position)
        let newLoc = mapCenterLoc-mapLoc
        currentMap!.cullAroundIndexX(Int(newLoc.x), indexY: Int(newLoc.y), columnWidth: mapTilesWidth-1, rowHeight: mapTilesHeight-1)
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
    func addMapObject(m:SKSpriteNode) {
        mapObjects.addChild(m)
    }
    
    
}
