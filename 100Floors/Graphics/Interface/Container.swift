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
    static let HPColor = UIColor.greenColor()
    static let SPDColor = UIColor(red: 2/255, green: 164/255, blue: 239/255, alpha: 1)
    static let ATKColor = UIColor.redColor()
    static let EXPColor = UIColor(red: 107/255, green: 121/255, blue: 224/255, alpha: 1)
    static let MANAColor = UIColor(red: 105/255, green: 2/255, blue: 201/255, alpha: 1)
    //static let DEFColor = UIColor(red: 132/255, green: 140/255, blue: 150/255, alpha: 1)
    static let DEFColor = UIColor.blackColor()
    static let DEXColor = UIColor(red: 249/255, green: 159/255, blue: 2/255, alpha: 1)
    
    static let strokeColor =  UIColor(colorLiteralRed: 0.95, green: 0.95, blue: 0.95, alpha: 0.9)
    static let strokeColorSelected = UIColor(colorLiteralRed: 1, green: 0.98, blue: 0.45, alpha: 0.8)
    
    static let fillColor = UIColor(colorLiteralRed: 0.85, green: 0.85, blue: 0.85, alpha: 0.75)
    static let fillColorSelected = UIColor(colorLiteralRed: 1, green: 0.98, blue: 0.45, alpha: 0.5)
}

class Container:UICollectionViewCell {
    private var centerPoint = CGPointZero
    private let rectangleLayer = CAShapeLayer()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        centerPoint =  CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
        let rectanglePath = UIBezierPath(roundedRect: CGRect(x: 2, y: 2, width: self.bounds.width-4, height: self.bounds.width-4), cornerRadius: 12)
        rectangleLayer.path = rectanglePath.CGPath
        rectangleLayer.lineWidth = 2.0
        self.layer.addSublayer(rectangleLayer)
        setSelectedTo(false)
        ////////////////////////////
        //self.addSubview(containerView)
    }
    
    func setSelectedTo(val:Bool) {
        if (val) {
            rectangleLayer.fillColor = ColorScheme.fillColorSelected.CGColor
            rectangleLayer.strokeColor = ColorScheme.strokeColorSelected.CGColor
        }
        else {
            rectangleLayer.fillColor = ColorScheme.fillColor.CGColor
            rectangleLayer.strokeColor = ColorScheme.strokeColor.CGColor
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
        levelView.bounds = CGRectMake(10, self.bounds.height - 10, self.bounds.width-20, self.bounds.height-20)
        levelView.userInteractionEnabled = false
        levelView.multipleTouchEnabled = false
        levelView.center = centerPoint
        levelView.contentMode = .ScaleAspectFit
        levelView.layer.magnificationFilter = kCAFilterNearest
        levelView.animationRepeatCount = -1
        
        lockView.bounds = self.bounds
        lockView.center = centerPoint
        lockView.image = UIImage(named: "lock")
        lockView.tintColor = ColorScheme.strokeColor
        
        numberLabel.text = ""
        numberLabel.textAlignment = .Right
        numberLabel.textColor = ColorScheme.strokeColorSelected
        numberLabel.bounds = CGRectMake(0, self.bounds.height - 30, self.bounds.width - 5, 30)
        numberLabel.center = CGPointMake(self.bounds.width/2 - 2.5, self.bounds.height - 15)
        ////////////////////////////
        self.addSubview(levelView)
        self.addSubview(lockView)
        self.addSubview(numberLabel)
    }
    
    override func setSelectedTo(val: Bool) {
        if (val) {
            rectangleLayer.fillColor = ColorScheme.fillColorSelected.CGColor
            rectangleLayer.strokeColor = ColorScheme.strokeColorSelected.CGColor
            lockView.tintColor = ColorScheme.strokeColorSelected
        }
        else {
            rectangleLayer.fillColor = ColorScheme.fillColor.CGColor
            rectangleLayer.strokeColor = ColorScheme.strokeColor.CGColor
            lockView.tintColor = ColorScheme.strokeColor
        }
    }
    
    func setLevelTo(l:LevelHandler.LevelDefinition) {
        level = l
        lockView.hidden = level!.unlocked
        animationImages = []
        for i in 0..<level!.thumbFrames {
            animationImages.append(UIImage(named: "\(level!.thumb)\(i)")!)
        }
        if (level!.unlocked) {
            levelView.image = UIImage.animatedImageWithImages(animationImages, duration: Double(level!.thumbFrames) * 0.125)
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
        itemView.bounds = CGRectMake(10, self.bounds.height - 10, self.bounds.width-20, self.bounds.height-20)
        itemView.userInteractionEnabled = false
        itemView.center = centerPoint
        itemView.contentMode = .ScaleAspectFit
        itemView.layer.magnificationFilter = kCAFilterNearest
        itemView.clipsToBounds = true
        ////////////////////////////
        numberLabel.text = ""
        numberLabel.textAlignment = .Right
        numberLabel.textColor = ColorScheme.strokeColor
        numberLabel.bounds = CGRectMake(0, self.bounds.height - 30, self.bounds.width-10, 30)
        numberLabel.center = CGPointMake(self.bounds.width/2 - 2.5, self.bounds.height - 15)
        ////////////////////////////
        self.addSubview(itemView)
        self.addSubview(numberLabel)
        
    }
    
    func updateIndex(index:Int) {
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
        itemView.hidden = false
    }
    
    override func setSelectedTo(val:Bool) {
        if (item == nil) {
            isEquipped = false
        }
        if (val) {
            numberLabel.textColor = ColorScheme.strokeColorSelected
            rectangleLayer.fillColor = ColorScheme.fillColorSelected.CGColor
        }
        else {
            numberLabel.textColor = ColorScheme.strokeColor
            rectangleLayer.fillColor = ColorScheme.fillColor.CGColor
        }
        
        if (isEquipped) {
            if (item! is Weapon) {
                rectangleLayer.strokeColor = ColorScheme.ATKColor.CGColor
            }
            else if (item! is Armor) {
                rectangleLayer.strokeColor = ColorScheme.DEFColor.CGColor
            }
            else if (item! is Enhancer) {
                rectangleLayer.strokeColor = ColorScheme.SPDColor.CGColor
            }
            else if (item! is Skill) {
                rectangleLayer.strokeColor = ColorScheme.MANAColor.CGColor
            }
        }
        else if (val) {
            rectangleLayer.strokeColor = ColorScheme.strokeColorSelected.CGColor
        }
        else {
            rectangleLayer.strokeColor = ColorScheme.strokeColor.CGColor
        }
        
    }
    
    func setItemTo(newItem:Item?) -> Item?
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

