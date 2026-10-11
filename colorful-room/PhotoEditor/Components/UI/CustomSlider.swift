//
//  CustomSlider.swift
//  colorful-room
//
//  Created by macOS on 7/15/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI



struct FilterSlider : View {
    
    var lable: String
    var defaultValue: Double
    @Binding var value: Double
    var range: (Double, Double)
    var rangeDisplay: (Double, Double)
    var spacing: CGFloat
    
    init(value: Binding<Double>, range: (Double, Double) = (0, 1), lable: String = "", defaultValue: Double = 0, rangeDisplay: (Double, Double) = (-100, 100), spacing: CGFloat = 4) {
        _value = value
        self.range = range
        self.lable = lable
        self.defaultValue = defaultValue
        self.rangeDisplay = rangeDisplay
        self.spacing = spacing
    }
    
    var body: some View {
        VStack(spacing: spacing) {
            HStack {
                if !lable.isEmpty {
                    Text(lable)
                }
                Spacer()
                Text(displayValue(self.value))
            }
            .font(.system(size: 11, weight: .regular))
            
            CustomSlider(value: $value, defaultValue: defaultValue, range: range)
                .frame(height: 28)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(lable.isEmpty ? "Adjustment" : lable)
        .accessibilityValue(displayValue(self.value))
    }
    
    func displayValue(_ value: Double) -> String {
        return String(format: "%.0f", value.convert(fromRange: range, toRange: rangeDisplay))
    }
}

struct CustomSlider: View {
    @Binding var value: Double
    var defaultValue: Double = 0
    var range: (Double, Double) = (0, 1)
    var knobDiameter: CGFloat = 20
    var dotDiameter: CGFloat = 5
    
    var body: some View {
        GeometryReader { geometry in
            let sliderWidth = geometry.size.width
            let travel = max(1, sliderWidth - knobDiameter)
            let valueSpan = range.1 - range.0
            
            let valueFraction = valueSpan != 0 ? min(max((value - range.0) / valueSpan, 0), 1) : 0.5
            let knobX = (knobDiameter / 2) + CGFloat(valueFraction) * travel
            
            let defaultFraction = valueSpan != 0 ? min(max((defaultValue - range.0) / valueSpan, 0), 1) : 0.5
            let dotX = (knobDiameter / 2) + CGFloat(defaultFraction) * travel
            
            let drag = DragGesture(minimumDistance: 0)
                .onChanged { gesture in
                    updateValue(location: gesture.location.x, travel: travel)
                }
                .onEnded { gesture in
                    updateValue(location: gesture.location.x, travel: travel)
                }
            
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.primary.opacity(0.3))
                    .frame(height: 2)
                    .frame(maxWidth: .infinity)
                
                // Default dot
                Circle()
                    .fill(Color(uiColor: .tertiaryLabel))
                    .frame(width: dotDiameter, height: dotDiameter)
                    .offset(x: dotX - dotDiameter / 2)
                
                // Knob
                ZStack {
                    Circle()
                        .fill(Color(uiColor: .systemBackground))
                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                    Circle()
                        .stroke(Color(uiColor: .separator), lineWidth: 0.5)
                }
                .frame(width: knobDiameter, height: knobDiameter)
                .glassEffect(.regular, in: .circle)
                .offset(x: knobX - knobDiameter / 2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .highPriorityGesture(drag)
        }
    }
    
    private func updateValue(location: CGFloat, travel: CGFloat) {
        let valueSpan = range.1 - range.0
        guard valueSpan != 0 else { return }
        let clampedX = min(max(location, knobDiameter / 2), knobDiameter / 2 + travel)
        let fraction = Double((clampedX - knobDiameter / 2) / travel)
        let newValue = range.0 + fraction * valueSpan
        self.value = newValue
    }
}

extension Double {
    func convert(fromRange: (Double, Double), toRange: (Double, Double)) -> Double {
        guard fromRange.1 != fromRange.0 else { return toRange.0 }
        var value = self
        value -= fromRange.0
        value /= Double(fromRange.1 - fromRange.0)
        value *= toRange.1 - toRange.0
        value += toRange.0
        return value
    }
}
