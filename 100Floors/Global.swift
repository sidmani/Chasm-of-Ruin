//
//  Global.swift
//  100Floors
//
//  Created by Sid Mani on 1/9/16.
//
//
import UIKit

//Screen/Map constants
let screenSize: CGRect = UIScreen.mainScreen().bounds
let screenCenter:CGPoint = CGPoint(x: Int(screenSize.width/2), y: Int(screenSize.height/2))
let tileEdge:CGFloat = 32
let mapTilesWidth:Int = Int(screenSize.width/(tileEdge))
let mapTilesHeight:Int = Int(screenSize.height/(tileEdge))
let mapCenterLoc:CGPoint = CGPoint(x: mapTilesWidth/2,y: mapTilesHeight/2)
//Game logic constants
let inventory_size = 8 // TODO: fix this (IAP)

protocol Updatable {
    func update()
}
let nullStats = Stats(health: 0, defense: 0, attack: 0, speed: 0, dexterity: 0, hunger: 0, level: 0, mana: 0, rage: 0) //TODO: remove this later
///////////
//Physics bitmasks
struct PhysicsCategory {
    static let None: UInt32 = 0
    static let All: UInt32 = UINT32_MAX
    static let FriendlyProjectile: UInt32 = 0b00001
    static let ThisPlayer: UInt32 = 0b00010
    static let Enemy: UInt32 = 0b00100
    static let MapObject: UInt32 = 0b01000
    static let EnemyProjectile: UInt32 = 0b10000
}
//Operator overloads
func +(left: CGPoint, right:CGPoint) -> CGPoint {
    return CGPoint(x: left.x+right.x, y: left.y+right.y)
}

func -(left: CGPoint, right:CGPoint) -> CGPoint {
    return CGPoint(x: left.x-right.x, y: left.y-right.y)
}
func *(left: CGFloat, right: CGPoint) -> CGPoint {
    return CGPointMake(left*right.x, left*right.y)
}

func +(left: Stats, right:Stats) -> Stats { // add Stats together
    return Stats(health: left.health + right.health,  defense: left.defense + right.defense, attack: left.attack + right.attack, speed: left.speed+right.speed, dexterity: left.dexterity + right.dexterity, hunger: left.hunger + right.hunger, level: left.level+right.level, mana: left.mana+right.mana, rage: left.rage + right.rage)
}

func +(left:CGVector, right:CGVector) -> CGVector {
    return CGVectorMake(left.dx + right.dx, left.dy + right.dy)
}

//Is left divisible by right?

infix operator %% {}

func %%(left: Int, right: Int) -> Bool {
    return left % right == 0
}

//Shorthand to invert a vector
prefix operator ~ {}

prefix func ~ (vector:CGVector) -> CGVector
{
    return CGVectorMake(-1*vector.dx, -1*vector.dy)
}

// test overloads
func print(point:CGPoint)
{
    print("(\(point.x),\(point.y))")
}
