//
//  SunlitCavernsEnemies.swift
//  Chasm Of Ruin
//
//  Created by Sid Mani on 7/28/16.
//
//

import Foundation

extension EnemyDictionary {
    static func BugB(parent:Enemy) -> EnemyAI {
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
                    FireProjectile(error: 0.5, rateOfFire: 500, projectileTexture: "projectile9", projectileSpeed: 70, range: 30),
                    MaintainDistance(distanceToMaintain: 20, triggerDistance: 50, priority: 5),
                    Circle(triggerInsideOfDistance: 25, priority: 10)
                ], runOnStruckMapBoundary: [
                    Wander(triggerOutsideOfDistance: 0, priority: 15)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75)
                ])
            ])
    }
    static func DuckA(parent:Enemy) -> EnemyAI {
        return EnemyAI(parent:parent, startingState:"idle", withStates: [
            State(name: "idle",
                behaviors: [
                    RunAnimationSequence(animationName: "default"),
                    Wander(triggerOutsideOfDistance: 0, priority: 5),
                ],
                transitions: [
                    PlayerCloserThan(dest: "active", distance: 50)
                ]),
            State(name: "active", behaviors: [
                RunAnimationSequence(animationName: "default"),
                FireProjectilesAtAngularRange(numProjectiles: 3, angularRange: 3.14, direction: .TowardPlayer, projectileTexture: "projectile9", rateOfFire: 500, projectileSpeed: 50, range: 70),
                MaintainDistance(distanceToMaintain: 30, triggerDistance: 50, priority: 5),
                Wander(triggerOutsideOfDistance: 0, priority: 2)
                ], runOnStruckMapBoundary: [
                    Flee(finalDist: 75, priority: 5)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 50)
                ])
            ])
    }
    static func OrbA(parent:Enemy) -> EnemyAI {
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
                    FireProjectilesInSpiral(numStreams: 3, offsetStep: 0.2, projectileTexture: "projectile9", rateOfFire: 200, projectileSpeed: 60, range: 75),
                    RunAnimationSequence(animationName: "attack")
                    ], useConditionalOfIndex: 0, idType:.Animation, priority:10),
                    Wander(triggerOutsideOfDistance: 40, priority: 5),
                    Circle(triggerInsideOfDistance: 40, priority: 10)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75)
                ])
            ])
    }
    
    static func AirA(parent:Enemy) -> EnemyAI {
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
    
    static func BallA(parent:Enemy) -> EnemyAI {
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
    
    static func BrainC(parent:Enemy) -> EnemyAI {
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
                FireProjectilesAtAngularRange(numProjectiles: 5, angularRange: 2, direction: .TowardPlayer, projectileTexture: "projectile9", rateOfFire: 300, projectileSpeed: 80, range: 80),
                MaintainDistance(distanceToMaintain: 15, triggerDistance: 50, priority: 5),
                Wander(triggerOutsideOfDistance: 0, priority: 2)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75)
                ])
            ])
    }
    
    static func EarthA(parent:Enemy) -> EnemyAI { //
        return EnemyAI(parent:parent, startingState:"idle", withStates: [
            State(name: "idle",
                behaviors: [
                    RunAnimationSequence(animationName: "default")
                ],
                transitions: [
                    PlayerCloserThan(dest: "active", distance: 75)
                ]),
            State(name: "active", behaviors: [
                RunAnimationSequence(animationName: "default"),
                FireProjectile(error: 0.2, rateOfFire: 300, projectileTexture: "projectile9", projectileSpeed: 80, range: 50),
                FireProjectilesInSpiral(numStreams: 2, offsetStep: 0.2, projectileTexture: "projectile9", rateOfFire: 400, projectileSpeed: 80, range: 75),
                MaintainDistance(distanceToMaintain: 30, triggerDistance: 50, priority: 5),
                Wander(triggerOutsideOfDistance: 0, priority: 2)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75)
                ])
            ])
    }
    
    static func FactoryA(parent:Enemy) -> EnemyAI {
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
                FireNProjectilesAtEqualIntervals(numProjectiles: 5, projectileTexture: "projectile9", rateOfFire: 250, projectileSpeed: 80, range: 60),
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75),
                    HPLessThan(dest: "enraged", hpLevel: 0.5)
                ]),
            State(name: "enraged", behaviors: [
                MaintainDistance(distanceToMaintain: 20, triggerDistance: 50, priority: 5),
                Circle(triggerInsideOfDistance: 15, priority: 10),
                FireNProjectilesAtEqualIntervals(numProjectiles: 5, projectileTexture: "projectile9", rateOfFire: 250, projectileSpeed: 80, range: 60),
                FireProjectilesAtAngularRange(numProjectiles: 5, angularRange: 1, direction: .TowardPlayer, projectileTexture: "projectile9", rateOfFire: 500, projectileSpeed: 50, range: 60)
                ], transitions: [
                
                ])
            ])
    }
   
    static func GolemA(parent:Enemy) -> EnemyAI {
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
                RunSimultaneously(behaviorsToRun: [
                    FireProjectilesInSpiral(numStreams: 2, offsetStep: 0.1, projectileTexture: "projectile9", rateOfFire: 500, projectileSpeed: 50, range: 75),
                    RunAnimationSequence(animationName: "attack")
                    ], useConditionalOfIndex: 0, idType:.Animation, priority:10),
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75),
                    HPLessThan(dest: "enraged", hpLevel: 0.5)
                ]),
            State(name: "enraged", behaviors: [
                MaintainDistance(distanceToMaintain: 20, triggerDistance: 50, priority: 5),
                Circle(triggerInsideOfDistance: 15, priority: 10),
                RunSimultaneously(behaviorsToRun: [
                    FireProjectilesInSpiral(numStreams: 5, offsetStep: 0.1, projectileTexture: "projectile9", rateOfFire: 500, projectileSpeed: 50, range: 75),
                    RunAnimationSequence(animationName: "attack")
                    ], useConditionalOfIndex: 0, idType:.Animation, priority:10),
                RunSimultaneously(behaviorsToRun: [
                    FireNProjectilesAtEqualIntervals(numProjectiles: 10, projectileTexture: "projectile9", rateOfFire: 500, projectileSpeed: 75, range: 80),
                    RunAnimationSequence(animationName: "attack")
                    ], useConditionalOfIndex: 0, idType:.Nonexclusive, priority:10),
                ], transitions: [
                    
                ])
            ])
    }
    
    static func MonolithA(parent:Enemy) -> EnemyAI {
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
                FireProjectilesInSpiral(numStreams: 3, offsetStep: 0.1, projectileTexture: "projectile9", rateOfFire: 300, projectileSpeed: 50, range: 75)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75),
                    HPLessThan(dest: "enraged", hpLevel: 0.7)
                ]),
            State(name: "enraged", behaviors: [
                MaintainDistance(distanceToMaintain: 20, triggerDistance: 50, priority: 5),
                Circle(triggerInsideOfDistance: 15, priority: 10),
                FireNProjectilesAtEqualIntervals(numProjectiles: 5, projectileTexture: "projectile9", rateOfFire: 250, projectileSpeed: 80, range: 60),
                FireProjectilesAtAngularRange(numProjectiles: 5, angularRange: 1, direction: .TowardPlayer, projectileTexture: "projectile9", rateOfFire: 500, projectileSpeed: 50, range: 60)
                ], transitions: [
                    HPLessThan(dest: "finalEffort", hpLevel: 0.4)
                ]),
            State(name: "finalEffort", behaviors: [
                MaintainDistance(distanceToMaintain: 5, triggerDistance: 50, priority: 5),
                FireProjectilesAtAngularRange(numProjectiles: 5, angularRange: 1.5, direction: .TowardPlayer, projectileTexture: "projectile9", rateOfFire: 300, projectileSpeed: 80, range: 100)
                ], transitions: [
                ])
            ])
    }
}