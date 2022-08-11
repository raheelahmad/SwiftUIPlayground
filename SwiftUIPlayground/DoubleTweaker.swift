//
//  DoubleTweaker.swift
//  SwiftUIPlayground
//
//  Created by Raheel Ahmad on 8/9/22.
//

import SwiftUI

struct ColorParam: Identifiable {
    @Binding var color: Color
    let name: String
    var id: String { name }
}

struct DoubleParam: Identifiable {
    @Binding var param: Double
    let range: ClosedRange<Double>
    let name: String

    var id: String { name }
    init(param: Binding<Double>, range: ClosedRange<Double>, name: String) {
        self._param = param
        self.name = name
        self.range = range
    }

    init(param: Binding<Int>, range: ClosedRange<Int>, name: String) {
        self._param = .init(get: {
            Double(param.wrappedValue)
        }, set: {
            param.wrappedValue = Int($0)
        })
        self.range = Double(range.lowerBound)...Double(range.upperBound)
        self.name = name
    }
}

struct DoubleTweakerView: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let title: String
    init(
        value: Binding<Double>,
        range: ClosedRange<Double>,
        title: String
    ) {
        self._value = value
        self.range = range
        self.title = title
    }

    init(
        value: Binding<Int>,
        range: ClosedRange<Int>,
        title: String
    ) {
        self._value = .init(get: {
            Double(value.wrappedValue)
        }, set: {
            value.wrappedValue = Int($0)
        })
        self.range = .init(uncheckedBounds: (Double(range.lowerBound), Double(range.upperBound)))
        self.title = title
    }

    var body: some View {
        VStack {
            Slider(value: $value, in: range, step: 0.1)
                .frame(width: 220)
            Text("\(title): \(nf.string(from: .init(value: value)) ?? "")")
                .font(.caption2)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.thinMaterial)
        )
    }
}

