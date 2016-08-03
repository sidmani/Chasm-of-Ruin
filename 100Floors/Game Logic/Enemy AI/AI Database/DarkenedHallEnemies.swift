//
//  DarkenedHallEnemies.swift
//  Chasm Of Ruin
//
//  Created by Sid Mani on 7/29/16.
//
//

import Foundation

extension EnemyDictionary {
    static func BatB(_ parent:Enemy) -> EnemyAI {
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
                FireProjectile(error: 0.5, rateOfFire: 300, projectileTexture: "projectile32", projectileSpeed: 70, range: 30),
                MaintainDistance(distanceToMaintain: 20, triggerDistance: 50, priority: 5),
                Circle(triggerInsideOfDistance: 25, priority: 10)
                ], runOnStruckMapBoundary: [
                    Wander(triggerOutsideOfDistance: 0, priority: 15)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75)
                ])
            ])
    }
    
    static func BatN(_ parent:Enemy) -> EnemyAI {
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
                FireProjectile(error: 0.5, rateOfFire: 300, projectileTexture: "projectile41", projectileSpeed: 70, range: 30),
                MaintainDistance(distanceToMaintain: 20, triggerDistance: 50, priority: 5),
                Circle(triggerInsideOfDistance: 25, priority: 10)
                ], runOnStruckMapBoundary: [
                    Wander(triggerOutsideOfDistance: 0, priority: 15)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75)
                ])
            ])
    }
    
    static func BeardB(_ parent:Enemy) -> EnemyAI {
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
                Wander(triggerOutsideOfDistance: 40, priority: 5),
                Circle(triggerInsideOfDistance: 40, priority: 10),
                FireProjectilesInSpiral(numStreams: 2, offsetStep: 0.1, projectileTexture: "projectile12", rateOfFire: 200, projectileSpeed: 80, range: 100)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75)
                ])
            ])
    }
    
    static func CatA(_ parent:Enemy) -> EnemyAI {
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
                RunSimultaneously(behaviorsToRun: [
                    FireNProjectilesAtEqualIntervals(numProjectiles: 5, projectileTexture: "projectile15", rateOfFire: 250, projectileSpeed: 80, range: 60),
                    RunAnimationSequence(animationName: "attack")
                    ], useConditionalOfIndex: 0),
                MaintainDistance(distanceToMaintain: 15, triggerDistance: 50, priority: 5),
                Circle(triggerInsideOfDistance: 15, priority: 10)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75)
                ])
            ])
    }
    
    
    static func CloudA(_ parent:Enemy) -> EnemyAI {
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
                Wander(triggerOutsideOfDistance: 40, priority: 5),
                Circle(triggerInsideOfDistance: 40, priority: 10),
                FireProjectilesInSpiral(numStreams: 3, offsetStep: 0.1, projectileTexture: "projectile66", rateOfFire: 200, projectileSpeed: 80, range: 100)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75)
                ])
            ])
    }
    
    static func CrabE(_ parent:Enemy) -> EnemyAI { 
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
                FireProjectilesAtAngularRange(numProjectiles: 3, angularRange: 1, direction: .random, projectileTexture: "projectile21", rateOfFire: 1000, projectileSpeed: 75, range: 70),
                FireNProjectilesAtEqualIntervals(numProjectiles: 10, projectileTexture: "projectile73", rateOfFire: 500, projectileSpeed: 70, range: 70),
                MaintainDistance(distanceToMaintain: 15, triggerDistance: 50, priority: 5),
                Circle(triggerInsideOfDistance: 15, priority: 10)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75)
                ])
            ])
    }
    
    static func ChestA(_ parent:Enemy) -> EnemyAI {
        return EnemyAI(parent:parent, startingState:"idle", withStates: [
            State(name: "idle",
                behaviors: [
                    RunAnimationSequence(animationName: "locked"),
                ],
                transitions: [
                    PlayerCloserThan(dest: "active", distance: 75)
                ]),
            State(name: "active", behaviors: [
                RunAnimationSequence(animationName: "default"),
                FireNProjectilesAtEqualIntervals(numProjectiles: 5, projectileTexture: "projectile51", rateOfFire: 250, projectileSpeed: 80, range: 100),
                FireProjectilesAtAngularRange(numProjectiles: 5, angularRange: 3.14, direction: .towardPlayer, projectileTexture: "projectile60", rateOfFire: 300, projectileSpeed: 90, range: 130),
                MaintainDistance(distanceToMaintain: 15, triggerDistance: 50, priority: 5),
                Circle(triggerInsideOfDistance: 15, priority: 10)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75)
                ])
            ])
    }

    static func EyeballB(_ parent:Enemy) -> EnemyAI {
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
                        FireProjectilesAtAngularRange(numProjectiles: 3, angularRange: 1, direction: .towardPlayer, projectileTexture: "projectile74", rateOfFire: 1000, projectileSpeed: 65, range: 50)
                        ], useConditionalOfIndex: 1, idType: .animation, priority: 10),
                    Wander(triggerOutsideOfDistance: 0, priority: 5)
                ],
                transitions: [
                    PlayerFartherThan(dest: "Idle", distance: 50)
                ])
            ])
    }
    
    static func GhastA(_ parent:Enemy) -> EnemyAI {
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
                FireNProjectilesAtEqualIntervals(numProjectiles: 5, projectileTexture: "projectile35", rateOfFire: 250, projectileSpeed: 80, range: 60),
                MaintainDistance(distanceToMaintain: 40, triggerDistance: 75, priority: 5),
                WanderReallyFast(triggerOutsideOfDistance: 0, speedMultiplier: 3, priority: 1)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75)
                ])
            ])
    }
    
    static func DyeB(_ parent:Enemy) -> EnemyAI {
        return EnemyAI(parent:parent, startingState:"idle", withStates: [
            State(name: "idle",
                behaviors: [
                    RunAnimationSequence(animationName: "default"),
                    Wander(triggerOutsideOfDistance: 0, priority: 10)
                ],
                transitions: [
                    PlayerCloserThan(dest: "awakened", distance: 75),
                    HPLessThan(dest: "enraged", hpLevel: 0.5)
                ]),
            State(name: "awakened", behaviors: [
                Wander(triggerOutsideOfDistance: 0, priority: 10),
                RunAnimationSequence(animationName: "default"),
                FireProjectilesInSpiral(numStreams: 3, offsetStep: 0.1, projectileTexture: "projectile74", rateOfFire: 300, projectileSpeed: 75, range: 75)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75),
                    HPLessThan(dest: "enraged", hpLevel: 0.7)
                ]),
            State(name: "enraged", behaviors: [
                MaintainDistance(distanceToMaintain: 20, triggerDistance: 50, priority: 5),
                Circle(triggerInsideOfDistance: 15, priority: 10),
                RunSimultaneously(behaviorsToRun: [
                    FireProjectilesInSpiral(numStreams: 3, offsetStep: 0.1, projectileTexture: "projectile74", rateOfFire: 300, projectileSpeed: 75, range: 75),
                    RunAnimationSequence(animationName: "attack")
                    ], useConditionalOfIndex: 0),
                RunSimultaneously(behaviorsToRun: [
                    FireProjectilesAtAngularRange(numProjectiles: 5, angularRange: 1, direction: .towardPlayer, projectileTexture: "projectile54", rateOfFire: 500, projectileSpeed: 80, range: 60),
                    RunAnimationSequence(animationName: "attack")
                    ], useConditionalOfIndex: 0),
                ], transitions: [
                    HPLessThan(dest: "finalEffort", hpLevel: 0.4)
                ]),
            State(name: "finalEffort", behaviors: [
                MaintainDistance(distanceToMaintain: 5, triggerDistance: 50, priority: 5),
                FireProjectilesInSpiral(numStreams: 4, offsetStep: 0.2, projectileTexture: "projectile74", rateOfFire: 200, projectileSpeed: 80, range: 100)
                ], transitions: [
                ])
            ])
    }
    
    static func DiscA(_ parent:Enemy) -> EnemyAI {
        return EnemyAI(parent:parent, startingState:"idle", withStates: [
            State(name: "idle",
                behaviors: [
                    RunAnimationSequence(animationName: "default"),
                    Wander(triggerOutsideOfDistance: 0, priority: 10)
                ],
                transitions: [
                    PlayerCloserThan(dest: "awakened", distance: 75),
                    HPLessThan(dest: "enraged", hpLevel: 0.5)
                ]),
            State(name: "awakened", behaviors: [
                MaintainDistance(distanceToMaintain: 40, triggerDistance: 75, priority: 5),
                RunAnimationSequence(animationName: "default"),
                FireProjectilesInSpiral(numStreams: 3, offsetStep: 0.1, projectileTexture: "projectile76", rateOfFire: 300, projectileSpeed: 75, range: 75)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75),
                    HPLessThan(dest: "enraged", hpLevel: 0.7)
                ]),
            State(name: "enraged", behaviors: [
                MaintainDistance(distanceToMaintain: 20, triggerDistance: 50, priority: 5),
                Circle(triggerInsideOfDistance: 15, priority: 10),
                FireProjectilesInSpiral(numStreams: 3, offsetStep: 0.2, projectileTexture: "projectile79", rateOfFire: 300, projectileSpeed: 75, range: 75),
                FireProjectilesAtAngularRange(numProjectiles: 5, angularRange: 1, direction: .towardPlayer, projectileTexture: "projectile43", rateOfFire: 500, projectileSpeed: 75, range: 60)
                ], transitions: [
                    HPLessThan(dest: "finalEffort", hpLevel: 0.4)
                ]),
            State(name: "finalEffort", behaviors: [
                MaintainDistance(distanceToMaintain: 30, triggerDistance: 50, priority: 5),
                WanderReallyFast(triggerOutsideOfDistance: 0, speedMultiplier: 4, priority: 2),
                FireProjectilesInSpiral(numStreams: 6, offsetStep: 0.2, projectileTexture: "projectile81", rateOfFire: 300, projectileSpeed: 75, range: 75)
                ], transitions: [
                ])
            ])
    }

}
