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

struct BehaviorExecutor {
    static let Wander = {(e:Enemy) in
        print("Wandering")
    }
    static func executorFromString(s:String) -> ((Enemy) -> ()) {
        switch (s) {
        case "Wander":
            return BehaviorExecutor.Wander
        default:
            return {_ in return}
        }
    }
}