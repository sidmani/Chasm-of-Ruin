//
//  AncientRealmEnemies.swift
//  Chasm Of Ruin
//
//  Created by Sid Mani on 7/29/16.
//
//

import Foundation

extension EnemyDictionary {
    static func BallD(_ parent:Enemy) -> EnemyAI {
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
                    FireProjectilesInSpiral(numStreams: 5, offsetStep: 0.1, projectileTexture: "projectile1", rateOfFire: 500, projectileSpeed: 75, range: 75),
                    RunAnimationSequence(animationName: "attack")
                    ], useConditionalOfIndex: 0, idType:.animation, priority:10),
                MaintainDistance(distanceToMaintain: 20, triggerDistance: 50, priority: 5)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75)
                ])
            ])
    }
    static func BatH(_ parent:Enemy) -> EnemyAI {
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
                FireProjectile(error: 0.5, rateOfFire: 300, projectileTexture: "projectile15", projectileSpeed: 80, range: 30),
                MaintainDistance(distanceToMaintain: 20, triggerDistance: 50, priority: 5),
                Circle(triggerInsideOfDistance: 25, priority: 10)
                ], runOnStruckMapBoundary: [
                    Wander(triggerOutsideOfDistance: 0, priority: 15)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75)
                ])
            ])
    }
    static func BatR(_ parent:Enemy) -> EnemyAI {
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
                FireProjectile(error: 0.5, rateOfFire: 300, projectileTexture: "projectile49", projectileSpeed: 80, range: 30),
                MaintainDistance(distanceToMaintain: 20, triggerDistance: 50, priority: 5),
                Circle(triggerInsideOfDistance: 25, priority: 10)
                ], runOnStruckMapBoundary: [
                    Wander(triggerOutsideOfDistance: 0, priority: 15)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75)
                ])
            ])
    }
    
    static func BrainE(_ parent:Enemy) -> EnemyAI {
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
                FireProjectilesAtAngularRange(numProjectiles: 5, angularRange: 2, direction: .towardPlayer, projectileTexture: "projectile31", rateOfFire: 1000, projectileSpeed: 75, range: 50),
                MaintainDistance(distanceToMaintain: 15, triggerDistance: 50, priority: 5),
                Wander(triggerOutsideOfDistance: 0, priority: 2)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75)
                ])
            ])
    }
    
    static func FrogC(_ parent:Enemy) -> EnemyAI {
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
                    FireNProjectilesAtEqualIntervals(numProjectiles: 10, projectileTexture: "projectile20", rateOfFire: 500, projectileSpeed: 80, range: 60),
                    RunAnimationSequence(animationName: "attack")
                    ], useConditionalOfIndex: 0, idType:.animation, priority:10),
                Wander(triggerOutsideOfDistance: 0, priority: 10)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75)
                ])
            ])
    }
    
    static func KlackonB(_ parent:Enemy) -> EnemyAI {
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
                FireProjectilesAtAngularRange(numProjectiles: 3, angularRange: 1, direction: .random, projectileTexture: "projectile70", rateOfFire: 1000, projectileSpeed: 75, range: 70),
                FireNProjectilesAtEqualIntervals(numProjectiles: 10, projectileTexture: "projectile71", rateOfFire: 500, projectileSpeed: 70, range: 70),
                MaintainDistance(distanceToMaintain: 15, triggerDistance: 50, priority: 5),
                Circle(triggerInsideOfDistance: 15, priority: 10)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75)
                ])
            ])
    }

    static func GhastB(_ parent:Enemy) -> EnemyAI {
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
                FireNProjectilesAtEqualIntervals(numProjectiles: 5, projectileTexture: "projectile76", rateOfFire: 250, projectileSpeed: 80, range: 60),
                MaintainDistance(distanceToMaintain: 40, triggerDistance: 75, priority: 5),
                WanderReallyFast(triggerOutsideOfDistance: 0, speedMultiplier: 3, priority: 1)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75)
                ])
            ])
    }
    
    static func MonolithD(_ parent:Enemy) -> EnemyAI {
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
                FireProjectilesInSpiral(numStreams: 3, offsetStep: 0.1, projectileTexture: "projectile47", rateOfFire: 300, projectileSpeed: 75, range: 75)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75),
                    HPLessThan(dest: "enraged", hpLevel: 0.7)
                ]),
            State(name: "enraged", behaviors: [
                MaintainDistance(distanceToMaintain: 20, triggerDistance: 50, priority: 5),
                Circle(triggerInsideOfDistance: 15, priority: 10),
                FireNProjectilesAtEqualIntervals(numProjectiles: 5, projectileTexture: "projectile40", rateOfFire: 250, projectileSpeed: 80, range: 60),
                FireProjectilesAtAngularRange(numProjectiles: 5, angularRange: 1, direction: .towardPlayer, projectileTexture: "projectile53", rateOfFire: 500, projectileSpeed: 75, range: 60)
                ], transitions: [
                    HPLessThan(dest: "finalEffort", hpLevel: 0.4)
                ]),
            State(name: "finalEffort", behaviors: [
                MaintainDistance(distanceToMaintain: 5, triggerDistance: 50, priority: 5),
                FireProjectilesAtAngularRange(numProjectiles: 5, angularRange: 1.5, direction: .towardPlayer, projectileTexture: "projectile53", rateOfFire: 300, projectileSpeed: 80, range: 100)
                ], transitions: [
                ])
            ])
    }
    
    static func DyeD(_ parent:Enemy) -> EnemyAI {
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
                FireProjectilesInSpiral(numStreams: 3, offsetStep: 0.1, projectileTexture: "projectile23", rateOfFire: 300, projectileSpeed: 75, range: 75)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75),
                    HPLessThan(dest: "enraged", hpLevel: 0.7)
                ]),
            State(name: "enraged", behaviors: [
                MaintainDistance(distanceToMaintain: 20, triggerDistance: 50, priority: 5),
                Circle(triggerInsideOfDistance: 15, priority: 10),
                RunSimultaneously(behaviorsToRun: [
                    FireProjectilesInSpiral(numStreams: 3, offsetStep: 0.1, projectileTexture: "projectile23", rateOfFire: 300, projectileSpeed: 75, range: 75),
                    RunAnimationSequence(animationName: "attack")
                    ], useConditionalOfIndex: 0),
                RunSimultaneously(behaviorsToRun: [
                    FireProjectilesAtAngularRange(numProjectiles: 5, angularRange: 1, direction: .towardPlayer, projectileTexture: "projectile63", rateOfFire: 500, projectileSpeed: 80, range: 60),
                    RunAnimationSequence(animationName: "attack")
                    ], useConditionalOfIndex: 0),
                ], transitions: [
                    HPLessThan(dest: "finalEffort", hpLevel: 0.4)
                ]),
            State(name: "finalEffort", behaviors: [
                MaintainDistance(distanceToMaintain: 5, triggerDistance: 50, priority: 5),
                FireProjectilesInSpiral(numStreams: 4, offsetStep: 0.2, projectileTexture: "projectile23", rateOfFire: 200, projectileSpeed: 80, range: 100)
                ], transitions: [
                ])
            ])
    }

    static func HeadC(_ parent:Enemy) -> EnemyAI {
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
                FireProjectilesInSpiral(numStreams: 3, offsetStep: 0.1, projectileTexture: "projectile28", rateOfFire: 300, projectileSpeed: 75, range: 75)
                ], transitions: [
                    PlayerFartherThan(dest: "idle", distance: 75),
                    HPLessThan(dest: "enraged", hpLevel: 0.7)
                ]),
            State(name: "enraged", behaviors: [
                MaintainDistance(distanceToMaintain: 20, triggerDistance: 50, priority: 5),
                Circle(triggerInsideOfDistance: 15, priority: 10),
                FireNProjectilesAtEqualIntervals(numProjectiles: 5, projectileTexture: "projectile28", rateOfFire: 250, projectileSpeed: 80, range: 60),
                FireProjectilesAtAngularRange(numProjectiles: 5, angularRange: 1, direction: .towardPlayer, projectileTexture: "projectile30", rateOfFire: 500, projectileSpeed: 80, range: 60)
                ], transitions: [
                    HPLessThan(dest: "finalEffort", hpLevel: 0.4)
                ]),
            State(name: "finalEffort", behaviors: [
                MaintainDistance(distanceToMaintain: 5, triggerDistance: 50, priority: 5),
                FireProjectilesAtAngularRange(numProjectiles: 5, angularRange: 1.5, direction: .towardPlayer, projectileTexture: "projectile30", rateOfFire: 300, projectileSpeed: 80, range: 100),
                FireProjectilesInSpiral(numStreams: 4, offsetStep: 0.2, projectileTexture: "projectile28", rateOfFire: 200, projectileSpeed: 80, range: 100)
                ], transitions: [
                ])
            ])
    }

}
