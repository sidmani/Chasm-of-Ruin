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
                    RunAnimationSequence(animationName: "default")
                ],
                transitions: []),
        ])
    }
    static func SlimeSquareE(parent:Enemy) -> EnemyAI {
        return EnemyAI(parent:parent, startingState:"Idle", withStates: [
            State(name:"Idle",
                behaviors: [
                    RunAnimationSequence(animationName: "default"),
                    Wander(triggerOutsideOfDistance: 0, priority: 5)
                ],
                transitions: [
                    PlayerCloserThan(dest: "Engage", distance: 50)
                ]
            ),
            State(name: "Engage",
                behaviors: [
                    RunAnimationSequence(animationName: "default"),
                   // FireProjectile(parent: parent, error: 0.5, rateOfFire: 400, projectileTexture: "ProjectileB5", projectileSpeed: 60, range: 40),
                   // FireNProjectilesAtEqualIntervals(parent: parent, numProjectiles: 10, projectileTexture: "ProjectileA5", rateOfFire: 500, projectileSpeed: 20, range: 50),
                    FireProjectilesAtAngularRange(numProjectiles: 5, angularRange: 1, direction: .TowardPlayer, projectileTexture: "ProjectileB4", rateOfFire: 400, projectileSpeed: 35, range: 50),
                    FireProjectilesInSpiral(numStreams: 1, offsetStep: 0.2, projectileTexture: "ProjectileA5", rateOfFire: 100, projectileSpeed: 30, range: 60),
                    MaintainDistance(distanceToMaintain: 20, triggerDistance: 50, priority: 5),
                    Circle(triggerInsideOfDistance: 25, priority: 10)
                ],
                transitions: [
                    PlayerFartherThan(dest: "Idle", distance: 50),
                    HPLessThan(dest: "Flee", hpLevel: 0.2)
                ]),
            State(name: "Flee",
                behaviors: [
                    RunAnimationSequence(animationName: "default"),
                    Flee(finalDist: 40, priority: 5),
                    Wander(triggerOutsideOfDistance: 40, priority: 4)
                ],
                transitions: [])
        ])
    }
}
