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
        ///MENU
        "DisplayEnemy":EnemyDictionary.DisplayEnemy,
        ///Tutorial
        "t0":EnemyDictionary.TargetDummy,
        "t1":EnemyDictionary.SlimeSquareE,
        "t2":EnemyDictionary.EyeballA,
        ///Sunlit Caverns
        "sc3":EnemyDictionary.BugB,
        "sc4":EnemyDictionary.DuckA,
        "sc9":EnemyDictionary.OrbA,
        "sc0":EnemyDictionary.AirA,
        "sc1":EnemyDictionary.BallA,
        "sc2":EnemyDictionary.BrainC,
        "sc5":EnemyDictionary.EarthA,
        "sc6":EnemyDictionary.FactoryA,
        "sc7":EnemyDictionary.GolemA,
        "sc8":EnemyDictionary.MonolithA,
        //Ancient Realm
        "ar0":EnemyDictionary.BallD,
        "ar1":EnemyDictionary.BatH,
        "ar2":EnemyDictionary.BatR,
        "ar3":EnemyDictionary.BrainE,
        "ar4":EnemyDictionary.DyeD,
        "ar5":EnemyDictionary.FrogC,
        "ar6":EnemyDictionary.GhastB,
        "ar7":EnemyDictionary.HeadC,
        "ar8":EnemyDictionary.KlackonB,
        "ar9":EnemyDictionary.MonolithD,
        //Darkened Hall
        "dh0":EnemyDictionary.BatB,
        "dh1":EnemyDictionary.BatN,
        "dh2":EnemyDictionary.BeardB,
        "dh3":EnemyDictionary.CatA,
        "dh4":EnemyDictionary.ChestA,
        "dh5":EnemyDictionary.CloudA,
        "dh6":EnemyDictionary.CrabE,
        "dh7":EnemyDictionary.DiscA,
        "dh8":EnemyDictionary.DyeB,
        "dh9":EnemyDictionary.EyeballB,
        "dh10":EnemyDictionary.GhastA
    ]
    //MENU
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
    //TUTORIAL
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
                    FireProjectile(error: 1, rateOfFire: 1500, projectileTexture: "projectile69", projectileSpeed: 60, range: 50),
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
                    RunAnimationSequence(animationName: "default", priority: 5),
                    RunSimultaneously(behaviorsToRun: [
                        RunAnimationSequence(animationName: "attack"),
                        FireProjectilesAtAngularRange(numProjectiles: 3, angularRange: 1, direction: .TowardPlayer, projectileTexture: "projectile51", rateOfFire: 1000, projectileSpeed: 35, range: 50)
                        ], useConditionalOfIndex: 1, idType: .Animation, priority: 10),
                    Wander(triggerOutsideOfDistance: 0, priority: 5)
                ],
                transitions: [
                    PlayerFartherThan(dest: "Idle", distance: 50)
                ])
            ])
    }
    
}
