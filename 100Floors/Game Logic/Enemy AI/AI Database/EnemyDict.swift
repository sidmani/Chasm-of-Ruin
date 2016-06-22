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
                Wander(parent: parent, triggerOutsideOfDistance: 20, updateRate: 200, priority: 5),
                Circle(parent: parent, triggerInsideOfDistance: 20, updateRate: 50, priority: 5),
                MainAttack(parent: parent, error: 1, triggerDistance:20, rateOfFire: 200, priority: 5)
            ],
            transitions: [
                HPLessThan(parent: parent, dest: "Fleeing", hpLevel: 0.5)
            ]),
        State(name: "Fleeing",
            behaviors: [
                Flee(parent: parent, finalDist: 50, updateRate: 100, priority: 10)
            ],
            transitions: [
                PlayerFartherThan(parent: parent, dest: "Idle", distance: 45)
            ])
        ])
    }
}