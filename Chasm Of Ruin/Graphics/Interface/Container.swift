//
//  LevelContainer.swift
//  100Floors
//
//  Created by Sid Mani on 6/10/16.
//
//

import Foundation
//
//  ItemContainer.swift
//  100Floors
//
//  Created by Sid Mani on 1/13/16.
//
//
import UIKit

struct ColorScheme {
    static let HPColor = UIColor.green
    static let SPDColor = UIColor(red: 2/255, green: 164/255, blue: 239/255, alpha: 1)
    static let ATKColor = UIColor.red
    static let EXPColor = UIColor(red: 107/255, green: 121/255, blue: 224/255, alpha: 1)
    static let MANAColor = UIColor(red: 105/255, green: 2/255, blue: 201/255, alpha: 1)
    //static let DEFColor = UIColor(red: 132/255, green: 140/255, blue: 150/255, alpha: 1)
    static let DEFColor = UIColor.black
    static let DEXColor = UIColor(red: 249/255, green: 159/255, blue: 2/255, alpha: 1)
    
    static let strokeColor =  UIColor(colorLiteralRed: 0.95, green: 0.95, blue: 0.95, alpha: 0.9)
    static let strokeColorSelected = UIColor(colorLiteralRed: 1, green: 0.98, blue: 0.45, alpha: 0.8)
    
    static let fillColor = UIColor(colorLiteralRed: 0.85, green: 0.85, blue: 0.85, alpha: 0.75)
    static let fillColorSelected = UIColor(colorLiteralRed: 1, green: 0.98, blue: 0.45, alpha: 0.5)
}

class Container:UICollectionViewCell {
    private var centerPoint = CGPoint.zero
    private let rectangleLayer = CAShapeLayer()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        centerPoint =  CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let rectanglePath = UIBezierPath(roundedRect: CGRect(x: 2, y: 2, width: self.bounds.width-4, height: self.bounds.width-4), cornerRadius: 12)
        rectangleLayer.path = rectanglePath.cgPath
        rectangleLayer.lineWidth = 2.0
        self.layer.addSublayer(rectangleLayer)
        setSelectedTo(false)
        ////////////////////////////
        //self.addSubview(containerView)
    }
    
    func setSelectedTo(_ val:Bool) {
        if (val) {
            rectangleLayer.fillColor = ColorScheme.fillColorSelected.cgColor
            rectangleLayer.strokeColor = ColorScheme.strokeColorSelected.cgColor
        }
        else {
            rectangleLayer.fillColor = ColorScheme.fillColor.cgColor
            rectangleLayer.strokeColor = ColorScheme.strokeColor.cgColor
        }
    }
    
    
}
class LevelContainer:Container {
    
    private let levelView = UIImageView()
    private let numberLabel = UILabel()
    private var animationImages:[UIImage] = []
    var level:LevelHandler.LevelDefinition?
    private let lockView = UIImageView()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        levelView.bounds = CGRect(x: 10, y: self.bounds.height - 10, width: self.bounds.width-20, height: self.bounds.height-20)
        levelView.isUserInteractionEnabled = false
        levelView.isMultipleTouchEnabled = false
        levelView.center = centerPoint
        levelView.contentMode = .scaleAspectFit
        levelView.layer.magnificationFilter = kCAFilterNearest
        levelView.animationRepeatCount = -1
        
        lockView.bounds = self.bounds
        lockView.center = centerPoint
        lockView.image = UIImage(named: "lock")
        lockView.tintColor = ColorScheme.strokeColor
        
        numberLabel.text = ""
        numberLabel.textAlignment = .right
        numberLabel.textColor = ColorScheme.strokeColorSelected
        numberLabel.bounds = CGRect(x: 0, y: self.bounds.height - 30, width: self.bounds.width - 5, height: 30)
        numberLabel.center = CGPoint(x: self.bounds.width/2 - 2.5, y: self.bounds.height - 15)
        ////////////////////////////
        self.addSubview(levelView)
        self.addSubview(lockView)
        self.addSubview(numberLabel)
    }
    
    override func setSelectedTo(_ val: Bool) {
        if (val) {
            rectangleLayer.fillColor = ColorScheme.fillColorSelected.cgColor
            rectangleLayer.strokeColor = ColorScheme.strokeColorSelected.cgColor
            lockView.tintColor = ColorScheme.strokeColorSelected
        }
        else {
            rectangleLayer.fillColor = ColorScheme.fillColor.cgColor
            rectangleLayer.strokeColor = ColorScheme.strokeColor.cgColor
            lockView.tintColor = ColorScheme.strokeColor
        }
    }
    
    func setLevelTo(_ l:LevelHandler.LevelDefinition) {
        level = l
        lockView.isHidden = level!.unlocked
        animationImages = []
        for i in 0..<level!.thumbFrames {
            animationImages.append(UIImage(named: "\(level!.thumb)\(i)")!)
        }
        if (level!.unlocked) {
            levelView.image = UIImage.animatedImage(with: animationImages, duration: Double(level!.thumbFrames) * 0.125)
        }
        else {
            levelView.image = animationImages[0]
        }
        if (level!.cleared) {
            numberLabel.text = "⭐"
        }
        else if (level!.playCount == 0 && level!.unlocked) {
            numberLabel.text = "⚡"
        }
        else {
            numberLabel.text = ""
        }
    }
}

class ItemContainer:Container {

    private let numberLabel = UILabel()
    let itemView = UIImageView()
    var item:Item?
    
    var correspondsToInventoryIndex:Int = -5
    
    var isEquipped:Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        itemView.bounds = CGRect(x: 10, y: self.bounds.height - 10, width: self.bounds.width-20, height: self.bounds.height-20)
        itemView.isUserInteractionEnabled = false
        itemView.center = centerPoint
        itemView.contentMode = .scaleAspectFit
        itemView.layer.magnificationFilter = kCAFilterNearest
        itemView.clipsToBounds = true
        ////////////////////////////
        numberLabel.text = ""
        numberLabel.textAlignment = .right
        numberLabel.textColor = ColorScheme.strokeColor
        numberLabel.bounds = CGRect(x: 0, y: self.bounds.height - 30, width: self.bounds.width-10, height: 30)
        numberLabel.center = CGPoint(x: self.bounds.width/2 - 2.5, y: self.bounds.height - 15)
        ////////////////////////////
        self.addSubview(itemView)
        self.addSubview(numberLabel)
        
    }
    
    func updateIndex(_ index:Int) {
        correspondsToInventoryIndex = index
        if (index == -2) {
            numberLabel.text = "Ground"
        }
        else if (index >= 0) {
            numberLabel.text = "\(index+1)"
        }
        
    }
    
    func resetItemView() {
        itemView.center = centerPoint
        itemView.isHidden = false
    }
    
    override func setSelectedTo(_ val:Bool) {
        if (item == nil) {
            isEquipped = false
        }
        if (val) {
            numberLabel.textColor = ColorScheme.strokeColorSelected
            rectangleLayer.fillColor = ColorScheme.fillColorSelected.cgColor
        }
        else {
            numberLabel.textColor = ColorScheme.strokeColor
            rectangleLayer.fillColor = ColorScheme.fillColor.cgColor
        }
        
        if (isEquipped) {
            if (item! is Weapon) {
                rectangleLayer.strokeColor = ColorScheme.ATKColor.cgColor
            }
            else if (item! is Armor) {
                rectangleLayer.strokeColor = ColorScheme.DEFColor.cgColor
            }
            else if (item! is Enhancer) {
                rectangleLayer.strokeColor = ColorScheme.SPDColor.cgColor
            }
            else if (item! is Skill) {
                rectangleLayer.strokeColor = ColorScheme.MANAColor.cgColor
            }
        }
        else if (val) {
            rectangleLayer.strokeColor = ColorScheme.strokeColorSelected.cgColor
        }
        else {
            rectangleLayer.strokeColor = ColorScheme.strokeColor.cgColor
        }
        
    }
    
    @discardableResult func setItemTo(_ newItem:Item?) -> Item?
    {
        let oldItem:Item? = item
        item = newItem
        if (item != nil) {
            itemView.image = UIImage(named:item!.img)
        }
        else {
            itemView.image = nil
        }
        return oldItem
    }
    
}

