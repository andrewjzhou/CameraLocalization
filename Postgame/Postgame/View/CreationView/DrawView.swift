//
//  DrawView.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 4/18/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit

class DrawView: UIView {
    private var lines : [Line] = []
    private var lastPoint : CGPoint?
    private var currentLine: Line?
    
    // isActive is true to draw
    var isActive = true
    
    // Line color (default is red)
    var color = UIColor.red.cgColor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        backgroundColor = UIColor.clear
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isActive {
            currentLine = Line(color: color)
            lines.append(currentLine!)
            lastPoint = touches.first?.location(in: self)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isActive {
            let newPoint = touches.first?.location(in: self)
            currentLine?.appendSegment(start: lastPoint!, end: newPoint!)
            lastPoint = newPoint
            
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setLineCap(.round)
        context?.setLineWidth(5)
        for line in lines {
            // draw the line
            for segment in line.segments {
                context?.beginPath()
                context?.move(to: segment.start!)
                context?.addLine(to: segment.end!)
                context?.setStrokeColor(line.color)
                context?.strokePath()
            }
        }
    }
    
    // Delete most recently drawn line
    func undo() {
        if !lines.isEmpty {
            lines.remove(at: lines.count - 1)
            setNeedsDisplay()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


fileprivate class Line {
    private(set) var color: CGColor
    var segments: [Segment] = []
    
    struct Segment {
        var start: CGPoint?
        var end: CGPoint?
        init(start: CGPoint, end: CGPoint) {
            self.start = start
            self.end = end
        }
    }
    
    init(color: CGColor) {
        self.color = color
    }
    
    func appendSegment(start: CGPoint, end: CGPoint) {
        let segment = Segment(start: start, end: end)
        segments.append(segment)
    }
}
