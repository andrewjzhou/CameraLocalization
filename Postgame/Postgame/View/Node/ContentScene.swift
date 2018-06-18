//
//  ContentScene.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 6/14/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import ARKit

class ContentScene: SKScene {
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
        
        self.addChild(contentNode)
        self.addChild(whiteNode)
        self.addChild(promptNode)
        self.addChild(loadNode)
        activate()
       
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
    
    func deactivate() {
        contentNode = createChildNode(image: UIImage.from(color: .white), name: "content") // for testing
//        contentNode = createChildNode(image: UIImage.from(color: .clear), name: "content")
        activate()
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
