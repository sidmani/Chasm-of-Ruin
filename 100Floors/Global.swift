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
let mapTileWidth:Int = Int(screenSize.width/(16))
let mapTilesHeight:Int = Int(screenSize.height/(16))
let mapCenterLoc:CGPoint = CGPoint(x: mapTileWidth/2,y: mapTilesHeight/2)
let inventory_size = 8 // TODO: fix this (get from server, IAP)

//Functions
func +(left: CGPoint, right:CGPoint) -> CGPoint {
    return CGPoint(x: left.x+right.x, y: left.y+right.y)
}
func -(left: CGPoint, right:CGPoint) -> CGPoint {
    return CGPoint(x: left.x-right.x, y: left.y-right.y)
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

