//
//  Level.swift
//  100Floors
//
//  Created by Sid Mani on 1/29/16.
//
//

class Level { //level is just a map with attributes etc
    var map:SKATiledMap
    var id:String
    var name:String
    init(_map:String, _id: String, _name:String) {
        map = SKATiledMap(mapName: _map)
        id = _id
        name = _name
    }
    //convenience init (_id:String) {
        
    //}
}

class Dungeon { //this is procedurally generated
    
}

class Hub:Level {

}