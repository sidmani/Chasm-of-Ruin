//
//  TutorialEnemies.swift
//  100Floors
//
//  Created by Sid Mani on 6/14/16.
//
//

import Foundation
import SpriteKit

struct EnemyDictionary {
    static let EnemyDictionary: [String:(parent:Enemy) -> EnemyAI] = [
        "e0":TargetDummy,
        "e1":SlimeSquareE
    ]
    private static let TargetDummy = {(parent:Enemy) -> EnemyAI in
       return EnemyAI(parent:parent, startingState:"default", withStates: [
            State(name: "default",
                behaviors: [
                    RunAnimationSequence(parent: parent, animationName: "default", frameDuration: 0.125, updateRate:300, priority: 5)
                ],
                transitions: []),
        ])
    }
    private static let SlimeSquareE = {(parent:Enemy) -> EnemyAI in
        return EnemyAI(parent:parent, startingState:"Idle", withStates: [
            State(name:"Idle",
                behaviors: [
                    RunAnimationSequence(parent: parent, animationName: "default", frameDuration: 0.125, updateRate: 200, priority: 5),
                    Wander(parent: parent, triggerOutsideOfDistance: 0, updateRate: 400, priority: 5)
                ],
                transitions: [
                    PlayerCloserThan(parent: parent, dest: "Engage", distance: 50)
                ]
            ),
            State(name: "Engage",
                behaviors: [
                    RunAnimationSequence(parent: parent, animationName: "default", frameDuration: 0.125, updateRate: 200, priority: 5),
                    MainAttack(parent: parent, error: 0.5, triggerDistance: 30, rateOfFire: 200, projectileTexture: defaultLevelHandler.getCurrentLevelAtlas().textureNamed("texture-test"), projectileSpeed: 60, range: 40, priority: 5),
                    MaintainDistance(parent: parent, distanceToMaintain: 20, triggerDistance: 50, updateRate: 300, priority: 5),
                    Circle(parent: parent, triggerInsideOfDistance: 25, updateRate: 100, priority: 10)
                ],
                transitions: [
                    PlayerFartherThan(parent: parent, dest: "Idle", distance: 50),
                    HPLessThan(parent: parent, dest: "Flee", hpLevel: 0.2)
                ]),
            State(name: "Flee",
                behaviors: [
                    RunAnimationSequence(parent: parent, animationName: "default", frameDuration: 0.125, updateRate: 200, priority: 5),
                    Flee(parent: parent, finalDist: 40, updateRate: 200, priority: 5),
                    Wander(parent: parent, triggerOutsideOfDistance: 40, updateRate: 400, priority: 4)
                ],
                transitions: [])
        ])
    }
}
