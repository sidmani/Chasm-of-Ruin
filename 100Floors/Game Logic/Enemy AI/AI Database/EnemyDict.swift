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
    static let Dict: [String:(parent:Enemy) -> EnemyAI] = [
        "e0":EnemyDictionary.TargetDummy,
        "e1":EnemyDictionary.SlimeSquareE
    ]
    static func TargetDummy(parent:Enemy) -> EnemyAI {
       return EnemyAI(parent:parent, startingState:"default", withStates: [
            State(name: "default",
                behaviors: [
                    RunAnimationSequence(parent: parent, animationName: "default", frameDuration: 0.125, updateRate:300, priority: 5)
                ],
                transitions: []),
        ])
    }
    static func SlimeSquareE(parent:Enemy) -> EnemyAI {
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
                   // FireProjectile(parent: parent, error: 0.5, rateOfFire: 400, projectileTexture: "ProjectileB5", projectileSpeed: 60, range: 40),
                   // FireNProjectilesAtEqualIntervals(parent: parent, numProjectiles: 10, projectileTexture: "ProjectileA5", rateOfFire: 500, projectileSpeed: 20, range: 50),
                    FireProjectilesAtAngularRange(parent: parent, numProjectiles: 5, angularRange: 1, direction: .TowardPlayer, projectileTexture: "ProjectileB4", rateOfFire: 400, projectileSpeed: 35, range: 50),
                    FireProjectilesInSpiral(parent: parent, numStreams: 1, offsetStep: 0.2, projectileTexture: "ProjectileA5", rateOfFire: 100, projectileSpeed: 30, range: 60),
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
