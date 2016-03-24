//
//  AI.swift
//  100Floors
//
//  Created by Sid Mani on 3/10/16.
//
//

import Foundation
class EnemyAI: Updatable{
    private let behavior_update_interval:Double = 500
    private var parent:Enemy
    private var behaviors:[Behavior] = []
    private var behaviorsToRun:[Behavior] = []
    private var elapsedSinceUpdate:Double = 0
    init(parent:Enemy, withBehaviors:[AEXMLElement]) {
        self.parent = parent
        for element in withBehaviors {
            behaviors.append(Behavior(withID: element.stringValue, asChildOf: parent))
        }
        behaviors.sortInPlace({$0.priority > $1.priority})
    }
    
    func update(deltaT:Double) {
        if (elapsedSinceUpdate >= behavior_update_interval) {
            behaviorsToRun = []
            for behavior in behaviors {
                behavior.updatePriority()
            }
            behaviors.sortInPlace({$0.priority > $1.priority})
            var selectedIDs: [Int] = []
            for behavior in behaviors {
                if (!selectedIDs.contains(behavior.idType)) {
                    behaviorsToRun.append(behavior)
                    selectedIDs.append(behavior.idType)
                }
            }
            elapsedSinceUpdate = 0
        }
        else {
            elapsedSinceUpdate += deltaT
        }
        for behavior in behaviorsToRun {
            behavior.update(deltaT)
        }
    }
}

class Behavior: Updatable {
    var idType:Int
    var priority:Int = 0
    
    private var conditional: (e:Enemy, params:[CGFloat]) -> Bool
    private var conditionalParams:[CGFloat] = []
    
    private var executeFunc: (e:Enemy, params:[CGFloat], timeSinceUpdate:Double) -> Bool
    private var executeParams:[CGFloat] = []

    private var calcPriority: (e:Enemy, params:[CGFloat]) -> Int
    private var priorityParams:[CGFloat] = []
    
    private var parent:Enemy
    private var elapsedSinceUpdate:Double = 0
    
    init(fromElement: AEXMLElement, asChildOf:Enemy) {
        parent = asChildOf
        conditional = BehaviorConditionals.behaviorFromString(fromElement["conditional"].stringValue)
        executeFunc = BehaviorExecutor.behaviorFromString(fromElement["execute"].stringValue)
        calcPriority = BehaviorPriority.behaviorFromString(fromElement["priority"].stringValue)
        
        idType = fromElement["idtype"].intValue
        for param in fromElement["conditional-params"]["param"].all! {
            conditionalParams.append(CGFloat(param.doubleValue))
        }
        for param in fromElement["execute-params"]["param"].all! {
            executeParams.append(CGFloat(param.doubleValue))
        }
        for param in fromElement["priority-params"]["param"].all! {
            priorityParams.append(CGFloat(param.doubleValue))
        }
    }
    convenience init (withID: String, asChildOf:Enemy) {
        if let behaviors = behaviorXML?.root["behaviors"]["behavior"].allWithAttributes(["id":withID]) {
            if (behaviors.count != 1) {
                fatalError("Behavior ID error")
            }
            else {
                self.init(fromElement: behaviors[0], asChildOf: asChildOf)
            }
        }
        else {
            fatalError("Behavior Not Found")
        }
    }
    func update(deltaT: Double) {
        if (conditional(e: parent, params: conditionalParams)) {
            if (executeFunc(e: parent, params: executeParams, timeSinceUpdate: elapsedSinceUpdate)) {
                elapsedSinceUpdate = 0
            }
            else {
                elapsedSinceUpdate += deltaT
            }
        }
        else {
            elapsedSinceUpdate = 0
        }
    }

    
    func updatePriority() {
        priority = calcPriority(e: parent, params: priorityParams)
    }
    
}

