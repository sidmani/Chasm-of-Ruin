//
//  AncientRealmEnemies.swift
//  Chasm Of Ruin
//
//  Created by Sid Mani on 7/29/16.
//
//

import Foundation

extension EnemyDictionary {
    static func BallD(parent:Enemy) -> EnemyAI {
        return EnemyAI(parent:parent, startingState:"idle", withStates: [
            State(name: "idle",
                behaviors: [
                    RunAnimationSequence(animationName: "default"),
                ],
                transitions: [
                    PlayerCloserThan(dest: "active", distance: 75)
                ]),
            State(name: "active", behaviors: [
                RunAnimationSequence(animationName: "default", priority:5),
                RunSimultaneously(behaviorsToRun: [
                    FireProjectilesInSpiral(numStreams: 5, offsetStep: 0.1, projectileTexture: "projectile9", rateOfFire: 500, projectileSpeed: 50, range: 75),
                    RunAnimationSequence(animationName: "attack")
                    ], useConditionalOfIndex: 0, idType:.Animation, priority:10),
                MaintainDistance(distanceToMaintain: 20, triggerDistance: 50, priority: 5)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75)
                ])
            ])
    }
    static func BatH(parent:Enemy) -> EnemyAI {
        return EnemyAI(parent:parent, startingState:"idle", withStates: [
            State(name: "idle",
                behaviors: [
                    RunAnimationSequence(animationName: "default"),
                    Wander(triggerOutsideOfDistance: 0, priority: 5),
                ],
                transitions: [
                    PlayerCloserThan(dest: "active", distance: 75)
                ]),
            State(name: "active", behaviors: [
                RunAnimationSequence(animationName: "default"),
                FireProjectile(error: 0.5, rateOfFire: 300, projectileTexture: "projectile9", projectileSpeed: 70, range: 30),
                MaintainDistance(distanceToMaintain: 20, triggerDistance: 50, priority: 5),
                Circle(triggerInsideOfDistance: 25, priority: 10)
                ], runOnStruckMapBoundary: [
                    Wander(triggerOutsideOfDistance: 0, priority: 15)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75)
                ])
            ])
    }
    static func BatR(parent:Enemy) -> EnemyAI {
        return EnemyAI(parent:parent, startingState:"idle", withStates: [
            State(name: "idle",
                behaviors: [
                    RunAnimationSequence(animationName: "default"),
                ],
                transitions: [
                    PlayerCloserThan(dest: "active", distance: 75)
                ]),
            State(name: "active", behaviors: [
                RunAnimationSequence(animationName: "default"),
                RunSimultaneously(behaviorsToRun: [
                    FireProjectilesInSpiral(numStreams: 3, offsetStep: 0.2, projectileTexture: "projectile9", rateOfFire: 200, projectileSpeed: 60, range: 75),
                    RunAnimationSequence(animationName: "attack")
                    ], useConditionalOfIndex: 0),
                Wander(triggerOutsideOfDistance: 40, priority: 5),
                Circle(triggerInsideOfDistance: 40, priority: 10)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75)
                ])
            ])
    }
    
    static func BrainE(parent:Enemy) -> EnemyAI {
        return EnemyAI(parent:parent, startingState:"idle", withStates: [
            State(name: "idle",
                behaviors: [
                    RunAnimationSequence(animationName: "default"),
                    Wander(triggerOutsideOfDistance: 0, priority: 10)
                ],
                transitions: [
                    PlayerCloserThan(dest: "active", distance: 75)
                ]),
            State(name: "active", behaviors: [
                RunAnimationSequence(animationName: "default"),
                FireProjectilesAtAngularRange(numProjectiles: 5, angularRange: 2, direction: .TowardPlayer, projectileTexture: "projectile9", rateOfFire: 1000, projectileSpeed: 50, range: 50),
                MaintainDistance(distanceToMaintain: 15, triggerDistance: 50, priority: 5),
                Wander(triggerOutsideOfDistance: 0, priority: 2)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75)
                ])
            ])
    }
    
    static func FrogC(parent:Enemy) -> EnemyAI {
        return EnemyAI(parent:parent, startingState:"idle", withStates: [
            State(name: "idle",
                behaviors: [
                    RunAnimationSequence(animationName: "default"),
                    Wander(triggerOutsideOfDistance: 0, priority: 10)
                ],
                transitions: [
                    PlayerCloserThan(dest: "active", distance: 75)
                ]),
            State(name: "active", behaviors: [
                RunAnimationSequence(animationName: "default"),
                FireNProjectilesAtEqualIntervals(numProjectiles: 10, projectileTexture: "projectile9", rateOfFire: 500, projectileSpeed: 80, range: 60),
                Wander(triggerOutsideOfDistance: 0, priority: 10)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75)
                ])
            ])
    }
    
    static func KlackonB(parent:Enemy) -> EnemyAI {
        return EnemyAI(parent:parent, startingState:"idle", withStates: [
            State(name: "idle",
                behaviors: [
                    RunAnimationSequence(animationName: "default"),
                    Wander(triggerOutsideOfDistance: 0, priority: 10)
                ],
                transitions: [
                    PlayerCloserThan(dest: "active", distance: 75)
                ]),
            State(name: "active", behaviors: [
                RunAnimationSequence(animationName: "default"),
                FireProjectilesAtAngularRange(numProjectiles: 3, angularRange: 1, direction: .Random, projectileTexture: "projectile9", rateOfFire: 1000, projectileSpeed: 50, range: 70),
                FireNProjectilesAtEqualIntervals(numProjectiles: 10, projectileTexture: "projectile9", rateOfFire: 500, projectileSpeed: 40, range: 70),
                MaintainDistance(distanceToMaintain: 15, triggerDistance: 50, priority: 5),
                Circle(triggerInsideOfDistance: 15, priority: 10)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75)
                ])
            ])
    }
    ///
    static func GhastB(parent:Enemy) -> EnemyAI {
        return EnemyAI(parent:parent, startingState:"idle", withStates: [
            State(name: "idle",
                behaviors: [
                    RunAnimationSequence(animationName: "default"),
                    Wander(triggerOutsideOfDistance: 0, priority: 10)
                ],
                transitions: [
                    PlayerCloserThan(dest: "active", distance: 75)
                ]),
            State(name: "active", behaviors: [
                RunAnimationSequence(animationName: "default"),
                FireNProjectilesAtEqualIntervals(numProjectiles: 5, projectileTexture: "projectile9", rateOfFire: 250, projectileSpeed: 80, range: 60),
                MaintainDistance(distanceToMaintain: 15, triggerDistance: 50, priority: 5),
                Circle(triggerInsideOfDistance: 15, priority: 10)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75)
                ])
            ])
    }
    
    static func MonolithD(parent:Enemy) -> EnemyAI {
        return EnemyAI(parent:parent, startingState:"idle", withStates: [
            State(name: "idle",
                behaviors: [
                    RunAnimationSequence(animationName: "default"),
                    Wander(triggerOutsideOfDistance: 0, priority: 10)
                ],
                transitions: [
                    PlayerCloserThan(dest: "active", distance: 75)
                ]),
            State(name: "active", behaviors: [
                RunAnimationSequence(animationName: "default"),
                FireNProjectilesAtEqualIntervals(numProjectiles: 5, projectileTexture: "projectile9", rateOfFire: 250, projectileSpeed: 80, range: 60),
                MaintainDistance(distanceToMaintain: 15, triggerDistance: 50, priority: 5),
                Circle(triggerInsideOfDistance: 15, priority: 10)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75)
                ])
            ])
    }
    
    static func DyeD(parent:Enemy) -> EnemyAI {
        return EnemyAI(parent:parent, startingState:"idle", withStates: [
            State(name: "idle",
                behaviors: [
                    RunAnimationSequence(animationName: "default"),
                    Wander(triggerOutsideOfDistance: 0, priority: 10)
                ],
                transitions: [
                    PlayerCloserThan(dest: "active", distance: 75)
                ]),
            State(name: "active", behaviors: [
                RunAnimationSequence(animationName: "default"),
                FireNProjectilesAtEqualIntervals(numProjectiles: 5, projectileTexture: "projectile9", rateOfFire: 250, projectileSpeed: 80, range: 60),
                MaintainDistance(distanceToMaintain: 15, triggerDistance: 50, priority: 5),
                Circle(triggerInsideOfDistance: 15, priority: 10)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75)
                ])
            ])
    }

    static func HeadC(parent:Enemy) -> EnemyAI {
        return EnemyAI(parent:parent, startingState:"idle", withStates: [
            State(name: "idle",
                behaviors: [
                    RunAnimationSequence(animationName: "default"),
                    Wander(triggerOutsideOfDistance: 0, priority: 10)
                ],
                transitions: [
                    PlayerCloserThan(dest: "active", distance: 75)
                ]),
            State(name: "active", behaviors: [
                RunAnimationSequence(animationName: "default"),
                FireNProjectilesAtEqualIntervals(numProjectiles: 5, projectileTexture: "projectile9", rateOfFire: 250, projectileSpeed: 80, range: 60),
                MaintainDistance(distanceToMaintain: 15, triggerDistance: 50, priority: 5),
                Circle(triggerInsideOfDistance: 15, priority: 10)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75)
                ])
            ])
    }

}