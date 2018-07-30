//
//  ResizableView.swift
//  Resizable
//
//  Created by Caroline on 6/09/2014.
//  Copyright (c) 2014 Caroline. All rights reserved.
//

import UIKit

class ResizableView: UITextView, UIGestureRecognizerDelegate {
    
    var topLeft:DragHandle!
    var topRight:DragHandle!
    var bottomLeft:DragHandle!
    var bottomRight:DragHandle!
    var rotateHandle:DragHandle!
    var previousLocation = CGPoint.zero
    var rotateLine = CAShapeLayer()
    
    var showHandles = true {
        didSet {
            topLeft.isHidden = !showHandles
            topRight.isHidden = !showHandles
            bottomLeft.isHidden = !showHandles
            bottomRight.isHidden = !showHandles
            rotateHandle.isHidden = !showHandles
        }
    }
    
    override func didMoveToSuperview() {
        let resizeFillColor = UIColor.green.withAlphaComponent(0.25)
        let resizeStrokeColor = UIColor.flatBlack.withAlphaComponent(0.7)
        let rotateFillColor = UIColor.flatRed.withAlphaComponent(0.85)
        let rotateStrokeColor = UIColor.flatBlack.withAlphaComponent(0.7)
        topLeft = DragHandle(fillColor:resizeFillColor, strokeColor: resizeStrokeColor)
        topRight = DragHandle(fillColor:resizeFillColor, strokeColor: resizeStrokeColor)
        bottomLeft = DragHandle(fillColor:resizeFillColor, strokeColor: resizeStrokeColor)
        bottomRight = DragHandle(fillColor:resizeFillColor, strokeColor: resizeStrokeColor)
        rotateHandle = DragHandle(fillColor:rotateFillColor, strokeColor:rotateStrokeColor)
        
        rotateLine.opacity = 0.0
        rotateLine.lineDashPattern = [3,2]
        
        superview?.addSubview(topLeft)
        superview?.addSubview(topRight)
        superview?.addSubview(bottomLeft)
        superview?.addSubview(bottomRight)
        superview?.addSubview(rotateHandle)
        self.layer.addSublayer(rotateLine)
        
        
        var pan = UIPanGestureRecognizer(target: self, action: #selector(ResizableView.handlePan(_:)))
        topLeft.addGestureRecognizer(pan)
        pan = UIPanGestureRecognizer(target: self, action: #selector(ResizableView.handlePan(_:)))
        topRight.addGestureRecognizer(pan)
        pan = UIPanGestureRecognizer(target: self, action: #selector(ResizableView.handlePan(_:)))
        bottomLeft.addGestureRecognizer(pan)
        pan = UIPanGestureRecognizer(target: self, action: #selector(ResizableView.handlePan(_:)))
        bottomRight.addGestureRecognizer(pan)
        pan = UIPanGestureRecognizer(target: self, action: #selector(ResizableView.handleRotate(_:)))
        rotateHandle.addGestureRecognizer(pan)
        pan = UIPanGestureRecognizer(target: self, action: #selector(ResizableView.handleMove(_:)))
        self.addGestureRecognizer(pan)
        
        self.updateDragHandles()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleHandles(recognizer:)))
        superview?.addGestureRecognizer(tap)
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        showHandles = false
        backgroundColor = UIColor.clear
        font = UIFont(name: "Montserrat-Medium", size: 20)
        
        textColor = UIColor.black
        textAlignment = .center
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handleTextSize(recognizer:)))
        addGestureRecognizer(pinch)
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(recognizer:)))
        addGestureRecognizer(rotate)
    
    }

    
    @objc func handleHandles(recognizer: UITapGestureRecognizer) {
        if recognizer.view == self {
            showHandles = true
        } else {
            showHandles = false
            self.endEditing(true)
        }
        
    }
    
    @objc func handleRotation(recognizer: UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
            self.updateDragHandles()
        }
    }
    
    @objc func handleTextSize(recognizer: UIPinchGestureRecognizer) {
        let currentFontSize = self.font?.pointSize
        var newScale = currentFontSize! * recognizer.scale
        if (newScale < 20.0) {
            newScale = 20.0;
        }
        if (newScale > 60.0) {
            newScale = 60.0;
        }
        
        self.font = UIFont(name: "Helvetica", size:  newScale)
        
        recognizer.scale = 1
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateDragHandles() {
        topLeft.center = self.transformedTopLeft()
        topRight.center = self.transformedTopRight()
        bottomLeft.center = self.transformedBottomLeft()
        bottomRight.center = self.transformedBottomRight()
        rotateHandle.center = self.transformedRotateHandle()
    }
    
    //MARK: - Gesture Methods
    
    @objc func handleMove(_ gesture:UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview!)
        
        var center = self.center
        center.x += translation.x
        center.y += translation.y
        self.center = center
        
        gesture.setTranslation(CGPoint.zero, in: self.superview!)
        updateDragHandles()
    }
    
    func angleBetweenPoints(_ startPoint:CGPoint, endPoint:CGPoint)  -> CGFloat {
        let a = startPoint.x - self.center.x
        let b = startPoint.y - self.center.y
        let c = endPoint.x - self.center.x
        let d = endPoint.y - self.center.y
        let atanA = atan2(a, b)
        let atanB = atan2(c, d)
        return atanA - atanB
        
    }
    
    func drawRotateLine(_ fromPoint:CGPoint, toPoint:CGPoint) {
        let linePath = UIBezierPath()
        linePath.move(to: fromPoint)
        linePath.addLine(to: toPoint)
        rotateLine.path = linePath.cgPath
        rotateLine.fillColor = nil
        rotateLine.strokeColor = UIColor.orange.cgColor
        rotateLine.lineWidth = 2.0
        rotateLine.opacity = 1.0
    }
    
    @objc func handleRotate(_ gesture:UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            previousLocation = rotateHandle.center
            self.drawRotateLine(CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2), toPoint:CGPoint(x: self.bounds.size.width + diameter, y: self.bounds.size.height/2))
        case .ended:
            self.rotateLine.opacity = 0.0
        default:()
        }
        let location = gesture.location(in: self.superview!)
        let angle = angleBetweenPoints(previousLocation, endPoint: location)
        self.transform = self.transform.rotated(by: angle)
        previousLocation = location
        self.updateDragHandles()
    }
    
    @objc func handlePan(_ gesture:UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        switch gesture.view! {
        case topLeft:
            if gesture.state == .began {
                self.setAnchorPoint(CGPoint(x: 1, y: 1))
            }
            self.bounds.size.width -= translation.x
            self.bounds.size.height -= translation.y
        case topRight:
            if gesture.state == .began {
                self.setAnchorPoint(CGPoint(x: 0, y: 1))
            }
            self.bounds.size.width += translation.x
            self.bounds.size.height -= translation.y
            
        case bottomLeft:
            if gesture.state == .began {
                self.setAnchorPoint(CGPoint(x: 1, y: 0))
            }
            self.bounds.size.width -= translation.x
            self.bounds.size.height += translation.y
        case bottomRight:
            if gesture.state == .began {
                self.setAnchorPoint(CGPoint.zero)
            }
            self.bounds.size.width += translation.x
            self.bounds.size.height += translation.y
        default:()
        }
        
        gesture.setTranslation(CGPoint.zero, in: self)
        updateDragHandles()
        if gesture.state == .ended {
            self.setAnchorPoint(CGPoint(x: 0.5, y: 0.5))
        }
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // ColorSlider delegate
    func updateColor(_ color: UIColor?) {
        self.textColor = color
    }
    
}

/**
 extensions to UIView for ResizableView specifically
 */
extension UIView {
    func transformedTopLeft() -> CGPoint {
        let frame = self.originalFrame()
        let point = frame.origin
        return self.pointInTransformedView(point)
    }
    
    func transformedTopRight() -> CGPoint {
        let frame = self.originalFrame()
        var point = frame.origin
        point.x += frame.size.width
        return self.pointInTransformedView(point)
    }
    
    func transformedBottomRight() -> CGPoint {
        let frame = self.originalFrame()
        var point = frame.origin
        point.x += frame.size.width
        point.y += frame.size.height
        return self.pointInTransformedView(point)
    }
    
    func transformedBottomLeft() -> CGPoint {
        let frame = self.originalFrame()
        var point = frame.origin
        point.y += frame.size.height
        return self.pointInTransformedView(point)
    }
    
    func transformedRotateHandle() -> CGPoint {
        let frame = self.originalFrame()
        var point = frame.origin
        point.x += frame.size.width + 40
        point.y += frame.size.height / 2
        return self.pointInTransformedView(point)
    }
    
    func setAnchorPoint(_ anchorPoint:CGPoint) {
        var newPoint = CGPoint(x: self.bounds.size.width * anchorPoint.x, y: self.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint(x: self.bounds.size.width * self.layer.anchorPoint.x, y: self.bounds.size.height * self.layer.anchorPoint.y)
        
        newPoint = newPoint.applying(self.transform)
        oldPoint = oldPoint.applying(self.transform)
        
        var position = self.layer.position
        position.x -= oldPoint.x
        position.x += newPoint.x
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        self.layer.position = position
        self.layer.anchorPoint = anchorPoint
    }
    
    func offsetPointToParentCoordinates(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x + self.center.x, y: point.y + self.center.y)
    }
    
    func pointInViewCenterTerms(_ point:CGPoint) -> CGPoint {
        return CGPoint(x: point.x - self.center.x, y: point.y - self.center.y)
    }
    
    func pointInTransformedView(_ point: CGPoint) -> CGPoint {
        let offsetItem = self.pointInViewCenterTerms(point)
        let updatedItem = offsetItem.applying(self.transform)
        let finalItem = self.offsetPointToParentCoordinates(updatedItem)
        return finalItem
    }
    
    func originalFrame() -> CGRect {
        let currentTransform = self.transform
        self.transform = CGAffineTransform.identity
        let originalFrame = self.frame
        self.transform = currentTransform
        return originalFrame
    }
}




