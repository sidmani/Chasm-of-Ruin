//
//  Map.swift
//  100Floors
//
//  Created by Sid Mani on 1/16/16.
//
//


class Map:SKATiledMap {

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init!(mapName: String!) {
        super.init(mapName: mapName)
    }
    
    

   
}