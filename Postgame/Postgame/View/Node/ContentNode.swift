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
    var content: ContentScene = UIImage.from(color: .clear).convertToScene() {
        didSet{
            self.geometry?.firstMaterial?.diffuse.contents = content
        }
    }
    
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
        container.backgroundColor = UIColor.flatBlack.withAlphaComponent(0.9)
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
    
    private let imageView: UIImageView = {
        let edgeLength = UIScreen.main.bounds.height
        let iv = UIImageView(frame: CGRect(x: 0,
                                           y: 0,
                                           width: edgeLength,
                                           height: edgeLength))
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let containerView: UIView = {
        let edgeLength = UIScreen.main.bounds.height
        let view = UIView(frame: CGRect(x: 0,
                                           y: 0,
                                           width: edgeLength,
                                           height: edgeLength))
        view.backgroundColor = .flatBlack
        let rotate = CGAffineTransform(rotationAngle: .pi)
        let flip = CGAffineTransform(scaleX: -1, y: 1)
        view.transform = rotate.concatenating(flip)
        return view
    }()
    
    init(size: CGSize) {
        super.init()
        
        // Create the 3D plane geometry with the dimensions calculated from corners
        let planeGeometry = SCNPlane(width: size.width, height: size.height)
       
        
        planeGeometry.firstMaterial?.diffuse.contents = containerView
        containerView.addSubview(activityInd)
//        activityInd.center = containerView.center
        containerView.addSubview(imageView)
        imageView.center = containerView.center
        containerView.addSubview(promptView)
        promptView.center = containerView.center
      
        
//        // Flip content horizontally for skscene in setImage()
//        planeGeometry.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(1,-1,1)
//        planeGeometry.firstMaterial?.diffuse.wrapT = SCNWrapMode.init(rawValue: 2)!
        
        self.geometry = planeGeometry

    }
    
    func updateSize(_ size: CGSize) {
        let plane = self.geometry as! SCNPlane
        plane.width = size.width
        plane.height = size.height
    }
    
    func activate() {
        if activityInd.isAnimating { activityInd.stopAnimating() }
        geometry?.firstMaterial?.colorBufferWriteMask = defaultMask
        containerView.bringSubview(toFront: imageView)
//        geometry?.firstMaterial?.diffuse.contents = containerView
//        content.activate()
    }
    
    func deactivate() {
//        geometry?.firstMaterial?.diffuse.contents = content
        geometry?.firstMaterial?.colorBufferWriteMask = []
    }
    
    func prompt() {
        if activityInd.isAnimating { activityInd.stopAnimating() }
        geometry?.firstMaterial?.colorBufferWriteMask = defaultMask
        containerView.bringSubview(toFront: promptView)
//        geometry?.firstMaterial?.diffuse.contents = promptView
//        content.prompt()
    }
    
    func load() {
//        geometry?.firstMaterial?.diffuse.contents = activityInd
        containerView.bringSubview(toFront: activityInd)
        geometry?.firstMaterial?.colorBufferWriteMask = defaultMask
        activityInd.startAnimating()
//        content.load()
    }
    
    func setImage(_ image: UIImage) {
        imageView.image = image
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate let defaultMask = SCNColorMask(rawValue: 15)
