//
//  AI.swift
//  100Floors
//
//  Created by Sid Mani on 3/10/16.
//
//

import Foundation
class EnemyAI: Updatable{
    private var parent:Enemy
    private var behaviors:[Behavior] = []
    private var behaviorsToRun:[Behavior] = []
    private var elapsedSinceUpdate:Double = 0
    
    init(parent:Enemy, withBehaviors:[AEXMLElement]) {
        self.parent = parent
        for element in withBehaviors {
            behaviors.append(Behavior(fromElement: element, asChildOf: parent))
        }
        behaviors.sortInPlace({$0.priority > $1.priority})
    }
    
    func update(deltaT:Double) {
        if (elapsedSinceUpdate > 500) {
            var selectedIDs: [Int] = []
            for behavior in behaviors {
                if (behavior.evaluateConditional() && !selectedIDs.contains(behavior.idType)) {
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
class Behavior:Updatable {
    var idType:Int

    var priority:Int {
        return calcPriority(e: parent, params: priorityParams)
    }
    
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
        executeFunc = BehaviorExecutor.executorFromString(fromElement["execute"].stringValue)
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
    func update(deltaT: Double) {
        if (executeFunc(e: parent, params: executeParams, timeSinceUpdate: elapsedSinceUpdate)) {
            elapsedSinceUpdate = 0
        }
        else {
            elapsedSinceUpdate += deltaT
        }
    }
    
    func evaluateConditional() -> Bool {
        return conditional(e: parent, params: conditionalParams)
    }
    
}

