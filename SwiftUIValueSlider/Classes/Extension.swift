//
//  Extension.swift
//  SwiftUIValueSlider
//
//  Created by Studio-SJ on 2023/04/12.
//

import Foundation
import SwiftUI

public extension ValueSliderView {
    /// This is a setting for the value of the slider.
    /// - Parameters:
    ///   - valueFormat: This is the format of the value (as a string format)
    ///   - isVisibleValue: This is whether to display the value on top of the slider or not.
    /// - Returns: ValueSliderView
    func values(valueFormat: String = "%.f", font: Font? = nil, fontColor: Color = .black, isHidden: Bool = false) -> ValueSliderView {
        var slider = self
        slider.valueFormat = valueFormat
        slider.isHidden = isHidden
        slider.fontColor = fontColor
        slider.font = font ?? Font.f11r
        return slider
    }
    
    /// Specify the color of the track.
    /// - Parameters:
    ///   - minTrackColor: This is the color of the track below the thumb.
    ///   - maxTrackColor: This is the color of the track above the thumb.
    /// - Returns: ValueSliderView
    func trackColor(minTrackColor: Color, maxTrackColor: Color) -> ValueSliderView {
        var slider = self
        slider.minTrackColor = minTrackColor
        slider.maxTrackColor = maxTrackColor
        return slider
    }
    
    /// This is a setting for the thumb.
    /// - Parameters:
    ///   - thumbSize: This is the color of the thumb.
    ///   - thumbColor: This is the size of the thumb.
    /// - Returns: ValueSliderView
    func thumb(thumbSize: CGFloat, thumbColor: Color) -> ValueSliderView {
        var slider = self
        slider.thumbSize = thumbSize
        slider.thumbColor = thumbColor
        return slider
        
    }
    
    /// Set the range of the slider.
    /// - Parameter sliderRange: This is the range of the slider. default value is 0...100
    /// - Returns: ValueSliderView
    func range(sliderRange: ClosedRange<Double>) -> ValueSliderView {
        var slider = self
        slider.sliderRange = sliderRange
        return slider
    }
    
    /// Set the closure that is called each time a drag occurs.
    /// - Parameter onDrag: This closure is called every time a drag occurs.
    /// - Returns: ValueSliderView
    func onDragging(_ onDrag: (()->())?) -> ValueSliderView {
        var slider = self
        slider.dragCallback = onDrag
        return slider
    }
    
    /// Set a closure that will be called when the drag is finished.
    /// - Parameter onEnd: It will be called when the drag is finished.
    /// - Returns: ValueSliderView
    func onEnded(_ onEnd: (()->())?) -> ValueSliderView {
        var slider = self
        slider.onEndCallback = onEnd
        return slider
    }
    
    /// Set a closure that will be called when the drag is started
    /// - Parameter onStart: It will be called when the drag is started.
    /// - Returns: ValueSliderView
    func onStart(_ onStart: (()->())?) -> ValueSliderView {
        var slider = self
        slider.onStartCallback = onStart
        return slider
    }
    
    /// This is whether the slider is enabled or not.
    /// - Parameter isDisable: If it is "true," then the slider cannot be used.
    /// - Returns: ValueSliderView
    func isDisable(_ isDisable: Bool) -> ValueSliderView {
        var slider = self
        slider.isDisable = isDisable
        return slider
    }
    
    /// This specifies the width and height of the slider bar. The height of the slider bar is smaller than the size of the thumb. If it is set larger than the thumb size, it will be automatically adjusted to the size of the thumb.
    /// - Parameters:
    ///   - width: This is the width of the slider bar
    ///   - height: This is the height of the slider bar.
    /// - Returns: ValueSliderView
    func sliderFrame(width: CGFloat? = nil, height: CGFloat? = nil) -> ValueSliderView {
        var slider = self
        slider._width = width ?? slider._width
        slider._barHeight = height ?? slider._barHeight
        return slider
    }
}

public extension Color {
    init(hex string: String, opacity: CGFloat? = nil) {
        var string: String = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if string.hasPrefix("#") {
            _ = string.removeFirst()
        }
        
        // Double the last value if incomplete hex
        if !string.count.isMultiple(of: 2), let last = string.last {
            string.append(last)
        }
        
        // Fix invalid values
        if string.count > 8 {
            string = String(string.prefix(8))
        }
        
        // Scanner creation
        let scanner = Scanner(string: string)
        
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        
        if string.count == 2 {
            let mask = 0xFF
            
            let g = Int(color) & mask
            
            let gray = Double(g) / 255.0
            
            
            if let opacity = opacity {
                self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: opacity)
            } else {
                self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: 1)
            }
        } else if string.count == 4 {
            let mask = 0x00FF
            
            let g = Int(color >> 8) & mask
            let a = Int(color) & mask
            
            let gray = Double(g) / 255.0
            let alpha = Double(a) / 255.0
            
            if let opacity = opacity {
                self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: opacity)
            } else {
                self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: alpha)
            }
        } else if string.count == 6 {
            let mask = 0x0000FF
            let r = Int(color >> 16) & mask
            let g = Int(color >> 8) & mask
            let b = Int(color) & mask
            
            let red = Double(r) / 255.0
            let green = Double(g) / 255.0
            let blue = Double(b) / 255.0
            
            if let opacity = opacity {
                self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
            } else {
                self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)
            }
            
        } else if string.count == 8 {
            let mask = 0x000000FF
            let r = Int(color >> 24) & mask
            let g = Int(color >> 16) & mask
            let b = Int(color >> 8) & mask
            let a = Int(color) & mask
            
            let red = Double(r) / 255.0
            let green = Double(g) / 255.0
            let blue = Double(b) / 255.0
            let alpha = Double(a) / 255.0
            
            if let opacity = opacity {
                self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
            } else {
                self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
            }
            
        } else {
            self.init(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
        }
    }
    
    static let gray80: Color = Color(hex: "#454545", opacity: 0.8)
    static let gray60: Color = Color(hex: "#454545", opacity: 0.6)
    static let gray40: Color = Color(hex: "#454545", opacity: 0.4)
    static let gray30: Color = Color(hex: "#454545", opacity: 0.3)
    static let gray20: Color = Color(hex: "#454545", opacity: 0.2)
}

public extension Font {
    static let f11r: Font = .system(size: 11, weight: .regular, design: .default)
}

public extension View {
    func rectReader(_ binding: Binding<CGRect>, in space: CoordinateSpace) -> some View {
        self.background(GeometryReader { (geometry) -> AnyView in
            let rect = geometry.frame(in: space)
            DispatchQueue.main.async {
                binding.wrappedValue = rect
            }
            return AnyView(Rectangle().fill(Color.clear))
        })
    }
}
