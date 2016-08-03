//
//  Global.swift
//  100Floors
//
//  Created by Sid Mani on 1/9/16.
//
//
import UIKit
import Foundation

protocol Updatable {
    func update(_ deltaT:Double)
}

//////////////////
//Global functions
//////////////////

func *(left: CGFloat, right: CGVector) -> CGVector {
    return CGVector(dx: left*right.dx, dy: left*right.dy)
}

func randomBetweenNumbers(_ firstNum: CGFloat, secondNum: CGFloat) -> CGFloat{
    return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
}

// test overloads
func print(_ point:CGPoint)
{
    print("(\(point.x),\(point.y))")
}
