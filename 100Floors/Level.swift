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
    convenience init (_id:String) {
        var thisLevel:AEXMLElement
        if let levels = levelXML!.root["level"].allWithAttributes(["index":_id]) {
            if (levels.count != 1) {
                fatalError("Level ID error")
            }
            else {
                thisLevel = levels[0]
            }
        }
        else {
            fatalError("Level Not Found")
        }
        self.init(_map:thisLevel["map"].value!, _id:_id, _name:thisLevel["name"].value!)
    }
}

class Dungeon { //this is procedurally generated
    
}

class Hub:Level {

}