//
//  TutorialEnemies.swift
//  100Floors
//
//  Created by Sid Mani on 6/14/16.
//
//

import Foundation
struct EnemyDictionary {
    static let EnemyDictionary: [String:(parent:Enemy) -> EnemyAI] = [
        "Basic Enemy":BasicEnemy
    ]
    private static let BasicEnemy = {(parent:Enemy) -> EnemyAI in
       return EnemyAI(parent:parent, startingState:"Idle", withStates: [
        State(name: "Idle",
            behaviors: [
                MaintainDistance(parent: parent, distanceToMaintain: 10, triggerDistance: 20, updateRate: 50, priority: 5)
            ],
            transitions: [
                
            ])
        ])
    }
}