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
    
    required init(fromBase64: String, id: String) {
        //requiredMana, name, desc, img, priceCC, priceCoins, designatedCurrency
        let optArr = fromBase64.splitBase64IntoArray("|")
        self.mana = CGFloat(optArr[0])
        super.init(statMods: Stats.nilStats, name: optArr[1], description: optArr[2], img: optArr[3], priceCrystals: Int(optArr[4])!, priceCoins: Int(optArr[5])!, designatedCurrencyType: CurrencyType(rawValue: Int(optArr[6])!), id: id)
    }
    
    func execute(_ character:ThisCharacter) -> Bool {
        return false
        //override me
    }
    
    override func getType() -> String {
        return "Skill"
    }
}


class Scroll:Skill {
    private let effect:String
    private let statusEffect:StatusCondition
    private let statusProbability:CGFloat
    private let attack:CGFloat
    required init (fromBase64:String, id:String) {
        //requiredMana, name, desc, img, priceCC, priceCoins, designatedCurrency, animation name, attack, status effect raw value, probability
        let optArr = fromBase64.splitBase64IntoArray("|")
        effect = optArr[7]
        attack = CGFloat(optArr[8])
        statusEffect = StatusCondition(rawValue: Double(optArr[9])!)!
        statusProbability = CGFloat(optArr[10])
        SKTextureAtlas.preloadTextureAtlases([SKTextureAtlas(named: effect)], withCompletionHandler: {})
        super.init(fromBase64: fromBase64, id: id)
    }
    
    override func execute(_ character:ThisCharacter) -> Bool {
        var ret = false
        for enemy in (character.scene! as! InGameScene).enemiesOnScreen() where hypot(enemy.position.x - character.position.x, enemy.position.y-character.position.y) < 75 {
            enemy.runEffect(effect, completion: {[unowned self] in
                if (randomBetweenNumbers(0, secondNum: 1) < self.statusProbability) {
                    enemy.enableCondition(self.statusEffect, duration: self.statusEffect.rawValue)
                }
                enemy.adjustHealth(-enemy.getDamage(character.getStats().attack + self.attack), withPopup: true)
                enemy.setVelocity(CGVector.zero)
            })
            ret = true
        }
        return ret
    }
}
