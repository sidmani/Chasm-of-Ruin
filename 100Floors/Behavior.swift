//
//  Behavior.swift
//  100Floors
//
//  Created by Sid Mani on 3/19/16.
//
//

import Foundation

struct BehaviorConditionals {
    static let FixedValue = {(e:Enemy, params:[CGFloat]) -> Bool in
        //PARAMS
        //0 - (0 or 1) false or true
        return params[0] == 1
    }
    static let BasedOnStat = {(e:Enemy, params:[CGFloat]) -> Bool in
        //PARAMS
        //0 - (0 or 1) less than or greater than
        //1 - index of stat
        //2 - (0 to 1) percentage of total
        if (params[0] == 0) {
            return (e.currStats.getIndex(Int(params[1])) / e.baseStats.getIndex(Int(params[1]))) < params[2]
        }
        else {
            return (e.currStats.getIndex(Int(params[1])) / e.baseStats.getIndex(Int(params[1]))) > params[2]
        }
    }
    static let BasedOnCharacterStat = {(e:Enemy, params:[CGFloat]) -> Bool in
        //PARAMS
        //0 - (0 or 1) less than or greater than
        //1 - index of stat
        //2 - (0 to 1) percentage of total
        if (params[0] == 0) {
            return (thisCharacter.currStats.getIndex(Int(params[1])) / thisCharacter.baseStats.getIndex(Int(params[1]))) < params[2]
        }
        else {
            return (thisCharacter.currStats.getIndex(Int(params[1])) / thisCharacter.baseStats.getIndex(Int(params[1]))) > params[2]
        }
    }
    static let CharacterIsCloserThan = {(e:Enemy, params:[CGFloat]) -> Bool in
        //PARAMS
        //0 - maximum distance to player
        return (e.distanceToCharacter() < params[0])
    }
    static let CharacterIsFartherThan = {(e:Enemy, params:[CGFloat]) -> Bool in
        //PARAMS
        //0 - minimum distance to player
        return (e.distanceToCharacter() > params[0])
    }
    static func behaviorFromString(s:String) -> ((e:Enemy, params:[CGFloat]) -> Bool) {
        switch (s) {
        case "FixedValue":
            return BehaviorConditionals.FixedValue
        case "BasedOnStat":
            return BehaviorConditionals.BasedOnStat
        case "BasedOnCharacterStat":
            return BehaviorConditionals.BasedOnCharacterStat
        case "CharacterIsCloserThan":
            return BehaviorConditionals.CharacterIsCloserThan
        case "CharacterIsFartherThan":
            return BehaviorConditionals.CharacterIsFartherThan
        default:
            return {_,_ in return false}
        }
    }
    
}

struct BehaviorPriority {
    static let FixedValue = {(e:Enemy, params:[CGFloat]) -> Int in
        return Int(params[0])
    }
    static let ProportionalToStat = {(e:Enemy, params:[CGFloat]) -> Int in
        //PARAMS
        //0 - index of stat
        //1 - (-1 to 1) as stat decreases or increases, proportion
        if (e.baseStats.getIndex(Int(params[0])) == 0) {
            return 0
        }
        return Int((e.currStats.getIndex(Int(params[0])) / e.baseStats.getIndex(Int(params[0]))) * 10 * params[1])
    }
    static let ProportionalToCharacterStat = {(e:Enemy, params:[CGFloat]) -> Int in
        //PARAMS
        //0 - index of stat
        //1 - (-1 to 1) as stat decreases or increases, proportion
        return Int((thisCharacter.currStats.getIndex(Int(params[0])) / thisCharacter.baseStats.getIndex(Int(params[0]))) * 10 * params[1])
    }
    static func behaviorFromString(s:String) -> ((e:Enemy, params:[CGFloat]) -> Int){
        switch (s) {
        case "ProportionalToStat":
            return BehaviorPriority.ProportionalToStat
        case "ProportionalToCharacterStat":
            return BehaviorPriority.ProportionalToCharacterStat
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
    static let Orbit = {(e:Enemy, params:[CGFloat], timeSinceUpdate:Double) -> Bool in
        //PARAMS
        //0 - radius at which to orbit
        
        return true
    }
    
    ///////////////////////
    //////////ATK//////////
    ///////////////////////
    static let DoMainAtkAtInterval = {(e:Enemy, params:[CGFloat], timeSinceUpdate:Double) -> Bool in
        //PARAMS
        //0 - interval to attack in milliseconds
        //1 - accuracy of aim
        if (timeSinceUpdate > Double(params[0])) {
            var angle = e.angleToCharacter() //find angle to player
            if (params[1] != 1) {
                let error = randomBetweenNumbers(-(1-params[1])*3.14, secondNum: (1-params[1])*3.14) //add or subtract random error
                angle += error
            }
            e.fireProjectile(angle) //fire projectile
            return true
        }
        return false
    }
    
    static func behaviorFromString(s:String) -> ((e:Enemy, params:[CGFloat], timeSinceUpdate:Double) -> Bool) {
        switch (s) {
        case "Wander":
            return BehaviorExecutor.Wander
        case "DoMainAtkAtInterval":
            return BehaviorExecutor.DoMainAtkAtInterval
        case "Orbit":
            return BehaviorExecutor.Orbit
        default:
            return {_ in return true}
        }
    }
}