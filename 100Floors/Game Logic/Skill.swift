//
//  Skill.swift
//  Chasm Of Ruin
//
//  Created by Sid Mani on 6/27/16.
//
//

import Foundation
import SpriteKit

class Skill: Item {
    let mana:CGFloat
    
    required init(fromBase64: String) {
        //requiredMana, name, desc, img, priceCC, priceCoins, designatedCurrency
        let optArr = fromBase64.splitBase64IntoArray()
        self.mana = CGFloat(s: optArr[0])
        super.init(statMods: Stats.nilStats, name: optArr[1], description: optArr[2], img: optArr[3], priceCrystals: Int(optArr[4])!, priceCoins: Int(optArr[5])!, designatedCurrencyType: CurrencyType(rawValue: Int(optArr[6])!))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func execute(character:ThisCharacter) {
        //override me
    }
    
    override func getType() -> String {
        return "Skill"
    }
}


class HealSelf:Skill {
    
    required init(fromBase64: String) {
        super.init(fromBase64: fromBase64)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func execute(character:ThisCharacter) {
        thisCharacter.setHealth(1, withPopup: true)
    }
}

class Scroll:Skill {
    private let effect:String
    private let statusEffect:StatusCondition
    private let damagePercent:CGFloat
    private let statusProbability:CGFloat
    required init (fromBase64:String) {
        //requiredMana, name, desc, img, priceCC, priceCoins, designatedCurrency, animation name, damage percent, status effect raw value, probability
        let optArr = fromBase64.splitBase64IntoArray()
        effect = optArr[7]
        damagePercent = -CGFloat(s: optArr[8])
        statusEffect = StatusCondition(rawValue: Double(optArr[9])!)!
        statusProbability = CGFloat(s: optArr[10])
        super.init(fromBase64: fromBase64)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func execute(character:ThisCharacter) {
        //for all enemies on screen
        //apply status effect
        //do damage
        for enemy in (character.scene! as! InGameScene).enemiesOnScreen() {
            enemy.runEffect(effect, completion: {[unowned self] in
                if (randomBetweenNumbers(0, secondNum: 1) < self.statusProbability) {
                    enemy.enableCondition(self.statusEffect)
                }
                enemy.adjustHealth(self.damagePercent * enemy.getStats().maxHealth, withPopup: true)
                enemy.setVelocity(CGVector.zero)
            })

        }
    }
}