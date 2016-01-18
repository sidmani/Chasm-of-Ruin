//
//  Global.swift
//  100Floors
//
//  Created by Sid Mani on 1/9/16.
//
//
import UIKit

//Constants
let screenSize: CGRect = UIScreen.mainScreen().bounds
let screenCenter:CGPoint = CGPoint(x: Int(screenSize.width/2), y: Int(screenSize.height/2))
let tileEdge:CGFloat = 16
let mapTilesWidth:Int = Int(screenSize.width/(tileEdge))
let mapTilesHeight:Int = Int(screenSize.height/(tileEdge))
let mapCenterLoc:CGPoint = CGPoint(x: mapTilesWidth/2,y: mapTilesHeight/2)
let inventory_size = 8 // TODO: fix this (get from server, IAP)
var move_sensitivity:Int8 = 0
var rotate_sensitivity:Int8 = 0

//Operator overloads
func +(left: CGPoint, right:CGPoint) -> CGPoint {
    return CGPoint(x: left.x+right.x, y: left.y+right.y)
}
func -(left: CGPoint, right:CGPoint) -> CGPoint {
    return CGPoint(x: left.x-right.x, y: left.y-right.y)
}
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
//UI controls
var LeftJoystick:JoystickControl?
var RightJoystick:JoystickControl?
var HPBar:ReallyBigDisplayBar?
var ManaBar:DisplayBar?
var HungerBar:DisplayBar?
var Equip1:ItemContainer?
var Equip2:ItemContainer?
var Equip3:ItemContainer?
var Equip4:ItemContainer?

