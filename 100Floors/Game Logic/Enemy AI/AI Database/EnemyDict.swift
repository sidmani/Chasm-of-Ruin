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
        "t0":EnemyDictionary.TargetDummy,
        "t1":EnemyDictionary.SlimeSquareE,
        "t2":EnemyDictionary.EyeballA,
        "DisplayEnemy":EnemyDictionary.DisplayEnemy
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
                    FireProjectilesAtAngularRange(numProjectiles: 5, angularRange: 1, direction: .TowardPlayer, projectileTexture: "projectile9", rateOfFire: 400, projectileSpeed: 60, range: 50),
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
    
    static func EyeballA(parent:Enemy) -> EnemyAI {
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
                    RunAnimationSequence(animationName: "attack"),
                    RunSimultaneously(behaviorsToRun: [
                        RunAnimationSequence(animationName: "attack"),
                        FireProjectilesAtAngularRange(numProjectiles: 5, angularRange: 1, direction: .TowardPlayer, projectileTexture: "projectile9", rateOfFire: 400, projectileSpeed: 35, range: 50)
                    ], useConditionalOfIndex: 1),
                    FireProjectilesInSpiral(numStreams: 1, offsetStep: 0.2, projectileTexture: "projectile11", rateOfFire: 100, projectileSpeed: 30, range: 60),
                    Wander(triggerOutsideOfDistance: 0, priority: 5)
                ],
                transitions: [
                    PlayerFartherThan(dest: "Idle", distance: 50)
                ])
            ])
    }
    
    static func DisplayEnemy(parent:Enemy) -> EnemyAI {
        return EnemyAI(parent:parent, startingState:"default", withStates: [
            State(name: "default",
                behaviors: [
                    RunAnimationSequence(animationName: "default"),
                    Wander(triggerOutsideOfDistance: 0, priority: 5),
                    MoveToTouch(distanceToMaintain: 20, priority: 10)
                ],
                transitions: []),
            ])
    }
}
