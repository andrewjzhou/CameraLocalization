//
//  ContentNode.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 6/18/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import ARKit
import NVActivityIndicatorView

final class ContentNode: SCNNode {
    private let activityInd: NVActivityIndicatorView = {
        let edgeLength = UIScreen.main.bounds.height
        let activityInd = NVActivityIndicatorView(frame: CGRect(x: 0,
                                                                y: 0,
                                                                width: edgeLength,
                                                                height: edgeLength),
                                                  type: NVActivityIndicatorType.pacman,
                                                  color: .flatWhite,
                                                  padding: 0.2 * edgeLength)
        activityInd.backgroundColor = UIColor.flatBlack

        return activityInd
    }()
    
    private let promptView: UIView = {
        let edgeLength = UIScreen.main.bounds.height
        let container = UIView(frame: CGRect(x: 0,
                                             y: 0,
                                             width: edgeLength,
                                             height: edgeLength))
        container.backgroundColor = UIColor.flatBlack.withAlphaComponent(0.8)
        let label = UILabel(frame: CGRect(x: 0,
                                          y: 0,
                                          width: edgeLength,
                                          height: edgeLength))
        container.addSubview(label)
        label.center = container.center
        label.text = " Tap!"
        label.textColor = .flatWhite
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: edgeLength / 5)
        
        return container
    }()
    
    private let retryView: UIView = {
        let edgeLength = UIScreen.main.bounds.height
        let container = UIView(frame: CGRect(x: 0,
                                             y: 0,
                                             width: edgeLength,
                                             height: edgeLength))
        container.backgroundColor = UIColor.flatBlack.withAlphaComponent(0.8)
        let label = UILabel(frame: CGRect(x: 0,
                                          y: 0,
                                          width: edgeLength,
                                          height: edgeLength))
        container.addSubview(label)
        label.center = container.center
        label.numberOfLines = 2
        label.text = "Error :<\n Tap to Retry"
        label.textColor = .flatWhite
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: edgeLength / 5.5)
        
        return container
    }()
    
    private let imageView: UIImageView = {
        let edgeLength = UIScreen.main.bounds.height
        let iv = UIImageView(frame: CGRect(x: 0,
                                           y: 0,
                                           width: edgeLength,
                                           height: edgeLength))
        iv.contentMode = .scaleAspectFill
        iv.layer.borderColor = UIColor.flatBlack.cgColor
        iv.layer.borderWidth = 5
        return iv
    }()
    
    private let tagView: TagView = {
        let tag = TagView()
        tag.layer.cornerRadius = 5
        return tag
    }()
    
    
    private let containerView: UIView = {
        let edgeLength = UIScreen.main.bounds.height
        let view = UIView(frame: CGRect(x: 0,
                                           y: 0,
                                           width: edgeLength,
                                           height: edgeLength))
        view.backgroundColor = .flatBlack
        return view
    }()
    
    init(size: CGSize) {
        super.init()
        
        // Create the 3D plane geometry with the dimensions calculated from corners
        let planeGeometry = SCNPlane(width: size.width, height: size.height)
        planeGeometry.firstMaterial?.diffuse.contents = containerView
        
        containerView.addSubview(activityInd)
        containerView.addSubview(promptView)
        promptView.isHidden = true
        containerView.addSubview(imageView)
        addTagToImageView()
        containerView.addSubview(retryView)
        retryView.isHidden = true
        
        geometry = planeGeometry
        geometry?.firstMaterial?.colorBufferWriteMask = []

    }
    
    func updateSize(_ size: CGSize) {
        if let plane = self.geometry as? SCNPlane {
            plane.width = size.width
            plane.height = size.height
        }
    }
    
    func activate() {
        if activityInd.isAnimating { activityInd.stopAnimating() }
        geometry?.firstMaterial?.colorBufferWriteMask = defaultMask
        containerView.bringSubview(toFront: imageView)
        promptView.isHidden = true
        retryView.isHidden = true
    }
    
    func deactivate() { geometry?.firstMaterial?.colorBufferWriteMask = [] }
    
    func prompt() {
        promptView.isHidden = false
        retryView.isHidden = true
        if activityInd.isAnimating { activityInd.stopAnimating() }
        geometry?.firstMaterial?.colorBufferWriteMask = defaultMask
        containerView.bringSubview(toFront: promptView)
    }
    
    func retry() {
        promptView.isHidden = true
        retryView.isHidden = false
        if activityInd.isAnimating { activityInd.stopAnimating() }
        geometry?.firstMaterial?.colorBufferWriteMask = defaultMask
        containerView.bringSubview(toFront: retryView)
    }
    
    func load() {
        containerView.bringSubview(toFront: activityInd)
        geometry?.firstMaterial?.colorBufferWriteMask = defaultMask
        activityInd.startAnimating()
    }
    
    
    
    func setImage(_ image: UIImage, username: String, timestamp: String) {
        imageView.image = image
        tagView.display(username: username, timestamp: timestamp)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addTagToImageView() {
        imageView.addSubview(tagView)
        tagView.translatesAutoresizingMaskIntoConstraints = false
        tagView.setTrailingConstraint(equalTo: imageView.trailingAnchor,
                                      offset: -imageView.layer.borderWidth)
        tagView.setBottomConstraint(equalTo: imageView.bottomAnchor, offset: 0)
        tagView.setWidthConstraint(imageView.bounds.width * 0.27)
        let height = imageView.bounds.height * 0.05
        tagView.setHeightConstraint(height)
        tagView.font = UIFont.systemFont(ofSize: height * 0.4)
    }
}

fileprivate let defaultMask = SCNColorMask(rawValue: 15)
