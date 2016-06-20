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
    
    @IBInspectable public var cornerRadius: CGFloat = 12;
    @IBInspectable public var fillDoneColor : UIColor = UIColor.blueColor()
    @IBInspectable public var fillUndoneColor: UIColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.1)
    //@IBInspectable var fillRestColor : UIColor = UIColor.whiteColor()
    @IBInspectable public var animationDuration: Double = 0.5
    @IBInspectable public var vertical:Bool = true

    @IBInspectable public var progress: Float {
        get {
            return self.progressPriv
        }
        set{
            self.setProgress(newValue, animated: self.animationDuration > 0.0)
        }
    }
    
    public var label = UILabel()
    
    private var progressPriv: Float = 0.0
    
    public var filledView: CALayer?
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if self.filledView == nil {
            self.filledView = CALayer()
            self.filledView!.backgroundColor = self.fillDoneColor.CGColor
            self.layer.addSublayer(filledView!)
        }
        self.filledView!.frame = self.bounds
        if (vertical) {
            self.filledView!.frame.origin.y = self.shouldHavePosition()
        }
        else {
            self.filledView!.frame.origin.x = self.shouldHavePosition()

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
    }
    
    public override func prepareForInterfaceBuilder() {
        self.progressPriv = progress
        if self.progressPriv < 0 { progressPriv = 0 }
        else if(self.progressPriv > 1) { progressPriv = 1}
    }
    
    override public func drawRect(rect: CGRect) {
        super.drawRect(rect)
        if (vertical) {
            let filledHeight = rect.size.height * CGFloat(self.progressPriv)
            self.setLayerProperties()
            let y = self.frame.size.height - filledHeight
            self.filledView!.frame = CGRectMake(0, y, rect.size.width, rect.size.height)

        }
        else {
            let filledWidth = rect.size.width * CGFloat(self.progressPriv)
            self.setLayerProperties()
            let x = filledWidth - self.frame.size.width
            self.filledView!.frame = CGRectMake(x, 0, rect.size.width, rect.size.height)
        }
        
    }
    
    //public - for possible inheritance and customization
    public func setLayerProperties(){
        self.layer.cornerRadius = self.cornerRadius
        self.layer.masksToBounds = true
    }
    
    private func shouldHavePosition() -> CGFloat {
        if (vertical) {
            let filledHeight = self.frame.size.height * CGFloat(self.progressPriv)
            let position = self.frame.size.height - filledHeight
            return position
        }
        else {
            let filledWidth = self.frame.size.width * CGFloat(self.progressPriv)
            let position = filledWidth - self.frame.size.width
            return position
        }
    }
    
    func setFilledPosition(position: CGFloat, animated: Bool) {
        if self.filledView == nil { return }
        //animated
        let duration: NSTimeInterval = animated ? self.animationDuration : 0;
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)

        if (vertical) {
            self.filledView!.frame.origin.y = position
        }
        else {
            self.filledView!.frame.origin.x = position
        }
        
        CATransaction.commit()

    }
    
    public func setProgress(progress: Float, animated: Bool){
        //bounds check
        var val = progress
        if val < 0 { val = 0.0 }
        else if val > 1 { val = 1 }
        self.progressPriv = val
        
        setFilledPosition(self.shouldHavePosition(), animated: animated)
    }
    

    
}