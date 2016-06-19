//
//  AI.swift
//  100Floors
//
//  Created by Sid Mani on 3/10/16.
//
//

import Foundation
import UIKit

class EnemyAI: Updatable{
    private static let transition_update_interval:Double = 1000
    private var elapsedSinceUpdate:Double = 0
    
    private unowned let parent:Enemy
    private var states:[String:State] = [:]
    private var currState:State
    
    init(parent:Enemy, startingState:String, withStates:[State]) {
        self.parent = parent
        for state in withStates {
            states[state.name] = state
        }
        currState = states[startingState]!
    }
    func changeState(to:String) {
        currState = states[to]!
    }
    func update(deltaT:Double) {
        if (elapsedSinceUpdate >= EnemyAI.transition_update_interval) {
            let out = currState.evaluateTransitions()
            if (out != "") {
                changeState(out)
            }
            elapsedSinceUpdate = 0
        }
        else {
            elapsedSinceUpdate += deltaT
        }
        currState.update(deltaT)
    }
}

class State:Updatable {
    private static let behavior_update_interval:Double = 500
    private var elapsedSinceUpdate:Double = 501
    
    private var behaviors:[Behavior]
    private var behaviorsToRun:[Behavior] = []
    private var transitions:[Transition]
    
    let name:String
    
    init(name:String, behaviors:[Behavior], transitions:[Transition]) {
        self.name = name
        self.behaviors = behaviors
        self.transitions = transitions
    }
    
    func update(deltaT: Double) {
        if (elapsedSinceUpdate >= State.behavior_update_interval) {
            behaviorsToRun = []
            for behavior in behaviors {
                behavior.updatePriority()
            }
            behaviors.sortInPlace({$0.priority > $1.priority})
            var selectedIDs: [Behavior.BehaviorIDType] = []
            for behavior in behaviors {
                if (behavior.getConditional() && !selectedIDs.contains(behavior.idType)) {
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
    
    func evaluateTransitions() -> String {
        for transition in transitions {
            let out = transition.evaluate()
            if (out != "") {
                return out
            }
        }
        return ""
    }
}



