//
//  ViewController+Gesture.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 6/15/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import ARKit
import RxSwift
import RxCocoa

extension ViewController {
    
    // Use long press to select real-world vertical rectangles
    func setuplongPress() {
        // Long Press Indicator (hide when view loads)
        view.addSubview(longPressIndicator)
        longPressIndicator.isHidden = true
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(observeLongPress(sender:)))
        view.addGestureRecognizer(longPress)
    }
    
    @objc private func observeLongPress(sender: UILongPressGestureRecognizer) {
        
        // Refresh Cache
        // Consider if this is overdone/expensive
        // TODO: let cache finish refreshing before continuing to create Post Node. Attempting to create Post Node before reresh completes risks duplicate error
//        if sender.state == .began && createButton.post != nil {
//            descriptorCache.refresh()
//        }
        
        
        // Animate long press and delete inactive post nodes
        if sender.state.isActive{
            let point = sender.location(in: sceneView)
         
            // Animate long press indicator
            longPressIndicator.isHidden = false
            longPressIndicator.center = point
            longPressIndicator.isOnPlane = sceneView.isPointOnPlane(point)
            
            // Delete inactive post nodes touched by long press
            let scnHitTestResults = sceneView.hitTest(point, options: nil)
            guard let postNode = scnHitTestResults.first?.node.parent as? PostNode else {return}
            if postNode.state == .inactive {
                postNode.removeFromParentNode()
            }
        } else {
            longPressIndicator.isHidden = true
        }

    }
    
    // Use tap to interact with post nodes
    func setupPostNodeInteractions() {
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(handleTap(sender:)))
        sceneView.addGestureRecognizer(tap)
    }
    
    @objc func handleTap (sender: UILongPressGestureRecognizer) {
        // Select post node that is tapped
        let point = sender.location(in: sceneView)
        let scnHitTestResults = sceneView.hitTest(point, options: nil)
        guard let postNode = scnHitTestResults.first?.node.parent as? PostNode else {return}
        
        
        if postNode.state == .prompt && createButton.post != nil { // Adding / Updating
            // Do NOT switch function orders inside scope without purpose
            
            // Add created image to current post node
            postNode.setContentAndRecord(image: createButton.post!, location: lastLocation!)
            
            // cache image
            imageCache.setObject(createButton.post!, forKey: postNode.recorder.id! as NSString)
            
            // refresh descriptor cache
            descriptorCache.refresh()
            
            // Exist posting mode
            createButton.sendActions(for: .touchUpInside)
            
        } else if postNode.state == .prompt && createButton.post == nil { // Cancelling
            // Exit prompt state
            postNode.optOutPrompt()
            
        } else if postNode.state == .active && createButton.post != nil { // Choosing
            // Enter prompt state
            postNode.prompt()
            
        }
    }
    
    // Dismiss UserView when swipped up
    @objc func handleUserViewSwipe (sender: UISwipeGestureRecognizer) {
        UIView.animate(withDuration: 0.5, animations: {
            self.userView.transform = CGAffineTransform(translationX: 0, y: -UIScreen.main.bounds.height)
        }) { (_) in
//            self.userView.countView.alpha = 0
        }
    }
}
