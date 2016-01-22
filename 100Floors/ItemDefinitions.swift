//
//  ItemDefinitions.swift
//  100Floors
//
//  Created by Sid Mani on 1/18/16.
//
//

struct WeaponDefinition {
    var statMods:Stats
    var imgMain:String
    var imgAlt:String
    var projectile:ProjectileDefinition
}

struct ConsumableDefinition {
    var statMods:Stats
    var imgMain:String
    var imgAlt:String
}

struct ShieldDefinition {
    var statMods:Stats
    var imgMain:String
    var imgAlt:String
}

struct EnhancerDefinition {
    var statMods:Stats
    var imgMain:String
    var imgAlt:String
}

struct SkillDefinition {
    var statMods:Stats
    var imgMain:String
    var imgAlt:String
}

struct ProjectileDefinition {
    var imgMain:String
    var imgAlt:String
    var range:CGFloat
}

////////////////////////////
let SwordProjectile = ProjectileDefinition(imgMain: "SwordProjectile", imgAlt: "", range: 35)
let Sword = WeaponDefinition(statMods: nullStats, imgMain: "", imgAlt: "", projectile: SwordProjectile)
