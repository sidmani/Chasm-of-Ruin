//
//  AI.swift
//  100Floors
//
//  Created by Sid Mani on 3/10/16.
//
//

import Foundation
class EnemyAI: Updatable{
    var parent:Enemy
    var behaviors:[Behavior] = []
    private var currentBehavior:Behavior?
    init(parent:Enemy, withBehaviors:[AEXMLElement]) {
        self.parent = parent
        for element in withBehaviors {
            behaviors.append(Behavior(fromElement: element, asChildOf: self))
        }
        behaviors.sortInPlace({$0.priority > $1.priority})
    }
    func update(deltaT:Double) {
        for behavior in behaviors {
            if (behavior.evaluateConditional(parent)) {
                setBehavior(behavior)
            }
        }
        currentBehavior?.update(deltaT)
    }
    func setBehavior(to:Behavior) {
        currentBehavior = to
    }
}
class Behavior:Updatable {
    var priority:Int
    private var conditional: (e:Enemy, params:[CGFloat]) -> Bool
    private var params:[CGFloat] = []
    private var parentAI:EnemyAI
    
    init(fromElement: AEXMLElement, asChildOf:EnemyAI) {
        parentAI = asChildOf
        conditional = BehaviorConditionals.behaviorFromString(fromElement["conditional"].stringValue)
        priority = fromElement["priority"].intValue
        for param in fromElement["params"].all! {
            let val = param.attributes["val"]!
            params.append(CGFloat(NSNumberFormatter().numberFromString(val)!.doubleValue))
        }
    }
    func update(deltaT: Double) {
        
    }
    func evaluateConditional(forEnemy:Enemy) -> Bool {
        return conditional(e: forEnemy, params: params)
    }
    
}

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
        return (hypot(e.position.x - thisCharacter.position.x, e.position.y - thisCharacter.position.y) < params[0])
    }
    static let PlayerIsFartherThan = {(e:Enemy, params:[CGFloat]) -> Bool in
        //PARAMS
        //0 - minimum distance to player
        return (hypot(e.position.x - thisCharacter.position.x, e.position.y - thisCharacter.position.y) > params[0])
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