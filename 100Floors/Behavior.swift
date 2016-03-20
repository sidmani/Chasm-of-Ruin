//
//  Behavior.swift
//  100Floors
//
//  Created by Sid Mani on 3/19/16.
//
//

import Foundation

struct BehaviorConditionals {
    static let HealthIsLessThan = {(e:Enemy, params:[CGFloat]) -> Bool in
        //PARAMS
        //0 - fraction of health
        return (e.currStats.health < e.baseStats.health * params[0])
    }
    static let HealthIsMoreThan = {(e:Enemy, params:[CGFloat]) -> Bool in
        //PARAMS
        //0 - fraction of health
        return (e.currStats.health > e.baseStats.health * params[0])
    }
    static let PlayerIsCloserThan = {(e:Enemy, params:[CGFloat]) -> Bool in
        //PARAMS
        //0 - maximum distance to player
        return (e.distanceToPlayer() < params[0])
    }
    static let PlayerIsFartherThan = {(e:Enemy, params:[CGFloat]) -> Bool in
        //PARAMS
        //0 - minimum distance to player
        return (e.distanceToPlayer() > params[0])
    }
    static func behaviorFromString(s:String) -> ((e:Enemy, params:[CGFloat]) -> Bool) {
        switch (s) {
        case "HealthIsLessThan":
            return BehaviorConditionals.HealthIsLessThan
        case "HealthIsMoreThan":
            return BehaviorConditionals.HealthIsMoreThan
        case "PlayerIsCloserThan":
            return BehaviorConditionals.PlayerIsCloserThan
        case "PlayerIsFartherThan":
            return BehaviorConditionals.PlayerIsFartherThan
        default:
            return {_,_ in return false}
        }
    }
    
}

struct BehaviorPriority {
    static let ProportionalToStat = {(e:Enemy, params:[CGFloat]) -> Int in
        //PARAMS
        //0 - index of stat
        //1 - (-1 to 1) as stat decreases or increases
        //2 - (-1 to 1) ignore if stat is below/above this fraction of base
        return 0
    }
    static func behaviorFromString(s:String) -> ((e:Enemy, params:[CGFloat]) -> Int){
        switch (s) {
        case "ProportionalToStat":
            return BehaviorPriority.ProportionalToStat
        default:
            return {_,_ in return -1}
        }
    }
}
struct BehaviorExecutor {
    static let Wander = {(e:Enemy, params:[CGFloat], timeSinceUpdate:Double) -> Bool in
        print("Wandering")
        return true
    }
    static let DoMainAtkAtInterval = {(e:Enemy, params:[CGFloat], timeSinceUpdate:Double) -> Bool in
        //PARAMS
        //0 - interval to attack in milliseconds
        //1 - random accuracy of aim in radians
        if (timeSinceUpdate > Double(params[0])) {
            //find angle to player
            //add/subtract random error
            //fire projectile
            return true
        }
        return false
    }
    
    static func executorFromString(s:String) -> ((e:Enemy, params:[CGFloat], timeSinceUpdate:Double) -> Bool) {
        switch (s) {
        case "Wander":
            return BehaviorExecutor.Wander
        case "DoMainAtkAtInterval":
            return BehaviorExecutor.DoMainAtkAtInterval
        default:
            return {_ in return false}
        }
    }
}