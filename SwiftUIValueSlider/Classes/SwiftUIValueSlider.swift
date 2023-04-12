
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
