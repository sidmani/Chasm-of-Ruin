//
//  InGameScene.swift
//  100Floors
//
//  Created by Sid Mani on 1/2/16.
//
//
//TODO: restructure this class (update and didSimulatePhysics)


import SpriteKit

class InGameScene: SKScene {
    var character = SKNode()
    var nonCharNodes:SKNode = SKNode()
        var map:SKNode = SKNode()
        var mapObjects:SKNode = SKNode()
        var nonMapNodes:SKNode = SKNode()
            var projectiles:SKNode = SKNode()
            var enemies:SKNode = SKNode()

    //var currFrame:Int = 0
    override func didMoveToView(view: SKView) {

        self.physicsWorld.gravity = CGVectorMake(0,0)
        //currentMap = Map(mapName: "Map") //load map
        currentMap = SKATiledMap(mapName: "Map1")
        map.addChild(currentMap!)
        map.zPosition = 0
    

        nonCharNodes.physicsBody = SKPhysicsBody()
        nonCharNodes.physicsBody!.affectedByGravity = false
        nonCharNodes.physicsBody!.friction = 0
        
        //////////////////////////////////////////
        thisCharacter.absoluteLoc = CGPoint(x: 0, y: 0)
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
        let mapLoc = currentMap!.indexForPoint(nonCharNodes.position)
        let newLoc = CGPointMake(0,0)-mapLoc
        currentMap!.cullAroundIndexX(Int(newLoc.x), indexY: Int(newLoc.y), columnWidth: mapTilesWidth-1, rowHeight: mapTilesHeight-1)
        //////////////
        GameLogic.update()
       // currentMap!.update()
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
    
    //////
    
   // override func didSimulatePhysics() {
        
   // }
    
    //////

   /* func updatenonCharNodes() {
        
       // for i in nonMapNodes.children {
       //     if let spriteNode = i as? nonPlayerObject {
       //         spriteNode.update()
       //     }
       // }
    
    }*/
    
    
}
