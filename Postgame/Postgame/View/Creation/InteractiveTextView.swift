//
//  InteractiveTextView.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/25/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit

class InteractiveTextView: UITextView, UIGestureRecognizerDelegate{

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        textAlignment = .center
        font = UIFont.systemFont(ofSize: 15)
        
        //add pan gesture
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        gestureRecognizer.delegate = self
        self.addGestureRecognizer(gestureRecognizer)
        
        //Enable multiple touch and user interaction for textfield
        self.isUserInteractionEnabled = true
        self.isMultipleTouchEnabled = true
        
        //add pinch gesture
        let pinchGesture = UIPinchGestureRecognizer(target: self, action:#selector(pinchRecognized(pinch:)))
        pinchGesture.delegate = self
        self.addGestureRecognizer(pinchGesture)
        
        //add rotate gesture.
        let rotate = UIRotationGestureRecognizer.init(target: self, action: #selector(handleRotate(recognizer:)))
        rotate.delegate = self
        self.addGestureRecognizer(rotate)
    }
    
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let translation = gestureRecognizer.translation(in: self.superview)
            
            // note: 'view' is optional and need to be unwrapped
            gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.superview)
        }
        
    }
    
    @objc func pinchRecognized(pinch: UIPinchGestureRecognizer) {
        
        if let view = pinch.view {
            view.transform = view.transform.scaledBy(x: pinch.scale, y: pinch.scale)
            pinch.scale = 1
        }
    }
    
    @objc func handleRotate(recognizer : UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
        }
    }
    
    //MARK:- UIGestureRecognizerDelegate Methods
    func gestureRecognizer(_: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
