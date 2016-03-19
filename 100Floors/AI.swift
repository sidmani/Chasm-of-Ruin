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
    private var currentBehavior:Behavior?
    
    init(parent:Enemy, withBehaviors:[AEXMLElement]) {
        self.parent = parent
        for element in withBehaviors {
            behaviors.append(Behavior(fromElement: element, asChildOf: parent))
        }
        behaviors.sortInPlace({$0.priority > $1.priority})
    }
    
    func update(deltaT:Double) {
        currentBehavior?.update(deltaT)
        for behavior in behaviors {
            if (behavior.evaluateConditional()) {
                setBehavior(behavior)
                return
            }
        }
        setBehavior(nil)
    }
    
    func setBehavior(to:Behavior?) {
        currentBehavior = to
    }
}
class Behavior:Updatable {
    var priority:Int
    private var conditional: (e:Enemy, params:[CGFloat]) -> Bool
    private var executeFunc: (Enemy) -> ()
    private var params:[CGFloat] = []
    private var parent:Enemy
    
    init(fromElement: AEXMLElement, asChildOf:Enemy) {
        parent = asChildOf
        conditional = BehaviorConditionals.behaviorFromString(fromElement["conditional"].stringValue)
        executeFunc = BehaviorExecutor.executorFromString(fromElement["execute"].stringValue)
        priority = fromElement["priority"].intValue
        for param in fromElement["params"]["param"].all! {
            params.append(CGFloat(param.doubleValue))
        }
    }
    func update(deltaT: Double) {
        executeFunc(parent)
    }
    
    func evaluateConditional() -> Bool {
        return conditional(e: parent, params: params)
    }
    
}

