//
//  SagittaSchematicViews.swift
//  pipeDimensions
//
//  Created on 2026-07-09.
//  Copyright © 2026 Nick Khotenko. All rights reserved.
//

import UIKit

// MARK: - Sagitta Schematic View

/// Custom view that draws a schematic showing buried pipe with sagitta and chord annotations
class SagittaSchematicView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let width = rect.width
        let height = rect.height
        let centerX = width / 2
        
        // Pipe circle parameters
        let radius = height * 0.52
        let centerY = height * 0.86
        let chordY = height * 0.62
        
        let arcTopY = centerY - radius
        let halfChord = sqrt(max(0, radius * radius - pow(centerY - chordY, 2)))
        let leftX = centerX - halfChord
        let rightX = centerX + halfChord
        
        // Colors
        let pipeColor: UIColor
        if #available(iOS 13.0, *) {
            pipeColor = UIColor.label.withAlphaComponent(0.8)
        } else {
            pipeColor = UIColor.black.withAlphaComponent(0.8)
        }
        let chordColor = UIColor.systemBlue
        let sagittaColor = UIColor.systemRed
        let odColor = UIColor.systemGreen
        let groundColor: UIColor
        if #available(iOS 13.0, *) {
            groundColor = UIColor.systemBrown
        } else {
            groundColor = UIColor.brown
        }
        
        // Draw ground fill below chord
        let groundFillColor: UIColor
        if #available(iOS 13.0, *) {
            groundFillColor = UIColor.systemBrown.withAlphaComponent(0.1)
        } else {
            groundFillColor = UIColor.brown.withAlphaComponent(0.1)
        }
        context.setFillColor(groundFillColor.cgColor)
        context.fill(CGRect(x: 0, y: chordY, width: width, height: height - chordY))
        
        // Draw dashed full circle (ghost)
        context.setStrokeColor(pipeColor.withAlphaComponent(0.2).cgColor)
        context.setLineWidth(1.0)
        context.setLineDash(phase: 0, lengths: [4, 3])
        context.addArc(center: CGPoint(x: centerX, y: centerY), radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        context.strokePath()
        context.setLineDash(phase: 0, lengths: [])
        
        // Draw visible arc (filled)
        let angleLeft = atan2(chordY - centerY, leftX - centerX)
        let angleRight = atan2(chordY - centerY, rightX - centerX)
        
        context.setFillColor(pipeColor.withAlphaComponent(0.08).cgColor)
        context.move(to: CGPoint(x: leftX, y: chordY))
        context.addArc(center: CGPoint(x: centerX, y: centerY), radius: radius, startAngle: angleLeft, endAngle: angleRight, clockwise: false)
        context.closePath()
        context.fillPath()
        
        // Draw visible arc (stroke)
        context.setStrokeColor(pipeColor.cgColor)
        context.setLineWidth(2.2)
        context.addArc(center: CGPoint(x: centerX, y: centerY), radius: radius, startAngle: angleLeft, endAngle: angleRight, clockwise: false)
        context.strokePath()
        
        // Draw ground line
        context.setStrokeColor(groundColor.cgColor)
        context.setLineWidth(1.4)
        context.move(to: CGPoint(x: 0, y: chordY))
        context.addLine(to: CGPoint(x: width, y: chordY))
        context.strokePath()
        
        // Draw ground hatching
        context.setStrokeColor(groundColor.withAlphaComponent(0.5).cgColor)
        context.setLineWidth(1.0)
        for i in 0...9 {
            let x = width * CGFloat(i) / 9
            context.move(to: CGPoint(x: x, y: chordY))
            context.addLine(to: CGPoint(x: x - 7, y: chordY + 9))
        }
        context.strokePath()
        
        // Draw OD double arrow
        let odArrowY = arcTopY - 10
        drawDoubleArrow(context: context, from: CGPoint(x: centerX - radius, y: odArrowY),
                       to: CGPoint(x: centerX + radius, y: odArrowY), color: odColor, lineWidth: 1.6)
        
        // Draw OD drop lines
        context.setStrokeColor(odColor.withAlphaComponent(0.3).cgColor)
        context.setLineWidth(1.0)
        for x in [centerX - radius, centerX + radius] {
            context.move(to: CGPoint(x: x, y: odArrowY))
            context.addLine(to: CGPoint(x: x, y: min(centerY, height)))
        }
        context.strokePath()
        
        // Draw OD label
        drawLabel(text: "OD", at: CGPoint(x: centerX, y: odArrowY - 12), color: odColor, fontSize: 10, bold: true, centered: true)
        
        // Draw chord double arrow
        let chordArrowY = chordY - 14
        drawDoubleArrow(context: context, from: CGPoint(x: leftX, y: chordArrowY),
                       to: CGPoint(x: rightX, y: chordArrowY), color: chordColor, lineWidth: 1.6)
        
        // Draw chord tick marks
        context.setStrokeColor(chordColor.cgColor)
        context.setLineWidth(1.2)
        for x in [leftX, rightX] {
            context.move(to: CGPoint(x: x, y: chordY - 6))
            context.addLine(to: CGPoint(x: x, y: chordY + 5))
        }
        context.strokePath()
        
        // Draw chord label
        drawLabel(text: "C", at: CGPoint(x: centerX + halfChord * 0.35, y: chordArrowY - 17), color: chordColor, fontSize: 10)
        
        // Draw sagitta double arrow
        drawDoubleArrow(context: context, from: CGPoint(x: centerX, y: chordY),
                       to: CGPoint(x: centerX, y: arcTopY), color: sagittaColor, lineWidth: 1.8)
        
        // Draw sagitta label
        let sagMidY = (chordY + arcTopY) / 2
        drawLabel(text: "S", at: CGPoint(x: centerX - 14, y: sagMidY - 12), color: sagittaColor, fontSize: 11, italic: true)
    }
    
    private func drawDoubleArrow(context: CGContext, from: CGPoint, to: CGPoint, color: UIColor, lineWidth: CGFloat) {
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(lineWidth)
        context.move(to: from)
        context.addLine(to: to)
        context.strokePath()
        
        drawArrowHead(context: context, at: from, pointingTo: to, color: color, lineWidth: lineWidth)
        drawArrowHead(context: context, at: to, pointingTo: from, color: color, lineWidth: lineWidth)
    }
    
    private func drawArrowHead(context: CGContext, at tip: CGPoint, pointingTo: CGPoint, color: UIColor, lineWidth: CGFloat) {
        let dx = tip.x - pointingTo.x
        let dy = tip.y - pointingTo.y
        let length = sqrt(dx * dx + dy * dy)
        guard length > 0 else { return }
        
        let ux = dx / length
        let uy = dy / length
        let arrowLength: CGFloat = 6
        let arrowWidth: CGFloat = 3
        
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(lineWidth)
        
        context.move(to: tip)
        context.addLine(to: CGPoint(x: tip.x - ux * arrowLength + uy * arrowWidth,
                                   y: tip.y - uy * arrowLength - ux * arrowWidth))
        context.strokePath()
        
        context.move(to: tip)
        context.addLine(to: CGPoint(x: tip.x - ux * arrowLength - uy * arrowWidth,
                                   y: tip.y - uy * arrowLength + ux * arrowWidth))
        context.strokePath()
    }
    
    private func drawLabel(text: String, at point: CGPoint, color: UIColor, fontSize: CGFloat, bold: Bool = false, italic: Bool = false, centered: Bool = false) {
        let font: UIFont
        if italic {
            font = UIFont.italicSystemFont(ofSize: fontSize)
        } else if bold {
            font = UIFont.boldSystemFont(ofSize: fontSize)
        } else {
            font = UIFont.systemFont(ofSize: fontSize)
        }
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]
        
        let string = NSAttributedString(string: text, attributes: attributes)
        let size = string.size()
        let drawPoint = centered ? CGPoint(x: point.x - size.width / 2, y: point.y - size.height / 2) : point
        string.draw(at: drawPoint)
    }
}

// MARK: - Live Pipe Schematic View

/// Custom view that draws a simple pipe circle with OD label, updated in real-time
class LivePipeSchematicView: UIView {
    
    private var odInches: Double = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }
    
    func updateOD(_ od: Double) {
        self.odInches = od
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let width = rect.width
        let height = rect.height
        let centerX = width / 2
        let centerY = height * 0.60  // Moved lower to give more space for label at top
        let radius = min(width * 0.32, height * 0.32)  // Slightly smaller to fit better
        
        let pipeColor = UIColor.systemBlue
        let odColor = UIColor.systemGreen
        
        // Draw pipe circle (filled)
        context.setFillColor(pipeColor.withAlphaComponent(0.1).cgColor)
        context.addArc(center: CGPoint(x: centerX, y: centerY), radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        context.fillPath()
        
        // Draw pipe circle (stroke)
        context.setStrokeColor(pipeColor.cgColor)
        context.setLineWidth(2.5)
        context.addArc(center: CGPoint(x: centerX, y: centerY), radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        context.strokePath()
        
        // Draw OD double arrow
        let odY = centerY - radius - 16
        drawDoubleArrow(context: context, from: CGPoint(x: centerX - radius, y: odY),
                       to: CGPoint(x: centerX + radius, y: odY), color: odColor, lineWidth: 1.6)
        
        // Draw OD drop lines
        context.setStrokeColor(odColor.withAlphaComponent(0.22).cgColor)
        context.setLineWidth(1.0)
        for x in [centerX - radius, centerX + radius] {
            context.move(to: CGPoint(x: x, y: odY))
            context.addLine(to: CGPoint(x: x, y: centerY))
        }
        context.strokePath()
        
        // Draw OD value label - positioned higher with more clearance
        let odText = "OD = \(String(format: "%.3f", odInches)) in  /  \(String(format: "%.1f", odInches * 25.4)) mm"
        drawLabel(text: odText, at: CGPoint(x: centerX, y: odY - 16), color: odColor, fontSize: 10.5, bold: true, centered: true)
    }
    
    private func drawDoubleArrow(context: CGContext, from: CGPoint, to: CGPoint, color: UIColor, lineWidth: CGFloat) {
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(lineWidth)
        context.move(to: from)
        context.addLine(to: to)
        context.strokePath()
        
        drawArrowHead(context: context, at: from, pointingTo: to, color: color, lineWidth: lineWidth)
        drawArrowHead(context: context, at: to, pointingTo: from, color: color, lineWidth: lineWidth)
    }
    
    private func drawArrowHead(context: CGContext, at tip: CGPoint, pointingTo: CGPoint, color: UIColor, lineWidth: CGFloat) {
        let dx = tip.x - pointingTo.x
        let dy = tip.y - pointingTo.y
        let length = sqrt(dx * dx + dy * dy)
        guard length > 0 else { return }
        
        let ux = dx / length
        let uy = dy / length
        let arrowLength: CGFloat = 6
        let arrowWidth: CGFloat = 3
        
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(lineWidth)
        
        context.move(to: tip)
        context.addLine(to: CGPoint(x: tip.x - ux * arrowLength + uy * arrowWidth,
                                   y: tip.y - uy * arrowLength - ux * arrowWidth))
        context.strokePath()
        
        context.move(to: tip)
        context.addLine(to: CGPoint(x: tip.x - ux * arrowLength - uy * arrowWidth,
                                   y: tip.y - uy * arrowLength + ux * arrowWidth))
        context.strokePath()
    }
    
    private func drawLabel(text: String, at point: CGPoint, color: UIColor, fontSize: CGFloat, bold: Bool = false, centered: Bool = false) {
        let font = bold ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]
        
        let string = NSAttributedString(string: text, attributes: attributes)
        let size = string.size()
        let drawPoint = centered ? CGPoint(x: point.x - size.width / 2, y: point.y - size.height / 2) : point
        string.draw(at: drawPoint)
    }
}
