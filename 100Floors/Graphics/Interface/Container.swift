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
    static let strokeColor =  UIColor(colorLiteralRed: 0.85, green: 0.85, blue: 0.85, alpha: 0.8)
    static let strokeColorSelected = UIColor(colorLiteralRed: 1, green: 0.98, blue: 0.45, alpha: 0.8)
    
    static let fillColor = UIColor(colorLiteralRed: 0.85, green: 0.85, blue: 0.85, alpha: 0.5)
    static let fillColorSelected = UIColor(colorLiteralRed: 1, green: 0.98, blue: 0.45, alpha: 0.5)
}

class Container:UICollectionViewCell {
    private var centerPoint = CGPointZero
    private let rectangleLayer = CAShapeLayer()
    private let containerView:UIView = UIView()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        centerPoint =  CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
        let rectanglePath = UIBezierPath(roundedRect: CGRect(x: 2, y: 2, width: self.bounds.width-4, height: self.bounds.width-4), cornerRadius: 12)
        rectangleLayer.path = rectanglePath.CGPath
        rectangleLayer.lineWidth = 2.0
        containerView.layer.addSublayer(rectangleLayer)
        setSelectedTo(false)
        ////////////////////////////
        self.addSubview(containerView)
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
    var level:LevelHandler.LevelDefinition?
    private let lockView = UIImageView()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        levelView.bounds = self.bounds
        levelView.userInteractionEnabled = false
        levelView.center = centerPoint
        levelView.contentMode = .ScaleAspectFit
        levelView.layer.magnificationFilter = kCAFilterNearest
        
        lockView.bounds = self.bounds
        lockView.center = centerPoint
        lockView.image = UIImage(named: "lock")
        lockView.tintColor = ColorScheme.strokeColor
        ////////////////////////////
        self.addSubview(containerView)
        self.addSubview(levelView)
        self.addSubview(lockView)
    }
    
    
    
    func setLevelTo(l:LevelHandler.LevelDefinition) {
        level = l
        lockView.hidden = level!.unlocked
        //TODO: somehow get level thumbnail from level name
        //then add it to the UIImageView
    }

    
}

class ItemContainer:Container {
    
    private var numberLabel = UILabel()
    let itemView = UIImageView()
    var item:Item?
    
    var correspondsToInventoryIndex:Int = -5
    
    var isEquipped:Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        itemView.bounds = self.bounds
        itemView.userInteractionEnabled = false
        itemView.center = centerPoint
        itemView.contentMode = .ScaleAspectFit
        itemView.layer.magnificationFilter = kCAFilterNearest
        ////////////////////////////
        numberLabel.text = ""
        numberLabel.textAlignment = .Right
        numberLabel.textColor = ColorScheme.strokeColor
        numberLabel.bounds = CGRectMake(0, self.bounds.height - 30, self.bounds.width-10, 30)
        numberLabel.center = CGPointMake(self.bounds.width/2 - 2.5, self.bounds.height - 15)
        ////////////////////////////
        self.addSubview(containerView)
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
        
        if (isEquipped) { //TODO: nicer colors
            if (item! is Weapon) {
                rectangleLayer.strokeColor = UIColor(colorLiteralRed: 1, green: 0, blue: 0, alpha: 1.0).CGColor
            }
            else if (item! is Armor) {
                rectangleLayer.strokeColor = UIColor(colorLiteralRed: 0, green: 0, blue: 1, alpha: 1.0).CGColor
            }
            else if (item! is Enhancer) {
                rectangleLayer.strokeColor = UIColor(colorLiteralRed: 0, green: 1, blue: 0, alpha: 1.0).CGColor
            }
            else if (item! is Skill) {
                rectangleLayer.strokeColor = UIColor(colorLiteralRed: 1, green: 1, blue: 0, alpha: 1.0).CGColor
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
