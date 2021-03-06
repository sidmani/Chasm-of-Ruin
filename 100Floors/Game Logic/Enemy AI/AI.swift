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
            state.setParent(parent)
        }
        currState = states[startingState]!
    }
    
    func changeState(_ to:String) {
        currState.endState()
        currState = states[to]!
        currState.beginState()
    }
    
    func struckMapBoundary(_ point:CGPoint) {
        currState.struckMapBoundary(point)
    }
    
    func update(_ deltaT:Double) {
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
    
    private let runOnBeginState:[Behavior]
    private let runOnEndState:[Behavior]
    
    private let runOnStruckMapBoundary:[Behavior]
    
    private var behaviors:[Behavior]
    private var behaviorsToRun:[Behavior] = []
    private let transitions:[Transition]
    
    let name:String
    
    init(name:String, runOnBeginState:[Behavior] = [], behaviors:[Behavior], runOnEndState:[Behavior] = [], runOnStruckMapBoundary:[Behavior] = [], transitions:[Transition]) {
        self.name = name
        self.behaviors = behaviors
        self.transitions = transitions
        self.runOnEndState = runOnEndState
        self.runOnBeginState = runOnBeginState
        self.runOnStruckMapBoundary = runOnStruckMapBoundary
        self.behaviors.sort(by: {$0.priority > $1.priority})
    }
    
    func update(_ deltaT: Double) {
        if (elapsedSinceUpdate >= State.behavior_update_interval) {
            behaviorsToRun = []
            var selectedIDs: [Behavior.BehaviorIDType] = []
            for behavior in behaviors {
                if (behavior.getConditional() && (behavior.idType == .nonexclusive || !selectedIDs.contains(behavior.idType))) {
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
    
    func setParent(_ to:Enemy) {
        for behavior in runOnBeginState {
            behavior.setParent(to)
        }
        for behavior in behaviors {
            behavior.setParent(to)
        }
        for behavior in runOnEndState {
            behavior.setParent(to)
        }
        for transition in transitions {
            transition.setParent(to)
        }
        for behavior in runOnStruckMapBoundary {
            behavior.setParent(to)
        }
    }
    
    func beginState() {
        for behavior in runOnBeginState {
            behavior.executeBehavior(0)
        }
    }
    
    func endState() {
        for behavior in runOnEndState {
            behavior.executeBehavior(0)
        }
    }
    
    func struckMapBoundary(_ point:CGPoint) {
        for behavior in runOnStruckMapBoundary {
            if let b = behavior as? FleeFromPoint {
                b.point = point
            }
            behavior.executeBehavior(0)
        }
    }
}



