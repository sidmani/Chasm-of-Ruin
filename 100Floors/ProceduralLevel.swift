//
//  ProceduralMap.swift
//  100Floors
//
//  Created by Sid Mani on 2/26/16.
//
//
enum MapThemes {
    case Grass, Rock, Lava
}


class ProceduralLevel:BaseLevel, Updatable {
    
    private var objects = SKNode()
    private var map = SKNode()
    
    var collisionBodies = SKNode()
    
   // init() {
        
   // }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(deltaT: Double) {
        
    }
    
    
    
}
