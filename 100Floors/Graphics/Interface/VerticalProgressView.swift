//
//  VerticalProgressView.swift
//  VerticalProgressView
//
//  Created by mlaskowski on 11/08/15.
//  Copyright (c) 2015 mlaskowski. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class VerticalProgressView : UIView {
    
    @IBInspectable public var fillDoneColor : UIColor = UIColor.blueColor()
    @IBInspectable public var vertical:Bool = true

    private var progress: CGFloat = 0
    
    public let label = UILabel()
    private let animationDuration: Double = 0.5
    public let filledView = CALayer()
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        self.filledView.backgroundColor = self.fillDoneColor.CGColor
        self.filledView.frame = self.bounds

        self.layer.addSublayer(filledView)
        if (vertical) {
            self.filledView.frame.origin.y = self.shouldHavePosition()
        }
        else {
            self.filledView.frame.origin.x = self.shouldHavePosition()

        }
        if (self.vertical) {
            label.bounds = CGRectMake(0, self.bounds.height - 30, self.bounds.width - 10, 30)
            label.center = CGPointMake(self.bounds.width/2 - 2.5, self.bounds.height - 15)
            label.textColor = ColorScheme.strokeColor
            label.textAlignment = .Right
            self.addSubview(label)
        }
        self.layer.borderColor = ColorScheme.strokeColor.CGColor
        self.layer.borderWidth = 2.0
        self.backgroundColor = ColorScheme.fillColor
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true

    }
    
    override public func drawRect(rect: CGRect) {
        super.drawRect(rect)
        if (vertical) {
            let filledHeight = rect.size.height * progress
            let y = self.frame.size.height - filledHeight
            self.filledView.frame = CGRectMake(0, y, rect.size.width, rect.size.height)

        }
        else {
            let filledWidth = rect.size.width * progress
            let x = filledWidth - self.frame.size.width
            self.filledView.frame = CGRectMake(x, 0, rect.size.width, rect.size.height)
        }
        
    }
    
    private func shouldHavePosition() -> CGFloat {
        if (vertical) {
            let filledHeight = self.frame.size.height * progress
            let position = self.frame.size.height - filledHeight
            return position
        }
        else {
            let filledWidth = self.frame.size.width * progress
            let position = filledWidth - self.frame.size.width
            return position
        }
    }
    
    private func setFilledPosition(position: CGFloat, animated: Bool) {
        //animated
        let duration: NSTimeInterval = animated ? self.animationDuration : 0;
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)

        if (vertical) {
            self.filledView.frame.origin.y = position
        }
        else {
            self.filledView.frame.origin.x = position
        }
        
        CATransaction.commit()

    }
    
    private func setFilledPosition(color:UIColor, position: CGFloat, animated: Bool) {
        //animated
        let duration: NSTimeInterval = animated ? self.animationDuration : 0;
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        
        if (vertical) {
            self.filledView.frame.origin.y = position
        }
        else {
            self.filledView.frame.origin.x = position
        }
        self.filledView.backgroundColor = color.CGColor
        
        CATransaction.commit()
        
    }
    
    public func setProgress(progress: CGFloat, animated: Bool){
        //bounds check
        self.progress = max(0, min(progress, 1))
        setFilledPosition(self.shouldHavePosition(), animated: animated)
    }
    
    public func setProgress(color:UIColor, progress: CGFloat, animated: Bool){
        //bounds check
        self.progress = max(0, min(progress, 1))
        setFilledPosition(color, position: self.shouldHavePosition(), animated: animated)
    }
    
    

    
}