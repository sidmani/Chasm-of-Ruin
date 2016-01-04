//
//  100Floors.swift
//  100Floors
//
//  Created by Sid Mani on 1/3/16.
//
//
import UIKit
enum Wearable {
    case Cloak, Robe, Vest
}
class HundredFloors {
    // MARK: Global UI properties
    var left_joystick_distance:Float = 0
    var left_joystick_angle:Float = 0
    var right_joystick_distance:Float = 0
    var right_joystick_angle:Float = 0
    
    // MARK: Character-specific properties
    var x_loc:Float, y_loc:Float
    var clothing:Wearable
    
    init(x:Float, y:Float, clothes:Wearable)
    {
        x_loc = x
        y_loc = y
        clothing = clothes
    }
    func update_loc(distance: Float, angle: Float, sensitivity: Float)
    {

    }
    func update_joystick_left(distance:Float, angle:Float)
    {
        left_joystick_angle = angle
        left_joystick_distance = distance
    }
    func update_joystick_right(distance:Float, angle:Float)
    {
        right_joystick_angle = angle
        right_joystick_distance = distance
    }
    
}