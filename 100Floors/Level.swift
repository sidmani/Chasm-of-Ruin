//
//  Level.swift
//  100Floors
//
//  Created by Sid Mani on 1/29/16.
//
//

class Level:SKNode { //level is just a map with attributes etc
    private var map:SKATiledMap
  //  var id:String
    var startLoc:CGPoint
    var objects = [MapObject]()
    
    init(_map:String, _name:String, _startLoc:CGPoint) {
        map = SKATiledMap(mapName: _map)
   //     id = _id
        startLoc = _startLoc
        super.init()
        name = _name
        self.addChild(map)
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
        let point = CGPointMake(CGFloat(thisLevel["spawn-loc"]["x"].doubleValue), CGFloat(thisLevel["spawn-loc"]["y"].doubleValue))
        self.init(_map:thisLevel["map"].value!, _name:thisLevel["name"].value!, _startLoc:point)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func indexForPoint(p:CGPoint) -> CGPoint {
        return map.indexForPoint(p)
    }
    func cull(x:Int, y:Int, width:Int, height:Int) {
        map.cullAroundIndexX(x, indexY: y, columnWidth: width, rowHeight: height)
    }
}

class Dungeon { //this is procedurally generated
    
}

class Hub:Level { //probably delete this

}