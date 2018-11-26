//
//  LongPressIndicator.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 6/15/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class LongPressIndicator: UIView {
    private let disposeBag = DisposeBag()
    private var pulsatingLayer = CAShapeLayer()
    private var coreLayer = CAShapeLayer()
    private var shapeLayer = CAShapeLayer()
    
    var colorDriver: Driver<UIColor>? {
        didSet {
            colorDriver!.drive(onNext: { [weak self](color) in
                self?.coreLayer.strokeColor = color.cgColor
                self?.pulsatingLayer.fillColor = color.withAlphaComponent(0.4).cgColor
            }).disposed(by: disposeBag)
        }
    }
    
    var isOnPlane: Bool = false {
        didSet{
            if isOnPlane {
                pulsatingLayer.isHidden = true
                coreLayer.opacity = 0.8
            } else {
                coreLayer.opacity = 0.6
                pulsatingLayer.isHidden = false
            }
        }
    }
    
    override var isHidden: Bool {
        didSet {
            isOnPlane = false
        }
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
        
        let pulsatingFillColor = UIColor.rgb(r: 165, g: 0, b: 0)
        pulsatingLayer = createCircleShapeLayer(strokeColor: .clear, fillColor: pulsatingFillColor)
        pulsatingLayer.opacity = 0.4
        layer.addSublayer(pulsatingLayer)
        animatePulsatingLayer(pulsatingLayer)
        
        let coreStrokeColor = UIColor.rgb(r: 201, g: 13, b: 0)
        coreLayer = createCircleShapeLayer(strokeColor: coreStrokeColor, fillColor: .clear)
        coreLayer.opacity = 0.6
        layer.addSublayer(coreLayer)
        
        let outlineStrokeColor = UIColor.rgb(r: 234, g: 46, b: 111)
        shapeLayer = createCircleShapeLayer(strokeColor: outlineStrokeColor, fillColor: .clear)
        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        shapeLayer.strokeEnd = 0
        layer.addSublayer(shapeLayer)
    }
    
    func refresh() {
        animatePulsatingLayer(pulsatingLayer)
    }
    
    private func animatePulsatingLayer(_ pulsatingLayer: CALayer) {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        
        animation.toValue = 1.5
        animation.duration = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        
        pulsatingLayer.add(animation, forKey: "pulsing")
    }
    
    private func createCircleShapeLayer(strokeColor: UIColor, fillColor: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 35, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        layer.path = circularPath.cgPath
        layer.strokeColor = strokeColor.cgColor
        layer.lineWidth = 10
        layer.fillColor = fillColor.cgColor
        layer.lineCap = kCALineCapRound
        layer.position = CGPoint(x: self.bounds.width/2.0,
                                 y: self.bounds.height/2.0)
        return layer
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
