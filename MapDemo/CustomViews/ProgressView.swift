//
//  ProgressView.swift
//  HockeyDemo
//
//  Created by Ilgiz Fazlyev on 21/05/2019.
//

import Foundation
import UIKit

class ProgressView: UIView {
    
    private var circleShapeLayer: CAShapeLayer!
    
    init(frame: CGRect, onView: UIView, colors: [CGColor], lineWidth: CGFloat, startValue: CGFloat) {
        super.init(frame: frame)
        circleShapeLayer = CAShapeLayer()
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.width / 2  , y:  frame.height / 2 ), radius: CGFloat(frame.size.width / 2 - 20), startAngle: CGFloat(Double.pi / 1.5 ), endAngle:  CGFloat(Double.pi / Double.pi), clockwise: true)
        
        circleShapeLayer.strokeEnd = startValue
        circleShapeLayer.path = circlePath.cgPath
        circleShapeLayer.fillColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 0).cgColor
        circleShapeLayer.strokeColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        circleShapeLayer.lineWidth = lineWidth
        circleShapeLayer.lineCap = .round
        circleShapeLayer.zPosition = 1
        let backgroundLayer = CAShapeLayer()
        backgroundLayer.strokeEnd = 1
        backgroundLayer.path = circlePath.cgPath
        backgroundLayer.fillColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 0).cgColor
        backgroundLayer.strokeColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1).cgColor
        backgroundLayer.lineWidth = lineWidth
        backgroundLayer.lineCap = .round
        backgroundLayer.zPosition = 0
        
        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.colors = colors
        gradient.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradient.mask = circleShapeLayer
        gradient.name = "circleShapeLayer"
        gradient.type = .conic
        circleShapeLayer.zPosition = 1
        onView.layer.addSublayer(backgroundLayer)
        onView.layer.addSublayer(gradient)
        
        
        
    }
    
    func animation(from: CGFloat, to: CGFloat, duration: Double) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = from
        animation.toValue =  to
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.fillMode = CAMediaTimingFillMode.both
        animation.isRemovedOnCompletion = false
        circleShapeLayer.add(animation, forKey: nil)
        
    }
    
    func remove(fromView: UIView) {
        for layer in fromView.layer.sublayers! {
            if layer.name ==  "circleShapeLayer" {
                layer.removeFromSuperlayer()
            }
        }
    }
    func clearAnimation(){
        circleShapeLayer.removeAllAnimations()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

