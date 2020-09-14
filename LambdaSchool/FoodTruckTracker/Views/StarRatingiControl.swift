//
//  StarRatingiControl.swift
//  FoodTruckTracker
//
//  Created by Michael on 3/25/20.
//  Copyright © 2020 Michael. All rights reserved.
//

import UIKit

class StarRatingControl: UIControl {
    
    private let componentDimension: CGFloat = 60.0
    
    private let componentCount = 5
    
    private let componentActiveColor = UIColor.yellow
    //        UIColor.init(red: 0.1986209262, green: 0.8029425761, blue: 0.4024934892, alpha: 1)
    
    private let componentInactiveColor = UIColor.gray
    
    var value: Int = 1
    
    private var starLabels: [UILabel] = []
    
    override var intrinsicContentSize: CGSize {
        let componentsWidth = CGFloat(componentCount) * componentDimension
        let componentsSpacing = CGFloat(componentCount + 1) * 8.0
        let width = componentsWidth + componentsSpacing
        return CGSize(width: width, height: componentDimension)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        for index in 1...componentCount {
            let label = UILabel()
            label.tag = index
            label.viewWithTag(1)?.frame = CGRect(x: 0, y: 0, width: componentDimension, height: componentDimension)
            label.viewWithTag(2)?.frame = CGRect(x: componentDimension + 5, y: 0, width: componentDimension, height: componentDimension)
            label.viewWithTag(3)?.frame = CGRect(x: componentDimension * 2 + 10, y: 0, width: componentDimension, height: componentDimension)
            label.viewWithTag(4)?.frame = CGRect(x: componentDimension * 3 + 15, y: 0, width: componentDimension, height: componentDimension)
            label.viewWithTag(5)?.frame = CGRect(x: componentDimension * 4 + 20, y: 0, width: componentDimension, height: componentDimension)
            label.font = UIFont.systemFont(ofSize: 40.0, weight: .bold)
            label.text = "☆"
            if label.tag == 1 {
                label.textColor = componentActiveColor
            } else {
                label.textColor = componentInactiveColor
            }
            addSubview(label)
            starLabels.append(label)
            
        }
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        updateValue(at: touch)
        return true
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let touchPoint = touch.location(in: self)
        if bounds.contains(touchPoint) {
            updateValue(at: touch)
            sendActions(for: [.touchUpInside, .touchDragInside])
        } else {
            sendActions(for: [.touchUpOutside, .touchDragOutside])
        }
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        defer { super.endTracking(touch, with: event) }
        guard let touch = touch else { return }
        let touchPoint = touch.location(in: self)
        
        if bounds.contains(touchPoint) {
            updateValue(at: touch)
            sendActions(for: [.touchUpInside, .touchDragInside])
        } else {
            sendActions(for: [.touchUpOutside, .touchDragOutside])
        }
    }
    
    override func cancelTracking(with event: UIEvent?) {
        sendActions(for: .touchCancel)
    }
    
    func updateValue(at touch: UITouch) {
        let touchPoint = touch.location(in: self)
        for label in starLabels {
            if label.frame.contains(touchPoint) {
                value = label.tag
                label.performFlare()
                sendActions(for: [.valueChanged])
            }
            if label.tag <= value {
                label.textColor = componentActiveColor
                label.performFlare()
                label.text = "★"
            } else {
                label.textColor = componentInactiveColor
                label.text = "☆"
            }
        }
    }
}

extension UIView {
    // "Flare view" animation sequence
    func performFlare() {
        func flare()   { transform = CGAffineTransform(scaleX: 1.6, y: 1.6) }
        func unflare() { transform = .identity }
        
        UIView.animate(withDuration: 0.3,
                       animations: { flare() },
                       completion: { _ in UIView.animate(withDuration: 0.1) { unflare() }})
    }
}
