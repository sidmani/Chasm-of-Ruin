//
//  Global.swift
//  100Floors
//
//  Created by Sid Mani on 1/9/16.
//
//
import UIKit

//Screen constants
let screenSize = UIScreen.mainScreen().bounds
let screenCenter = CGPoint(x: Int(screenSize.width/2), y: Int(screenSize.height/2))

//Game logic constants
let inventory_size = 8 // TODO: fix this (IAP)

protocol Updatable {
    func update(deltaT:Double)
}

protocol Interactive {
    var autotrigger:Bool { get }
    func trigger()
}

let nilStats = Stats(health: 0, defense: 0, attack: 0, speed: 0, dexterity: 0, hunger: 0, level: 0, mana: 0, rage: 0)
///////////
//Physics bitmasks
struct PhysicsCategory {
    static let None: UInt32 = 0
    static let All: UInt32 = UINT32_MAX
    static let FriendlyProjectile: UInt32 = 0b00001
    static let ThisPlayer: UInt32 = 0b00010
    static let Enemy: UInt32 = 0b00100
    static let Interactive: UInt32 = 0b01000
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
    return CGPoint(x: left*right.x, y: left*right.y)
}

func +(left: Stats, right:Stats) -> Stats { // add Stats together
    return Stats(health: left.health + right.health,  defense: left.defense + right.defense, attack: left.attack + right.attack, speed: left.speed+right.speed, dexterity: left.dexterity + right.dexterity, hunger: left.hunger + right.hunger, level: left.level+right.level, mana: left.mana+right.mana, rage: left.rage + right.rage)
}

func +(left:CGVector, right:CGVector) -> CGVector {
    return CGVectorMake(left.dx + right.dx, left.dy + right.dy)
}

// test overloads
func print(point:CGPoint)
{
    print("(\(point.x),\(point.y))")
}
