//
//  ItemContainer.swift
//  100Floors
//
//  Created by Sid Mani on 1/13/16.
//
//

import UIKit

class ItemContainer:UIView {
    var containerView:UIView
    var itemView:UIView
    var item:Item?
    
    required init?(coder aDecoder: NSCoder) {
        ///create container
        containerView = UIView()
        itemView = UIView()
        let rectanglePath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 60, height: 60), cornerRadius: 8)
        let rectangleLayer = CAShapeLayer()
        rectangleLayer.path = rectanglePath.CGPath
        rectangleLayer.fillColor = UIColor(colorLiteralRed: 0.85, green: 0.85, blue: 0.85, alpha: 0.5).CGColor
        rectangleLayer.strokeColor = UIColor(colorLiteralRed: 0.85, green: 0.85, blue: 0.85, alpha: 0.8).CGColor
        rectangleLayer.lineWidth = 2.0
        containerView.layer.addSublayer(rectangleLayer)
        ////////////////////////////
        super.init(coder: aDecoder)
        self.addSubview(containerView)
    }
    func addItem(newItem:Item) -> Item?
    {
        let oldItem:Item? = item
        item = newItem
        for view in itemView.subviews{
            view.removeFromSuperview()
        }

        itemView.addSubview(UIImageView(image: UIImage(CGImage:item!.getNode().texture!.CGImage())))
        return oldItem
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.locationInView(self)
            if item != nil {
             itemView.center = currentPoint
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.locationInView(self)
            if item != nil {
                itemView.center = currentPoint
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (touches.first != nil) {
            if item != nil {
                //if inside rectangle, set position back to 0,0
                //else if outside rectangle, drop item (call inventory.drop or something)
            }
        }
    }
    
    
}

class ItemContainerCircular:UIView {
    
}