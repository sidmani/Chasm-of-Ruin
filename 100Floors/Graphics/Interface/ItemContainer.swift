//
//  ItemContainer.swift
//  100Floors
//
//  Created by Sid Mani on 1/13/16.
//
//


import UIKit
import SpriteKit
import CoreGraphics
struct ColorScheme {
    static let strokeColor =  UIColor(colorLiteralRed: 0.85, green: 0.85, blue: 0.85, alpha: 0.8)
    static let strokeColorSelected = UIColor(colorLiteralRed: 1, green: 0.98, blue: 0.45, alpha: 0.8)

    static let fillColor = UIColor(colorLiteralRed: 0.85, green: 0.85, blue: 0.85, alpha: 0.5)
    static let fillColorSelected = UIColor(colorLiteralRed: 1, green: 0.98, blue: 0.45, alpha: 0.5)
}
class ItemContainer:UICollectionViewCell {
    
    private let rectangleLayer = CAShapeLayer()
    private var numberLabel = UILabel()
    let itemView = UIImageView()

    private var centerPoint = CGPointZero
    
    var item:Item?
    
    var correspondsToInventoryIndex:Int = -5
    
    var isEquipped:Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        centerPoint =  CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
        let rectanglePath = UIBezierPath(roundedRect: CGRect(x: 2, y: 2, width: self.bounds.width-4, height: self.bounds.width-4), cornerRadius: 12)
        rectangleLayer.path = rectanglePath.CGPath
        setSelectedTo(false)
        rectangleLayer.lineWidth = 2.0
        let containerView = UIView()
        containerView.layer.addSublayer(rectangleLayer)
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
    
    func setSelectedTo(val:Bool) {
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