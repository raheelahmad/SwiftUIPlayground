//
//  ParamsView.swift
//  SwiftUIPlayground
//
//  Created by Raheel Ahmad on 8/8/22.
//

import SwiftUI

struct Col: Hashable, Equatable, Codable {
    var r: Double
    var g: Double
    var b: Double

    init(col: Color) {
        let uiCol = UIColor(col)
        let comps = uiCol.cgColor.components!
        r = Double(comps[0])
        g = Double(comps[1])
        b = Double(comps[2])
    }

    var color: Color {
        Color(red: r, green: g, blue: b)
    }
}

struct Cols: Hashable, Equatable, Codable {
    var topLeading: Col
    var bottomTrailing: Col
}

struct ParamsView: View {
    var doubles: [DoubleParam]
    var colors: [ColorParam]
    let leadingIndices: Range<Int>
    let trailingIndices: Range<Int>
    @State var showingDoubles: [Bool]
    @State var showingColors: [Bool]

    init(doubles: [DoubleParam], colors: [ColorParam] = []) {
        self.doubles = doubles
        self.colors = colors
        self.showingDoubles = .init(repeating: false, count: doubles.count)
        self.showingColors = .init(repeating: false, count: colors.count)
        let middle = self.doubles.count/2 + 1
        self.leadingIndices = 0..<middle
        self.trailingIndices = middle..<doubles.count
    }

    func column(_ indices: Range<Int>) -> some View {
        VStack {
            ForEach(indices, id: \.self) { index in
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
                }
            }
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 8) {
                HStack(alignment: .top, spacing: 12) {
                    column(leadingIndices)
                    column(trailingIndices)
                }

                ForEach(colors.indices, id: \.self) { idx in
                    HStack {
                        Text(colors[idx].name)
                            .font(.caption)
                            .foregroundColor(.blue)
                        Spacer()
                            .overlay(
                                VStack {
                                    Spacer()
                                    Rectangle().frame(height: 0.5)
                                }
                                    .opacity(0.8)
                                    .padding(.horizontal, 4)
                            )

                        ColorPicker("", selection: colors[idx].$color)
                            .fixedSize()
                    }
                }

            }.frame(minHeight: 180)

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


            ForEach(colors.indices, id: \.self) { index in
                if showingColors[index] {
                    ClosableContainer(
                        content: ColorPicker(colors[index].name, selection: colors[index].$color),
                        showing: $showingColors[index]
                    )
                }
            }
        }
    }
}
