//
//  ParamsView.swift
//  SwiftUIPlayground
//
//  Created by Raheel Ahmad on 8/8/22.
//

import SwiftUI

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

struct ParamsView: View {
    var doubles: [DoubleParam]
    @State var showingDoubles: [Bool]

    init(doubles: [DoubleParam]) {
        self.doubles = doubles
        self.showingDoubles = .init(repeating: false, count: doubles.count)
    }

    var body: some View {
        ZStack {
            VStack {
                ForEach(doubles.indices, id: \.self) { index in
                    Button {
                        withAnimation { showingDoubles[index] = true }
                    } label: {
                        HStack {
                            Text(doubles[index].name)
                                .font(.caption)
                            Spacer()
                                .overlay(
                                    VStack {
                                        Spacer()
                                        Rectangle().frame(height: 0.5)
                                    }
                                        .opacity(0.8)
                                        .padding(.horizontal, 4)
                                )
                            Text(
                                nf.string(from: .init(value: doubles[index].param))!
                            )
                        }
                    }.frame(maxWidth: 190)
                }
            }


            ForEach(doubles.indices, id: \.self) { index in
                if showingDoubles[index] {
                    ClosableContainer(
                        content: DoubleTweakerView(
                            value: doubles[index].$param,
                            range: doubles[index].range,
                            title: doubles[index].name
                        ),
                        showing: $showingDoubles[index]
                    )
                }
            }
        }
    }
}
