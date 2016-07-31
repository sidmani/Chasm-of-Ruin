//
//  InGameScene.swift
//  100Floors
//
//  Created by Sid Mani on 1/2/16.
//
//


import SpriteKit
import AVFoundation

let screenSize = UIScreen.mainScreen().bounds

class InGameScene: SKScene, SKPhysicsContactDelegate {

    struct PhysicsCategory {
        static let None: UInt32 = 0
        static let All: UInt32 = UINT32_MAX
        static let FriendlyProjectile: UInt32 = 0b00001
        static let ThisPlayer: UInt32 = 0b00010
        static let Enemy: UInt32 = 0b00100
        static let Interactive: UInt32 = 0b01000
        static let EnemyProjectile: UInt32 = 0b10000
        static let MapBoundary:UInt32 = 0b100000
        static let Activate:UInt32 = 0b1000000
    }

    private var currentLevel:MapLevel?
    private var oldTime:CFTimeInterval = 0
    private let mainCamera = SKCameraNode()
    private var nonCharNodes = SKNode()
    private var itemBags = SKNode()
    private var cameraBounds:CGRect = CGRectZero
    var currScreenBounds:CGRect = CGRectZero
    weak var currentGroundBag:ItemBag?
    
    override func didMoveToView(view: SKView) {
        self.physicsWorld.gravity = CGVectorMake(0,0)
        self.physicsWorld.contactDelegate = self
        self.scaleMode = .AspectFill
        self.camera = mainCamera
        self.camera!.position = thisCharacter.position
        self.camera!.setScale(0.2)
        self.paused = true
        //////////////////////////////////////////
        self.addChild(self.camera!)
        //////////////////////////////////////////
        nonCharNodes.addChild(itemBags)
        addChild(nonCharNodes)
        addChild(thisCharacter)
    }

    func didBeginContact(contact: SKPhysicsContact) {
        /////// player contacts interactive object
        if (contact.bodyA.categoryBitMask == PhysicsCategory.Interactive) {
            let object = contact.bodyA.node as! Interactive
            if (object.autotrigger) { object.trigger() }
            object.displayPopup(true)
            if (object is ItemBag) {currentGroundBag = (object as! ItemBag)}
            return
        }
        else if (contact.bodyB.categoryBitMask == PhysicsCategory.Interactive) {
            let object = contact.bodyB.node as! Interactive
            if (object.autotrigger) { object.trigger() }
            object.displayPopup(true)
            if (object is ItemBag) {currentGroundBag = (object as! ItemBag)}
            return
        }
        ////// player is hit by projectile
        else if (contact.bodyA.categoryBitMask == PhysicsCategory.ThisPlayer && contact.bodyB.categoryBitMask == PhysicsCategory.EnemyProjectile) {
            if let projectile = contact.bodyB.node as? Projectile {
                thisCharacter.struckByProjectile(projectile)
                projectile.struckMapBoundary()
                return
            }
        }
        else if (contact.bodyB.categoryBitMask == PhysicsCategory.ThisPlayer && contact.bodyA.categoryBitMask == PhysicsCategory.EnemyProjectile) {
            if let projectile = contact.bodyA.node as? Projectile {
                thisCharacter.struckByProjectile(projectile)
                projectile.struckMapBoundary()
                return
            }
        }
        ////// projectile hits map boundary
        else if ((contact.bodyA.categoryBitMask == PhysicsCategory.EnemyProjectile || contact.bodyA.categoryBitMask == PhysicsCategory.FriendlyProjectile) && contact.bodyB.categoryBitMask == PhysicsCategory.MapBoundary) {
            if let projectile = contact.bodyA.node as? Projectile {
                projectile.struckMapBoundary()
                return
            }
        }
            
        else if ((contact.bodyB.categoryBitMask == PhysicsCategory.EnemyProjectile || contact.bodyB.categoryBitMask == PhysicsCategory.FriendlyProjectile) && contact.bodyA.categoryBitMask == PhysicsCategory.MapBoundary) {
            if let projectile = contact.bodyB.node as? Projectile {
                projectile.struckMapBoundary()
                return
            }
        }
        ////// character enters spawner radius
        else if (contact.bodyA.categoryBitMask == PhysicsCategory.Activate) {
            (contact.bodyA.node as! Activate).activate()
            if let trap = contact.bodyA.node as? Trap {
                (contact.bodyB.node as! ThisCharacter).adjustHealth(trap.damage, withPopup: true)
            }
        }
        else if (contact.bodyB.categoryBitMask == PhysicsCategory.Activate) {
            (contact.bodyB.node as! Activate).activate()
            if let trap = contact.bodyB.node as? Trap {
                (contact.bodyA.node as! ThisCharacter).adjustHealth(trap.damage, withPopup: true)
            }

        }
        ////// enemy hit by friendly projectile
        else if (contact.bodyA.categoryBitMask == PhysicsCategory.FriendlyProjectile && contact.bodyB.categoryBitMask == PhysicsCategory.Enemy) {
            if let projectile = contact.bodyA.node as? Projectile {
                (contact.bodyB.node as? Enemy)?.struckByProjectile(projectile)
                projectile.struckMapBoundary()
            }
            return
        }
            
        else if (contact.bodyB.categoryBitMask == PhysicsCategory.FriendlyProjectile && contact.bodyA.categoryBitMask == PhysicsCategory.Enemy) {
            if let projectile = contact.bodyB.node as? Projectile {
                (contact.bodyA.node as? Enemy)?.struckByProjectile(projectile)
                projectile.struckMapBoundary()
            }
            return
        }
        ////// enemy hits map boundary
        else if (contact.bodyA.categoryBitMask == PhysicsCategory.Enemy && contact.bodyB.categoryBitMask == PhysicsCategory.MapBoundary) {
            if let enemy = contact.bodyA.node as? Enemy {
                enemy.struckMapBoundary(contact.contactPoint)
            }
            return
        }
            
        else if (contact.bodyB.categoryBitMask == PhysicsCategory.Enemy && contact.bodyA.categoryBitMask == PhysicsCategory.MapBoundary) {
            if let enemy = contact.bodyB.node as? Enemy {
                enemy.struckMapBoundary(contact.contactPoint)
            }
            return
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == PhysicsCategory.Interactive && contact.bodyB.categoryBitMask == PhysicsCategory.ThisPlayer) {
            let object = contact.bodyA.node as! Interactive
            object.displayPopup(false)
            if (object is ItemBag && (object as! ItemBag) == currentGroundBag) { currentGroundBag = nil }
        }
        else if (contact.bodyB.categoryBitMask == PhysicsCategory.Interactive && contact.bodyA.categoryBitMask == PhysicsCategory.ThisPlayer) {
            let object = contact.bodyB.node as! Interactive
            object.displayPopup(false)
            if (object is ItemBag && (object as! ItemBag) == currentGroundBag) { currentGroundBag = nil }
        }
        ////// character exits spawner radius
        else if (contact.bodyA.categoryBitMask == PhysicsCategory.Activate) {
            (contact.bodyA.node as! Activate).deactivate()
        }
        else if (contact.bodyB.categoryBitMask == PhysicsCategory.Activate) {
            (contact.bodyB.node as! Activate).deactivate()
        }
    }
    
    override func didFinishUpdate() {
        var newLoc = CGPointMake(floor(thisCharacter.position.x*10)/10, floor(thisCharacter.position.y*10)/10)
        newLoc.x = min(cameraBounds.maxX, newLoc.x)
        newLoc.x = max(cameraBounds.minX, newLoc.x)
        newLoc.y = min(cameraBounds.maxY, newLoc.y)
        newLoc.y = max(cameraBounds.minY, newLoc.y)
        camera!.position = newLoc
    }

    func isTutorial() -> Bool {
        return currentLevel?.definition.mapName == "Tutorial"
    }
    
    func currentWave() -> Int {
        return (currentLevel != nil ? currentLevel!.currWaveIndex : 0)
    }
    
    func setLevel(level:MapLevel) {
        thisCharacter.hidden = true
        nonCharNodes.hidden = true
        nonCharNodes.removeAllChildren()
        thisCharacter.pointers.removeAllChildren()
        ///////////////////////////
        currentLevel = level
        nonCharNodes.addChild(currentLevel!)
        thisCharacter.position = currentLevel!.startLoc
        thisCharacter.setTextureDict()
        thisCharacter.reset()
        cameraBounds = CGRectMake(camera!.xScale*screenSize.width/2, camera!.yScale*screenSize.height/2,  (currentLevel!.mapSize.width) - camera!.xScale*(screenSize.width), (currentLevel!.mapSize.height) - camera!.yScale*(screenSize.height))
        globalAudioPlayer?.stop()
        let url = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(level.definition.bgMusic, ofType: "mp3")!)
        do {
            globalAudioPlayer = try AVAudioPlayer(contentsOfURL:url)
            globalAudioPlayer!.numberOfLoops = -1
            globalAudioPlayer!.prepareToPlay()
            if (audioEnabled) {
                globalAudioPlayer!.play()
            }
        } catch {
            print("Error getting the audio file")
        }

        ///////////////////////////
        thisCharacter.hidden = false
        nonCharNodes.hidden = false
        self.paused = false
        if (!isTutorial()) {
            NSNotificationCenter.defaultCenter().postNotificationName("postInfoToDisplay", object: currentLevel!.definition.mapName)
            self.camera!.addChild(CountdownTimer(time: 5, endText: "WAVE \(self.currentLevel!.currWaveIndex + 2)") {[unowned self] in
                self.currentLevel!.nextWave()
            })
        }
        else {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(startCountdownAfterTutorial), name: "TutorialEnded", object: nil)
        }
    }
    
    func startCountdownAfterTutorial() {
        self.camera!.addChild(CountdownTimer(time: 5, endText: "WAVE \(self.currentLevel!.currWaveIndex + 2)") {[unowned self] in
            self.currentLevel!.nextWave()
        })
    }
    
    func reloadLevel() {
        if let level = currentLevel {
            setLevel(MapLevel(level: level.definition))
            self.currentLevel!.nextWave()
        }
    }
    
    ////////
    var hasMovedToNextWave = false
    var timeUntilProceedToNextWave:Double = 15000
    var progressUpdateTime:Double = 0
    override func update(currentTime: CFTimeInterval) {
        let deltaT = (currentTime-oldTime)*1000
        oldTime = currentTime
        if (deltaT < 100) {
            thisCharacter.update(deltaT)
            if (currentLevel != nil) {
                let newWidth = Int(currentLevel!.mapSizeOnScreen.width*camera!.xScale) - 1
                let newHeight = Int(currentLevel!.mapSizeOnScreen.height*camera!.yScale) - 1
                let mapLoc = currentLevel!.indexForPoint(thisCharacter.position)
                currentLevel!.cull(Int(mapLoc.x), y: Int(mapLoc.y), width: newWidth, height: newHeight) //Remove tiles that are off-screen
                thisCharacter.physicsBody!.velocity = currentLevel!.speedModForIndex(mapLoc) * thisCharacter.physicsBody!.velocity
                if (currentLevel!.waveIsOver() && !hasMovedToNextWave) {
                    if (timeUntilProceedToNextWave <= 0) {
                        if (currentLevel!.currWaveIndex == currentLevel!.numWaves - 1) {
                            NSNotificationCenter.defaultCenter().postNotificationName("levelEndedVictory", object: nil)
                        }
                        else {
                            hasMovedToNextWave = true
                            self.camera!.addChild(CountdownTimer(time: 5, endText: "\(currentLevel!.currWaveIndex == currentLevel!.numWaves - 2 ? "FINAL WAVE" : "WAVE \(self.currentLevel!.currWaveIndex + 2)")") {[unowned self] in
                                self.currentLevel!.nextWave()
                            })
                        }
                        timeUntilProceedToNextWave = 15000
                        UIElements.ProceedButton.hidden = true
                        UIElements.ProceedButton.setProgress(1, animated: false)
                    }
                    else {
                        if (progressUpdateTime >= 20) {
                            UIElements.ProceedButton.setProgress(CGFloat(timeUntilProceedToNextWave/15000), animated: false)
                            progressUpdateTime = 0
                        }
                        else {
                            progressUpdateTime += deltaT
                        }
                        timeUntilProceedToNextWave -= deltaT
                        UIElements.ProceedButton.hidden = false
                    }
                }
                else if (!currentLevel!.waveIsOver()){
                    hasMovedToNextWave = false
                }
            }
            for node in nonCharNodes.children {
                (node as? Updatable)?.update(deltaT)
            }
            currScreenBounds = CGRectMake(camera!.position.x - camera!.xScale*screenSize.width/2, camera!.position.y - camera!.yScale*screenSize.height/2, screenSize.width*camera!.xScale, screenSize.height*camera!.yScale)
        }
    }

    func proceedToNextWave() {
        if (!hasMovedToNextWave) {
            UIElements.ProceedButton.hidden = true
            if (currentLevel!.currWaveIndex == currentLevel!.numWaves - 1) {
                NSNotificationCenter.defaultCenter().postNotificationName("levelEndedVictory", object: nil)
            }
            else {
                hasMovedToNextWave = true
                self.camera!.addChild(CountdownTimer(time: 5, endText: "\(currentLevel!.currWaveIndex == currentLevel!.numWaves - 2 ? "FINAL WAVE" : "WAVE \(self.currentLevel!.currWaveIndex + 2)")") {[unowned self] in
                    self.currentLevel!.nextWave()
                    })
            }
            timeUntilProceedToNextWave = 15000
            UIElements.ProceedButton.setProgress(1, animated: false)
        }
    }
    
    func addObject(node:SKNode) {
        if (node.parent == nil) {
            if let obj = node as? MapObject {
                currentLevel?.objects.addChild(obj)
            }
            else if let bag = node as? ItemBag {
                itemBags.addChild(bag)
            }
            else {
                nonCharNodes.addChild(node)
            }
        }
    }

    func enemiesOnScreen() -> [Enemy] {
        var arr = [Enemy]()
        for node in nonCharNodes.children where (node is Enemy && currScreenBounds.contains(node.position)) {
            arr.append(node as! Enemy)
        }
        return arr
    }
    
    func enemiesOffScreen() -> [Enemy] {
        var arr = [Enemy]()
        for node in nonCharNodes.children where (node is Enemy && !currScreenBounds.contains(node.position)) {
            arr.append(node as! Enemy)
        }
        return arr
    }
    
    deinit {
        for node in camera!.children where node is CountdownTimer {
            (node as! CountdownTimer).invalidate()
        }
    }
    
}
