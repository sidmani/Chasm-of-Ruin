//
//  SKATMXParser.swift
//  SKATiledMapExample
//
//  Created by Skyler Lauren on 10/17/15.
//  Copyright © 2015 Sprite Kit Alliance. All rights reserved.
//

import Foundation

class SKATMXParser : NSObject, XMLParserDelegate {
    
    //MARK: - Public Properties
    var parser = XMLParser()
    var mapDictionary = ["properties" : [String: AnyObject]()] as [String : AnyObject]
    //MARK: - Private Properties
    /**
     Parsing keys
     */
    private let kMap = "map"
    private let kTileset = "tileset"
    private let kTile = "tile"
    private let kImage = "image"
    private let kLayer = "layer"
    private let kData = "data"
    private let kObjectGroup = "objectgroup"
    private let kObject = "object"
    private let kProperty = "property"
    private let kProperies = "properties"
    private let kPolygon = "polygon"
    private let kPolyline = "polyline"
    private let kEllipse = "ellipse"

    /**
     Data holders for tile sets
     */
    private var tileSets = [[String: AnyObject]]()
    private var tileSet = [String: AnyObject]()
    
    /**
     Data holders for tile information
     */
    private var tileID = ""
    private var tiles = [String: AnyObject]()
    private var tile = [String: AnyObject]()
    
    /**
     Data holders layer information
     */
    private var layers = [[String: AnyObject]]()
    private var layer = [String: AnyObject]()
    private var data = [String : AnyObject]()
    
    /**
     Dataholders for object layers
     */
    private var objectLayers = [[String: AnyObject]]()
    private var objectLayer = [String: AnyObject]()
    
    /**
     Dataholders for objects
     */
    private var objects = [[String: AnyObject]]()
    private var object = [String: AnyObject]()
    var properties = [String: AnyObject]()
    
    
    //MARK: - Initializers
    /**
    Designated Initializer
    @param filePath used to locate tmx file
    */
    init(filePath : String){
        
        super.init()
        
        //attemps to load tmx as xml
        do{
            let tmxData = try Data(contentsOf: URL(fileURLWithPath: filePath), options: .mappedIfSafe)
            
            if (tmxData.count > 0)
            {
                parser = XMLParser(data: tmxData)
            }
            else{
                fatalError("Unable to load tmx file: \(filePath)")
            }
        }
        catch
        {
            fatalError("Unable to load tmx file: \(filePath)")
        }
        
        parser.delegate = self
        parser.parse()
    }
    
    //MARK: - Required Default Setters For Parsing
    private func newObject() -> [String: AnyObject]{
        return ["x": "0", "y": "0", "width": "0", "height": "0", "type": "", "name": "pizza", "rotation": 0.0, "visible": true, "ellipse": false]
    }
    
    private func newObjectLayer() -> [String: AnyObject]{
        return ["x": 0, "y": 0, "width": 0, "height": 0, "type": "", "name": "", "opacity": 0.0, "visible": true, "draworder": "topdown"]
    }
    
    private func newSpriteLayer() -> [String: AnyObject]{
        return ["x": 0, "y": 0, "width": 0, "height": 0, "type": "", "name": "", "opacity": 0.0, "visible": true, "draworder": "topdown"]
    }
    
    private func newTileset() -> [String : AnyObject]{
        return ["spacing": 0, "margin": 0];
    }
    
    //MARK: - Clean Up Methods
    /**
    XML Parser returns strings so we need to convert and clean where needed
    */
    private func cleanDictionary(_ dictionary: [String : AnyObject]) -> [String : AnyObject] {
        var dictCopy = dictionary
        let intTypes = ["width", "height", "x", "y", "tilewidth", "tileheight", "firstgid", "imagewidth", "imageheight", "spacing", "margin"]
        let floatTypes = ["opacity", "rotation"]
        let boolTypes = ["visible"]
        for (key, value) in dictionary where value is String{
            //clean expected Ints
            for intType in intTypes where intType == key {
                dictCopy[key] = Int(Float(value as! String)!)
            }
            for floatType in floatTypes where floatType == key {
                dictCopy[key] = Float(value as! String)
            }
            for boolType in boolTypes where boolType == key {
                dictCopy[key] = Int(value as! String) == 1
            }
            
        }
        
        if let image = dictCopy["source"] as? String{
            dictCopy["image"] = image
            dictCopy["source"] = nil
        }
        
        return dictCopy
    }
    //MARK: - NSXMLParserDelegate Methods
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        //Filling correct data holders based on element name
        //When appropriate data holders are prefilled with required values that may not be in xml
        switch elementName{
            
        case kMap :
            for (key, value) in attributeDict{
                mapDictionary[key] = value
            }
        
        case kTileset :
            if (properties.count > 0) {
                var dict:[String:AnyObject]? = [:]
                for (key,value) in properties{
                   dict![key] = value
                }
                mapDictionary["properties"] = dict
                properties = [String: AnyObject]()
                dict = nil
            }
            tileSet = newTileset()
            for (key, value) in attributeDict{
                tileSet[key] = value
            }
        //resetting tiles because we are starting a new set
        tiles = [String : AnyObject]()

        case kTile :
            tile = [String: AnyObject]()
            //we only care about the id
            for (_, value) in attributeDict{
                tileID = value
            }
        
        case kImage :
            //tileId will be present if it is an image collection tile set
            if(tileID != ""){
                tile = attributeDict
            }
            //If no tileID is presnet it is a sprite sheet with additional values
            else{
                //for whatever reason json sets these values different than xml so 
                //they are converted to match json values
                for (key, value) in attributeDict{
                    if key == "width" {
                        tileSet["imagewidth"] = value
                    }
                    else if key == "height"{
                        tileSet["imageheight"] = value
                    }
                    else{
                        tileSet[key] = value
                    }
                }
            }
        
        case kLayer :
            layer = newSpriteLayer()
            for (key, value) in attributeDict{
                layer[key] = value
            }
        
        case kData:
            data = attributeDict
        
        case kObjectGroup :
            objectLayer = newObjectLayer()
            for (key, value) in attributeDict{
                objectLayer[key] = value
            }
        
        case kObject :
      //      print("discovered object")
            object = newObject()
            for (key, value) in attributeDict{
                object[key] = value
            }
        
        case kProperty:
            if let key = attributeDict["name"]{
                if let value = attributeDict["value"]{
                    properties[key] = value
                }
            }
        case kProperies:
            properties = [String: AnyObject]()
        case kPolygon:
            if let pairsString = attributeDict["points"] {
                
                var polygons = [[String: Int]]()
                let pairs = pairsString.components(separatedBy: " ")
                
                for pair in pairs{
                    let xy = pair.components(separatedBy: ",")
                    if xy.count == 2 {
                        let x = Int(NumberFormatter().number(from: xy[0])!.int32Value)
                        let y = Int(NumberFormatter().number(from: xy[1])!.int32Value)
                        polygons.append(["x": x, "y": y])
                    }else{
                        fatalError("TMXParser Error: expected x,y pair but got \(xy)")
                    }
                }
                
                object[kPolygon] = polygons
            }
        case kPolyline:
            if let pairsString = attributeDict["points"] {
                
                var polygons = [[String: Int]]()
                let pairs = pairsString.components(separatedBy: " ")
                
                for pair in pairs{
                    let xy = pair.components(separatedBy: ",")
                    if xy.count == 2 {
                        let x = Int(NumberFormatter().number(from: xy[0])!.int32Value)
                        let y = Int(NumberFormatter().number(from: xy[1])!.int32Value)
                        polygons.append(["x": x, "y": y])
                    }else{
                        fatalError("TMXParser Error: expected x,y pair but got \(xy)")
                    }
                }
                
                object[kPolyline] = polygons
            }
        case kEllipse:
            object[kEllipse] = true
        
        default :
            print("unexpected name found: \(elementName)\nAttr: \(attributeDict)")
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        //this gets called for every element but only data encoding matters
        if let encoding = data["encoding"] as? String{
            if encoding == "csv"{
                //converting csv to something useful
                let numberString = string.replacingOccurrences(of: "\n", with: "")
                let numbers = numberString.components(separatedBy: ",")
                
                var tileIDs = [Int]()
                
                for number in numbers{
                    tileIDs.append(Int(number)!)
                }
                layer["data"] = tileIDs
            }
            else{
                fatalError("Error: tmx only support csv layer format. Before saving tmx go to Map->Map Options->Map->Tile Layer Format and chaning to csv")
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        //Setting and cleaning up elements
        switch elementName{
            case kTileset:
                if(tiles.count > 0){
                    tileSet["tiles"] = tiles
                    tileSet["tileproperties"] = tiles
                }
                tileSets.append(cleanDictionary(tileSet))
            
            case kTile:
                
                if(properties.count > 0){
                    for (key, value) in properties{
                        tile[key] = value
                    }
                    
                    properties = [String: AnyObject]()
                }
                
                tiles[tileID] = (cleanDictionary(tile))
                
                tileID = ""
            
            case kLayer:
                if(properties.count > 0){
                    for (key, value) in properties{
                        layer[key] = value
                    }
                    properties = [String: AnyObject]()
                }
                layers.append(cleanDictionary(layer))
            case kData:
                data = [String : AnyObject]()
            
            case kObject:
                if(properties.count > 0){
                    for (key, value) in properties{
                        object[key] = value
                    }
                    properties = [String: AnyObject]()
                }
                objects.append(cleanDictionary(object))
            
            case kObjectGroup:
                if(properties.count > 0){
                    for (key, value) in properties{
                        objectLayer[key] = value
                    }
                    properties = [String: AnyObject]()
                }
                objectLayer["objects"] = objects
                layers.append(cleanDictionary(objectLayer))
                objects = []
            case kProperies:
                object["properties"] = properties
            
            default:
                break
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        //final clean up
        mapDictionary["tilesets"] = tileSets
        mapDictionary["layers"] = layers
        mapDictionary = cleanDictionary(mapDictionary)
    }
    

    //MARK: - Required Apple Method
    /**
     Lame required function for subclassing
     */
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
