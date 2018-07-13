//
//  ContentScene.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 6/14/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import ARKit
import ChameleonFramework

final class ContentScene: SKScene {
    private let sceneSize = UIScreen.main.bounds.size
    
    private var contentNode: SKSpriteNode
    private var whiteNode: SKSpriteNode
    private var promptNode: SKSpriteNode
    private var loadNode: SKSpriteNode
    
    var image: UIImage
    
    init(_ image: UIImage) {
        self.image = image
        
        contentNode = createChildNode(image: image, name: "content")
        whiteNode = createChildNode(image: UIImage.from(color: .white), name: "white")
        promptNode = createChildNode(image: UIImage(named: "ic_add_circle_outline_white")!, name: "prompt")
        loadNode = createChildNode(image: UIImage(named: "ic_sentiment_very_satisfied_white")!, name: "load")
        
        super.init(size: sceneSize)
        
        // initialize child nodes
        addChild(contentNode)
        addChild(whiteNode)
        addChild(promptNode)
        addChild(loadNode)
        activate()
        
        // draw border
        drawBorder()
        
        // label
        let label = SKLabelNode()
        label.position = CGPoint(x: sceneSize.width * 0.97, y: sceneSize.height * 0.02)
        label.color = .yellow
        label.text = "@AndrewZhou"
        label.horizontalAlignmentMode = .right
        label.fontSize = sceneSize.width * 0.05
        addChild(label)
    }
    
    fileprivate let darken = SKAction.colorize(with: .black, colorBlendFactor: 0.5, duration: 0)
    fileprivate let undarken = SKAction.colorize(with: .black, colorBlendFactor: 0.0, duration: 0)
    
    func activate() {
        // Display content
        contentNode.run(undarken)
        contentNode.isHidden = false
        
        // Hide all other elements
        promptNode.isHidden = true
        whiteNode.isHidden = true
        loadNode.isHidden = true
    }

    func prompt() {
        // Darken content in background
        contentNode.run(darken)
        
        // Show prompt
        promptNode.isHidden = false
        
        // Hide other elements
        whiteNode.isHidden = true
        loadNode.isHidden = true
    }
    
    func load() {
        // Display loading screen with white background
        loadNode.isHidden = false
        whiteNode.isHidden = false
        whiteNode.run(darken)
        
        // Hide other elements
        promptNode.isHidden = true
        contentNode.isHidden = true
    }
    
    private func drawBorder() {
        let bl = CGPoint(x: 0, y: 0)
        let br = CGPoint(x: sceneSize.width, y: 0)
        let tl = CGPoint(x: 0, y: sceneSize.height)
        let tr = CGPoint(x: sceneSize.width, y: sceneSize.height)
        let line_path:CGMutablePath = CGMutablePath()
        line_path.addLines(between: [bl,br,tr,tl,bl])
        
        let shape = SKShapeNode()
        shape.path = line_path
        shape.strokeColor = .flatPowderBlueDark
        shape.lineWidth = 10
        addChild(shape)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate let sceneSize = UIScreen.main.bounds.size

fileprivate func createChildNode(image: UIImage, name: String) -> SKSpriteNode{
    let imageTexture = SKTexture(image: image.fixOrientation()!)
    let imageNode = SKSpriteNode(texture: imageTexture)
    imageNode.position = CGPoint(x: sceneSize.width / 2.0, y: sceneSize.height / 2.0)
    imageNode.size = sceneSize
    imageNode.name = name
    
    return imageNode
}

