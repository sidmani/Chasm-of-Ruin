//
//  ItemContainer.swift
//  100Floors
//
//  Created by Sid Mani on 1/13/16.
//
//
import UIKit
class ItemContainer:UICollectionViewCell {
    
    private let containerView:UIView = UIView()
    private let rectangleLayer = CAShapeLayer()

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
        containerView.layer.addSublayer(rectangleLayer)
        itemView.bounds = self.bounds
        itemView.userInteractionEnabled = false
        itemView.center = centerPoint
        itemView.contentMode = .ScaleAspectFit
        itemView.layer.magnificationFilter = kCAFilterNearest
        ////////////////////////////
        self.addSubview(containerView)
        self.addSubview(itemView)
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
            rectangleLayer.fillColor = UIColor(colorLiteralRed: 1, green: 0.98, blue: 0.45, alpha: 0.5).CGColor
        }
        else {
            rectangleLayer.fillColor = UIColor(colorLiteralRed: 0.85, green: 0.85, blue: 0.85, alpha: 0.5).CGColor
        }
        
        if (isEquipped) {
            if (item! is Weapon) {
                rectangleLayer.strokeColor = UIColor(colorLiteralRed: 1, green: 0, blue: 0, alpha: 1.0).CGColor
            }
            else if (item! is Shield) {
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
            rectangleLayer.strokeColor = UIColor(colorLiteralRed: 1, green: 0.98, blue: 0.45, alpha: 1.0).CGColor
        }
        else {
            rectangleLayer.strokeColor = UIColor(colorLiteralRed: 0.85, green: 0.85, blue: 0.85, alpha: 0.8).CGColor
        }
        
    }
    
    func setItemTo(newItem:Item?) -> Item?
    {
        let oldItem:Item? = item
        item = newItem
        if (item != nil) {
            itemView.image = UIImage(named: item!.img)
        }
        else {
            itemView.image = nil
        }
        return oldItem
    }
    
}