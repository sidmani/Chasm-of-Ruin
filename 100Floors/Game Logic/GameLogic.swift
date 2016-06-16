//
//  GameLogic.swift
//  100Floors
//
//  Created by Sid Mani on 1/9/16.
//
//
import Swift
import SpriteKit
import UIKit
import Foundation

protocol Updatable {
    func update(deltaT:Double)
}


let itemXML: AEXMLDocument! = {() -> AEXMLDocument? in
    let xmlPath = NSBundle.mainBundle().pathForResource("Items", ofType: "xml")
    let data = NSData(contentsOfFile: xmlPath!)!
    do {
        return try AEXMLDocument(xmlData: data)
    }
    catch {
        return nil
    }
    
}()
let levelXML: AEXMLDocument! = {() -> AEXMLDocument? in
    let xmlPath = NSBundle.mainBundle().pathForResource("Levels", ofType: "xml")!
    let data = NSData(contentsOfFile: xmlPath)!
    do {
        return try AEXMLDocument(xmlData: data)
    }
    catch {
        return nil
    }
    
}()

let enemyXML: AEXMLDocument! = {() -> AEXMLDocument? in
    let xmlPath = NSBundle.mainBundle().pathForResource("Enemies", ofType: "xml")!
    let data = NSData(contentsOfFile: xmlPath)!
    do {
        print("loaded xml")
        return try AEXMLDocument(xmlData: data)
    }
    catch {
        return nil
    }
    
}()
var thisCharacter:ThisCharacter!

//////////////////
//Global functions
//////////////////

func *(left: CGFloat, right: CGPoint) -> CGPoint {
    return CGPoint(x: left*right.x, y: left*right.y)
}
func *(left: CGFloat, right: CGVector) -> CGVector {
    return CGVector(dx: left*right.dx, dy: left*right.dy)
}
func randomBetweenNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat{
    return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
}
// test overloads
func print(point:CGPoint)
{
    print("(\(point.x),\(point.y))")
}
