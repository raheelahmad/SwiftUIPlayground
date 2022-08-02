//
//  ClothView.swift
//  SwiftUIPlayground
//
//  Created by Raheel Ahmad on 7/24/22.
//

import SwiftUI

struct RowCol: Equatable {
    let row: Int
    let col: Int
}

extension Double {
    func lerp(_ min: Double, _ max: Double, _ from: Double, _ to: Double) -> Double {
        guard self > min else { return from }
        guard self < max else { return to }
        guard max > min else { return (min + max)/2 }
        let ratio = (self - min) / (max - min)
        let result = from * (1 - ratio) + to * ratio
        return result
    }
}

struct ClothView: View {
    enum Kind: String, Identifiable {
        var id: String { rawValue }

        case timerWave = "Timer Wave"
        case touchCloth = "Touch Cloth"
    }
    private let side: Double = 20
    private let rows = 20
    private let cols = 17
    private var gridSize: CGSize {
        .init(width: side * Double(cols), height: side * Double(rows))
    }

    private let itemSpacing = 1.0

    @State private var kind: Kind = .touchCloth

    @State private var totalSize: CGSize? {
        didSet {
            newCalculateFrames()
        }
    }
    @State private var tapped: CGPoint? {
        didSet {
            newCalculateFrames()
        }
    }
    @State private var center: RowCol?

    typealias Opacity = Double
    @State private var itemMods: [(CGRect, Opacity)]?

    let timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()


    private func newCalculateFrames() {
        let rectSide = side - itemSpacing
        var rects: [(CGRect, Double)] = []
        let minOpacity = 0.25
        let maxOpacity = 0.95
        let maxDistance = 6 * rectSide
        for row in 0..<rows {
            for col in 0..<cols {
                let x = Double(col) * side + itemSpacing/2
                let y = Double(row) * side + itemSpacing/2

                let rectCenter = CGPoint(x: x + rectSide/2, y: y + rectSide/2)
                let sizeScale: Double
                let move: CGPoint
                let opacity: Opacity
                if let tapped {

                    let dist = self.distance(rectCenter, tapped)
                    let xDist: Double = (tapped.x - rectCenter.x)
                    let yDist: Double = (tapped.y - rectCenter.y)
//                    let xSign: Double = xDist > 0 ? 1 : -1
//                    let ySign: Double = yDist > 0 ? 1 : -1

                    let scale = dist.lerp(0, maxDistance, 0, 1)

                    sizeScale = scale.lerp(0, 1, 0.3, 1)
                    opacity = scale.lerp(0, 1, minOpacity, maxOpacity)

                    move = .init(
                        x: (1 - scale) * abs(xDist).lerp(0, 20, 0, rectSide/2),
                        y: (1 - scale) * abs(yDist).lerp(0, 20, 0, rectSide/2)
                    )
                } else {
                    sizeScale = 1
                    opacity = maxOpacity
                    move = .zero
                }

                let rect = CGRect(x: x + move.x, y: y + move.y, width: rectSide * sizeScale, height: rectSide * sizeScale)
                rects.append((rect, opacity))
            }
        }

        self.itemMods = rects
    }

    private func rect(_ row: Int, _ col: Int) -> CGRect {
        mod(row, col)?.0 ?? .zero
    }

    private func mod(_ row: Int, _ col: Int) -> (CGRect, Double)? {
        guard let mods = itemMods else {
            return nil
        }

        let index = col * rows + row
        return mods[index]
    }

    private func distance(_ a : CGPoint, _ b: CGPoint) -> Double {
        let pow1 = pow(Double(a.x - b.x), 2)
        let pow2 =
            pow(Double(a.y - b.y), 2)
        let result = sqrt(pow1 + pow2)
        return result
    }


    private func distance(_ a : RowCol, _ b: RowCol) -> Double {
        sqrt(
            pow(Double(a.row - b.row), 2)
            +
            pow(Double(a.col - b.col), 2)
        )
    }

    private var grid: some View {
        ZStack(alignment: .topLeading) {
            ForEach(0..<rows, id: \.self) { row in
                ForEach(0..<cols, id: \.self) { col in
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(.red)
                        .frame(width: rect(row, col).width, height: rect(row, col).height)
                        .offset(x: rect(row, col).origin.x, y: rect(row, col).origin.y)
                        .opacity(mod(row, col)?.1 ?? 0)
                }
            }
        }
        .frame(width: gridSize.width, height: gridSize.height, alignment: .topLeading)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    guard kind == .touchCloth else { return }
                    let loc = value.location
                    withAnimation {
                        self.tapped = loc
                    }
                }
                .onEnded { _ in
                    guard kind == .touchCloth else { return }
                    withAnimation(.easeIn(duration: 0.5)) {
                        self.tapped = nil
                    }
                }
        )
    }

    var body: some View {
        Color.clear
            .overlay(grid)
            .background(
                GeometryReader { reader in
                    Color.clear
                        .preference(key: SizeKey.self, value: [.init(id: UUID(), size: reader.size)])
                }
            )
//            .onAppear {
//                let l10 = (21.0).lerp(1, 100, 0, 1)
//                let l11 = (21.0).lerp(1, 100, 1, 0)
//                let l2 = (-12).lerp(-20, -1, 0, 1)
//                print("LERP for 21.0 between 1 → 100: \(l10)")
//                print("LERP for 21.0 between 1 → 100 reversed: \(l11)")
//                print("LERP for -12.0 between -20 → -1: \(l2)")
//            }
            .onPreferenceChange(SizeKey.self) {
                self.totalSize = $0.first!.size
            }
            .onReceive(timer) { _ in
                guard kind == .timerWave else { return }
                let row = (center?.row ?? 0) + 1
                let col = (center?.col ?? 0) + 1
                withAnimation {
                    center = .init(row: row % rows, col: col % cols)
                }
            }
    }
}

struct ClothView_Previews: PreviewProvider {
    static var previews: some View {
        ClothView()
    }
}
