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
    func setuplongPressSubject() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(observeLongPress(sender:)))
        view.addGestureRecognizer(longPress)
    }
    @objc private func observeLongPress(sender: UILongPressGestureRecognizer) {
        longPressSubject.onNext(sender)
        
        // Refresh Cache (Consider if this is overdone/expensive
        // TODO: let cache finish refreshing before continuing to create Post Node. Attempting to create Post Node before reresh completes risks duplicate error
        if sender.state == .began && createButton.post != nil {
            descriptorCache!.refresh()
        }
        
        // Delete placeholders when user is trying to select
        if sender.state.isActive{
            let point = sender.location(in: sceneView)
         
            // Animate long press indicator
            longPressIndicator.center = point
            longPressIndicator.isHidden = false
            if point.isOnVerticalPlane(in: sceneView) {
                longPressIndicator.pulsate = true
            } else {
                longPressIndicator.pulsate = false
            }
            
            let scnHitTestResults = sceneView.hitTest(point, options: nil)
            guard let postNode = scnHitTestResults.first?.node.parent as? PostNode else {return}
            
            if postNode.state == .inactive {
                postNode.removeFromParentNode()
            }
            
            
        } else {
            print("Test4")
            longPressIndicator.isHidden = true
        }
        
    }
    
    func setupPostNodeInteractions() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        sceneView.addGestureRecognizer(tap)
    }
    
    @objc func handleTap (sender: UILongPressGestureRecognizer) {
        // Perform hit-test at tapped location
        let point = sender.location(in: sceneView)
        let scnHitTestResults = sceneView.hitTest(point, options: nil)
        guard let postNode = scnHitTestResults.first?.node.parent as? PostNode else {return}
        
        if postNode.state == .prompt && createButton.post != nil {
            postNode.setContent(createButton.post!)
            createButton.sendActions(for: .touchUpInside)
            postNode.record()
        } else if postNode.state == .prompt && createButton.post == nil {
            postNode.optOutPrompt()
        } else if postNode.state == .active && createButton.post != nil {
            postNode.prompt()
        }
    }
}
