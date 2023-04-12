
import SwiftUI

public struct ValueSliderView: View {
    @Binding var value: Double
    var valueFormat: String = "%.f"
    var isDisable: Bool = false
    var isHidden: Bool = false
    
    @State var lastCoordinateValue: CGFloat = 0.0
    var sliderRange: ClosedRange<Double> = 0...10
    var thumbColor: Color = .yellow
    var minTrackColor: Color = Color.gray80
    var maxTrackColor: Color = Color.gray40
    var thumbSize: CGFloat = 20.0
    var thumbPadding: CGFloat = 5
    var _barHeight: CGFloat = 10.0
    var font: Font = Font.kr11r
    var fontColor: Color = .black
    
    var barHeight: CGFloat {
        get {
            min(self._barHeight, self.thumbSize)
        }
    }
    var _width: CGFloat = UIScreen.main.bounds.size.width
    var width: CGFloat {
        get {
            min(UIScreen.main.bounds.size.width - thumbSize, self._width)
        }
    }
    
    
    @State private var textPos: CGRect = .zero
    @State private var thumbPos: CGRect = .zero
    @State var isOnDragging: Bool = false
    var dragCallback: (()->())? = nil
    var onEndCallback: (()->())? = nil
    var onStartCallback: (()->())? = nil
    
    public init(_ value: Binding<Double>) {
        self._value = value
    }
    
    public var body: some View {
        let minPos = 0.0
        let maxPos = width
        let minValue = sliderRange.lowerBound
        
        let radius: CGFloat = UIScreen.main.bounds.size.height * 0.5
        let unit = sliderRange.upperBound + abs(sliderRange.lowerBound)
        let unitWidth = width / unit
        let pos = unitWidth * (value - sliderRange.lowerBound)
        ZStack {
            //MaxBar
            VStack(alignment: .trailing, spacing: 0) {
                RoundedCorners(color: isDisable ? Color.gray60 : maxTrackColor, tl: 0.0, tr: radius, bl: 0.0, br: radius)
                    .frame(width: width - pos, height: barHeight, alignment: .trailing)
            }
            .frame(width: width, height: barHeight, alignment: .trailing)
            
            
            //MinBar
            VStack(alignment: .leading, spacing: 0) {
                RoundedCorners(color: isDisable ? Color.gray60 : minTrackColor, tl: radius, tr: 0.0, bl: radius, br: 0.0)
                    .frame(width: pos, height: barHeight)
            }
            .frame(width: width, height: barHeight, alignment: .leading)
            
            if !isDisable {
                HStack {
                    Circle()
                        .foregroundColor(thumbColor)
                        .frame(width: thumbSize, height: thumbSize)
                        .background(
                            Circle()
                                .foregroundColor(Color.clear)
                                .frame(width: thumbSize + thumbPadding, height: thumbSize + thumbPadding)
                                .contentShape(Rectangle())
                        )
                        .contentShape(Rectangle())
                        .offset(x: pos)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { v in
                                    if !isOnDragging {
                                        isOnDragging = true
                                        onStartCallback?()
                                    }
                                    if (abs(v.translation.width) < 0.1) {
                                        self.lastCoordinateValue = pos
                                    }
                                    if v.translation.width > 0 {
                                        let nextCoordinateValue = min(maxPos, self.lastCoordinateValue + v.translation.width)
                                        self.value = ((nextCoordinateValue - minPos) / unitWidth) + minValue
                                    } else {
                                        let nextCoordinateValue = max(minPos, self.lastCoordinateValue + v.translation.width)
                                        self.value = ((nextCoordinateValue - minPos) / unitWidth) + minValue
                                    }
                                    dragCallback?()
                                }
                                .onEnded { v in
                                    isOnDragging = false
                                    onEndCallback?()
                                }
                        )
                    Spacer()
                }
                .zIndex(2)
                .contentShape(Rectangle())
            } else {
                HStack {
                    RoundedRectangle(cornerRadius: radius)
                        .foregroundColor(Color.gray)
                        .frame(width: thumbSize, height: thumbSize)
                        .offset(x: pos)
                    Spacer()
                }
                .zIndex(1)
            }
            HStack {
                if !isHidden {
                    if !isDisable {
                        Text(String(format: valueFormat, $value.wrappedValue))
                            .font(font)
                            .foregroundColor(isDisable ? Color.gray60 : fontColor)
                            .offset(x: pos - ($textPos.wrappedValue.size.width/2 - thumbSize/2))
                            .padding(.bottom, thumbSize * 2 + 6)
                            .rectReader($textPos, in: .global)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { v in
                                        if !isOnDragging {
                                            isOnDragging = true
                                            onStartCallback?()
                                        }
                                        if (abs(v.translation.width) < 0.1) {
                                            self.lastCoordinateValue = pos
                                        }
                                        if v.translation.width > 0 {
                                            let nextCoordinateValue = min(maxPos, self.lastCoordinateValue + v.translation.width)
                                            self.value = ((nextCoordinateValue - minPos) / unitWidth) + minValue
                                        } else {
                                            let nextCoordinateValue = max(minPos, self.lastCoordinateValue + v.translation.width)
                                            self.value = ((nextCoordinateValue - minPos) / unitWidth) + minValue
                                        }
                                        dragCallback?()
                                    }
                                    .onEnded { v in
                                        isOnDragging = false
                                        onEndCallback?()
                                    }
                            )
                        
                    } else {
                        Text(String(format: valueFormat, $value.wrappedValue))
                            .font(font)
                            .foregroundColor(isDisable ? Color.gray60 : fontColor)
                            .offset(x: pos - ($textPos.wrappedValue.size.width/2 - thumbSize/2))
                            .padding(.bottom, thumbSize * 2 + 6)
                            .rectReader($textPos, in: .global)
                    }
                }
                Spacer()
            }
        }
        .frame(width: width + thumbSize, alignment: .center)
        .contentShape(Rectangle())
    }
}

struct RoundedCorners: View {
    var color: Color = .blue
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                
                let w = geometry.size.width
                let h = geometry.size.height
                
                // Make sure we do not exceed the size of the rectangle
                let tr = min(min(self.tr, h/2), w/2)
                let tl = min(min(self.tl, h/2), w/2)
                let bl = min(min(self.bl, h/2), w/2)
                let br = min(min(self.br, h/2), w/2)
                
                path.move(to: CGPoint(x: w / 2.0, y: 0))
                path.addLine(to: CGPoint(x: w - tr, y: 0))
                path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
                path.addLine(to: CGPoint(x: w, y: h - br))
                path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
                path.addLine(to: CGPoint(x: bl, y: h))
                path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
                path.addLine(to: CGPoint(x: 0, y: tl))
                path.addArc(center: CGPoint(x: tl, y: tl), radius: tl, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
                path.closeSubpath()
            }
            .fill(self.color)
        }
    }
}


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
        slider.font = font ?? Font.kr11r
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

extension Color {
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
    
    public static let gray80: Color = Color(hex: "#454545", opacity: 0.8)
    public static let gray60: Color = Color(hex: "#454545", opacity: 0.6)
    public static let gray40: Color = Color(hex: "#454545", opacity: 0.4)
    public static let gray30: Color = Color(hex: "#454545", opacity: 0.3)
    public static let gray20: Color = Color(hex: "#454545", opacity: 0.2)
}

extension Font {
    public static let kr11r: Font = .system(size: 11, weight: .regular, design: .default)
}

extension View {
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
