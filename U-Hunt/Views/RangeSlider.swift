/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

class RangeSlider: UIControl {
    // MARK: - Properties
    var minimumValue: CGFloat = 0.05 {
        didSet {
            updateLayerFrames()
        }
    }
    
    var maximumValue: CGFloat = 0.95 {
        didSet {
            updateLayerFrames()
        }
    }
    
    var lowerValue: CGFloat = 0.05 {
        didSet {
            updateLayerFrames()
        }
    }
    
    var upperValue: CGFloat = 0.95 {
        didSet {
            updateLayerFrames()
        }
    }
    
    var trackTintColor = #colorLiteral(red: 0.716748178, green: 0.7173008919, blue: 0.7168337703, alpha: 1) {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    
    var trackHighlightTintColor = #colorLiteral(red: 0.9973543286, green: 0.7540413737, blue: 0.01105707698, alpha: 1) {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    
    var thumbImage = #imageLiteral(resourceName: "circle") {
        didSet {
            upperThumbImageView.image = thumbImage
            lowerThumbImageView.image = thumbImage
            updateLayerFrames()
        }
    }
    
    var highlightedThumbImage = #imageLiteral(resourceName: "highlightedCircle") {
        didSet {
            upperThumbImageView.highlightedImage = highlightedThumbImage
            lowerThumbImageView.highlightedImage = highlightedThumbImage
            updateLayerFrames()
        }
    }
    
    private let trackLayer = RangeSliderTrackLayer()
    private let lowerThumbImageView = UIImageView()
    private let upperThumbImageView = UIImageView()
    
    private var previousLocation = CGPoint()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        trackLayer.rangeSlider = self
        trackLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(trackLayer)
        
        lowerThumbImageView.image = thumbImage
        addSubview(lowerThumbImageView)
        
        upperThumbImageView.image = thumbImage
        addSubview(upperThumbImageView)
    }
    
    override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 1. Center the trackLayer and calculate the thumbs’ positions using thumbOriginForValue(_:).
    private func updateLayerFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        trackLayer.frame = bounds.insetBy(dx: 0.0, dy: bounds.height / 2.15)
        trackLayer.setNeedsDisplay()
        lowerThumbImageView.frame = CGRect(origin: thumbOriginForValue(lowerValue),
                                           size: thumbImage.size)
        upperThumbImageView.frame = CGRect(origin: thumbOriginForValue(upperValue),
                                           size: thumbImage.size)
        
        CATransaction.commit()
    }
    // 2. Scale the given value to the bound’s context.
    func positionForValue(_ value: CGFloat) -> CGFloat {
        return bounds.width * value
    }
    // 3. Return the position so that the thumb is centered given the scaled value.
    private func thumbOriginForValue(_ value: CGFloat) -> CGPoint {
        let x = positionForValue(value) - thumbImage.size.width / 2.0
        return CGPoint(x: x, y: (bounds.height - thumbImage.size.height) / 2.0)
    }
}

extension RangeSlider {
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        // 1. Translate the touch event into the control’s coordinate space
        previousLocation = touch.location(in: self)
        
        // 2. Check each thumb view to see whether the touch was within its frame.
        if lowerThumbImageView.frame.contains(previousLocation) {
            lowerThumbImageView.isHighlighted = true
        } else if upperThumbImageView.frame.contains(previousLocation) {
            upperThumbImageView.isHighlighted = true
        }
        
        // 3. The return value informs the UIControl superclass whether subsequent touches should be tracked. Tracking touch events continues if either thumb is highlighted.
        return lowerThumbImageView.isHighlighted || upperThumbImageView.isHighlighted
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        // 1. Calculate a delta location, which determines the number of points the user’s finger traveled. Then convert it into a scaled delta value based on the minimum and maximum values of the control.

        let deltaLocation = location.x - previousLocation.x
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / bounds.width
        
        previousLocation = location
        
        // 2. Adjust the upper or lower values based on where the user drags the slider to.

        if lowerThumbImageView.isHighlighted {
            lowerValue += deltaValue
            lowerValue = boundValue(lowerValue, toLowerValue: minimumValue,
                                    upperValue: upperValue)
        } else if upperThumbImageView.isHighlighted {
            upperValue += deltaValue
            upperValue = boundValue(upperValue, toLowerValue: lowerValue,
                                    upperValue: maximumValue)
        }
        
        sendActions(for: .valueChanged)
        
        return true
    }
    
    // 4. Clamp the passed in value so it’s within the specified range.

    private func boundValue(_ value: CGFloat, toLowerValue lowerValue: CGFloat,
                            upperValue: CGFloat) -> CGFloat {
        return min(max(value, lowerValue), upperValue)
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        lowerThumbImageView.isHighlighted = false
        upperThumbImageView.isHighlighted = false
    }
}
