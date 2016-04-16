//
//  ItemContainer.swift
//  100Floors
//
//  Created by Sid Mani on 1/13/16.
//
//
import UIKit
class ItemContainer:UIControl {
    private let containerView:UIView = UIView()
    private let itemView:UIView = UIView()
    private let rectangleLayer = CAShapeLayer()
    var centerPoint = CGPointZero
    var item:Item?
    var correspondsToInventoryIndex:Int = -1
    var droppedAt:CGPoint = CGPointZero
    var itemTypeRestriction:Any.Type = Any.self
    
    var itemType:Any.Type {
        get {
            if (item == nil) {
                return Any.self
            }
            return item!.dynamicType
            
        }
    }
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
        ////////////////////////////
        self.addSubview(containerView)
        self.addSubview(itemView)
    }
    func swapItemWith(container:ItemContainer) {
            setItemTo(container.setItemTo(self.item))
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
    func swappableWith(container:ItemContainer) -> Bool {
        return (self.itemTypeRestriction == Any.self || self.itemTypeRestriction == container.itemType || container.itemType == Any.self) && (container.itemTypeRestriction == Any.self || container.itemTypeRestriction == self.itemType || self.itemType == Any.self)
    }
    
    func setItemTo(newItem:Item?) -> Item?
    {
        let oldItem:Item? = item
        item = newItem
        for view in itemView.subviews{
            view.removeFromSuperview()
        }
        if (item != nil) {
            let imageView = UIImageView(image: UIImage(named: item!.img))
            imageView.contentMode = .ScaleAspectFit
            imageView.layer.magnificationFilter = kCAFilterNearest
            imageView.bounds = itemView.bounds
            imageView.center = centerPoint
            imageView.userInteractionEnabled = false
            itemView.addSubview(imageView)
        }
        return oldItem
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        superview?.bringSubviewToFront(self)
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            itemView.center = touch.locationInView(self)
        }
        super.touchesMoved(touches, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if item != nil {
            if let touch = touches.first {
                let currentPoint = touch.locationInView(superview)
                if (!CGRectContainsPoint(self.frame, currentPoint)) {
                    droppedAt = currentPoint
                    sendActionsForControlEvents(.ApplicationReserved)
                }
                else {
                    super.touchesEnded(touches, withEvent: event)
                }
            }
        }
        itemView.center = centerPoint
    }
}