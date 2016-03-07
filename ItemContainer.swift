//
//  ItemContainer.swift
//  100Floors
//
//  Created by Sid Mani on 1/13/16.
//
//
import UIKit
class ItemContainer:UIControl {
    private var containerView:UIView = UIView()
    private var itemView:UIView = UIView()
    private var rectangleLayer = CAShapeLayer()
    var item:Item?
    var correspondsToInventoryIndex:Int = -1
    var droppedAt:CGPoint = CGPointZero
    var itemTypeRestriction:ItemType = .None
    var itemType:ItemType {
        get {
            if (item == nil) {
                return .None
            }
            else {
                return item!.type
            }
        }
    }
    required init?(coder aDecoder: NSCoder) {
        ///create container
        super.init(coder: aDecoder)

        let rectanglePath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.width), cornerRadius: self.bounds.size.width/5)
        rectangleLayer.path = rectanglePath.CGPath
  //      rectangleLayer.fillColor = UIColor(colorLiteralRed: 0.85, green: 0.85, blue: 0.85, alpha: 0.5).CGColor
  //      rectangleLayer.strokeColor = UIColor(colorLiteralRed: 0.85, green: 0.85, blue: 0.85, alpha: 0.8).CGColor
        setSelectedTo(false)
        rectangleLayer.lineWidth = 2.0
        containerView.layer.addSublayer(rectangleLayer)
        itemView.center = CGPointZero
        ////////////////////////////
        self.addSubview(containerView)
        self.addSubview(itemView)
    }
    func swapItemWith(container:ItemContainer) {
            setItem(container.setItem(self.item))
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
//        print(self.itemType)
        return (self.itemTypeRestriction == .None || self.itemTypeRestriction == container.itemType || container.itemType == .None) && (container.itemTypeRestriction == .None || container.itemTypeRestriction == self.itemType || self.itemType == .None)
    }
    
    func setItem(newItem:Item?) -> Item?
    {
        let oldItem:Item? = item
        item = newItem
        for view in itemView.subviews{
            view.removeFromSuperview()
        }
        if (item != nil) {
            itemView.addSubview(UIImageView(image: UIImage(CGImage:item!.node.texture!.CGImage())))
        }
        return oldItem
    }
    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        if item != nil {
//        if let touch = touches.first {
//            itemView.center = touch.locationInView(self)
//        }
//        super.touchesBegan(touches, withEvent: event)
//        }
//    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //if item != nil {
        if let touch = touches.first {
            itemView.center = touch.locationInView(self)
        }
        super.touchesMoved(touches, withEvent: event)
        //}
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
        itemView.center = CGPointZero
    }
    
    
}