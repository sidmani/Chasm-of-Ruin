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

    var centerPoint = CGPointZero
    var item:Item?
    var correspondsToInventoryIndex:Int = -5

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        centerPoint =  CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
        let rectanglePath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.width), cornerRadius: self.bounds.size.width/5)
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
        if (val) {
            rectangleLayer.strokeColor = UIColor(colorLiteralRed: 1, green: 0.98, blue: 0.45, alpha: 1.0).CGColor
            rectangleLayer.fillColor = UIColor(colorLiteralRed: 1, green: 0.98, blue: 0.45, alpha: 0.5).CGColor
        }
        else {
            rectangleLayer.fillColor = UIColor(colorLiteralRed: 0.85, green: 0.85, blue: 0.85, alpha: 0.5).CGColor
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