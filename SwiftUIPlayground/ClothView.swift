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

let nf: NumberFormatter = {
    let fn = NumberFormatter()
    fn.maximumFractionDigits = 1
    return fn
}()


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

protocol ViewConfig {
    static var `default`: Self { get }
}


struct ClothView: View {
    struct Params: Identifiable, Hashable, Equatable, Codable {
        var id: String { name }
        let name: String
        var rows: Int
        var cols: Int
        var side: Double
        var elementsAffected: Int
        var itemSpacing: Double

        static var byDefault: Self {
            .init(name: "Default", rows: 12, cols: 15, side: 20, elementsAffected: 5, itemSpacing: 1.0)
        }
    }

    init(params: Params = .byDefault) {
        rows = params.rows
        cols = params.cols
        side = params.side
        itemSpacing = params.itemSpacing
        elementsAffected = params.elementsAffected

        let data = (UserDefaults.standard.value(forKey: Self.previousParamsKey) as? Data)
        let previousParams = (try? data.flatMap {
            try JSONDecoder().decode([Params].self, from: $0)
        }) ?? []
        self.previousParams = previousParams
    }

    enum Kind: String, Identifiable {
        var id: String { rawValue }

        case timerWave = "Timer Wave"
        case touchCloth = "Touch Cloth"
    }
    @State private var side: Double = 20 {
        didSet { newCalculateFrames() }
    }
    @State private var rows = 20 {
        didSet { newCalculateFrames() }
    }

    @State private var cols = 17 {
        didSet { newCalculateFrames() }
    }
    private var gridSize: CGSize {
        .init(width: side * Double(cols), height: side * Double(rows))
    }

    @State private var itemSpacing = 1.0 {
        didSet { newCalculateFrames() }
    }

    @State private var elementsAffected = 1 {
        didSet {
            newCalculateFrames()
        }
    }

    @State private var kind: Kind = .touchCloth

    @State private var totalSize: CGSize? {
        didSet { newCalculateFrames() }
    }

    @State private var animDown = 0.2
    @State private var animUp = 0.2

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
        let maxDistance = Double(elementsAffected) * rectSide
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
                    let scale = dist.lerp(0, maxDistance, 0, 1)

                    sizeScale = scale.lerp(0, 1, 0.1, 1)
                    opacity = scale.lerp(0, 1, minOpacity, maxOpacity)

                    move = .init(
                        x: (1 - scale) * xDist.lerp(0, 20, 0, rectSide/2),
                        y: (1 - scale) * yDist.lerp(0, 20, 0, rectSide/2)
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
        guard index < mods.count else { return nil }
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
        .drawingGroup()
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard kind == .touchCloth else { return }
                let loc = value.location
                withAnimation(.easeInOut(duration: animDown)) {
                    self.tapped = loc
                }
            }
            .onEnded { _ in
                guard kind == .touchCloth else { return }
                withAnimation(.easeIn(duration: animUp)) {
                    self.tapped = nil
                }
            }
    }

    private var content: some View {
        LinearGradient(colors: [.blue, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing)
            .frame(width: gridSize.width, height: gridSize.height, alignment: .topLeading)
            .mask(grid)
            .gesture(dragGesture)
            .background(
                GeometryReader { reader in
                    Color.clear
                        .preference(key: SizeKey.self, value: [.init(id: UUID(), size: reader.size)])
                }
            )
            .onPreferenceChange(SizeKey.self) {
                self.totalSize = $0.first!.size
            }
    }

    @State private var showingAnimDown = false
    @State private var showingAnimUp = false
    @State private var showingRows = false
    @State private var showingCols = false
    @State private var showingElementsAffected = false
    @State private var showingCellSide = false
    @State private var showingCellSpacing = false

    @State private var showingSaveParamsAlert = false
    @State private var showingLoadParams = false
    @State private var saveParamsName: String = ""

    private static let previousParamsKey = "previousParams for ClothView"
    @State var previousParams: [Params] {
        didSet {
            let data = (try! JSONEncoder().encode(previousParams))
            UserDefaults.standard.set(data, forKey: Self.previousParamsKey)
        }
    }

    @State private var chosenParamsFromPreviousList: Params?
    private var loadSheet: some View {
        List(previousParams, selection: $chosenParamsFromPreviousList) { param in
            Text(param.name)
                .contentShape(Rectangle())
                .onTapGesture {
                    rows = param.rows
                    cols = param.cols
                    side = param.side
                    itemSpacing = param.itemSpacing
                    showingLoadParams = false
                }
        }
    }

    private var saveSheet: some View {
        VStack {
            TextField("Name for parameters", text: $saveParamsName)
                .frame(width: 220)

            Button {
                if !saveParamsName.isEmpty {
                    previousParams.append(
                        .init(name: saveParamsName, rows: rows, cols: cols, side: side, elementsAffected: elementsAffected, itemSpacing: itemSpacing)
                    )
                    showingSaveParamsAlert = false
                }
            } label: {
                Text("Save Params")
                    .font(.caption2.bold())
            }
            .disabled(saveParamsName.isEmpty)
        }
    }

    private var tweaksView: some View {
        ZStack {
            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    Button {
                        withAnimation { showingAnimDown = true }
                    } label: {
                        Text("anim down \(nf.string(from: .init(value: animDown))!)")
                    }

                    Button {
                        withAnimation { showingAnimUp = true }
                    } label: {
                        Text("anim up \(nf.string(from: .init(value: animUp))!)")
                    }
                }

                HStack(spacing: 20) {
                    Button {
                        withAnimation { showingRows = true }
                    } label: {
                        Text("Rows \(nf.string(from: .init(value: rows))!)")
                    }
                    Button {
                        withAnimation { showingCols = true }
                    } label: {
                        Text("Cols \(nf.string(from: .init(value: cols))!)")
                    }
                }

                HStack(spacing: 20) {
                    Button {
                        withAnimation { showingCellSide = true }
                    } label: {
                        Text("Cell Side \(nf.string(from: .init(value: side))!)")
                    }
                    Button {
                        withAnimation { showingCellSpacing = true }
                    } label: {
                        Text("Spacing \(nf.string(from: .init(value: itemSpacing))!)")
                    }
                }

                HStack(spacing: 20) {
                    Button {
                        withAnimation { showingElementsAffected = true }
                    } label: {
                        Text("Elements affected \(elementsAffected)")
                    }
                }

                Divider()

                HStack {
                    Button {
                        showingSaveParamsAlert = true
                    } label: {
                        Text("Save")
                    }

                    Divider()
                        .frame(height: 12)

                    Button {
                        showingLoadParams = true
                    } label: {
                        Text("Load")
                    }
                }
            }.font(.caption2)

            if showingAnimUp {
                ClosableContainer(content: DoubleTweakerView(value: $animUp, range: 0...2.0, title: "Animation Up"), showing: $showingAnimUp)
            }
            if showingAnimDown {
                ClosableContainer(content: DoubleTweakerView(value: $animDown, range: 0...2.0, title: "Animation Down"), showing: $showingAnimDown)
            }
            if showingRows {
                ClosableContainer(content: DoubleTweakerView(value: $rows, range: 2...40, title: "Rows"), showing: $showingRows)
            }
            if showingCols {
                ClosableContainer(content: DoubleTweakerView(value: $cols, range: 2...40, title: "Cols"), showing: $showingCols)
            }

            if showingCellSide {
                ClosableContainer(content: DoubleTweakerView(value: $side, range: 2.0...100.0, title: "Side"), showing: $showingCellSide)
            }

            if showingCellSpacing {
                ClosableContainer(content: DoubleTweakerView(value: $itemSpacing, range: 1.0...20.0, title: "Spacing"), showing: $showingCellSpacing)
            }

            if showingSaveParamsAlert {
                ClosableContainer(content: saveSheet, showing: $showingSaveParamsAlert)
            }

            if showingElementsAffected {
                ClosableContainer(content: DoubleTweakerView(
                    value: $elementsAffected,
                    range: 2...20,
                    title: "Elements affected"
                ), showing: $showingElementsAffected)
            }
        }
        .frame(height: 190, alignment: .center)
        .sheet(isPresented: $showingLoadParams) {
            loadSheet
        }
    }

    var body: some View {
        VStack {
            content
            Spacer()
        }
        .overlay(
            VStack {
                tweaksView.fixedSize()
            }.frame(maxHeight: .infinity, alignment: .bottom)
        )
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

struct ClosableContainer<Content: View>: View {
    let content: () -> Content
    @Binding var showing: Bool

    init(content: @autoclosure @escaping () -> Content, showing: Binding<Bool>) {
        self._showing = showing
        self.content = content
    }

    var body: some View {
        content()
            .padding(.horizontal)
            .padding(.vertical, 40)
            .background(
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(.thickMaterial)
                    Button {
                        withAnimation {
                            showing = false
                        }
                    } label: {
                        Text("Close")
                    }
                    .padding()
                }
            )
            .transition(.move(edge: .bottom).combined(with: .opacity))
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
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.thinMaterial)
        )
    }
}

struct ClothView_Previews: PreviewProvider {
    @State static var value = 0.4
    static var previews: some View {
            ClothView()
    }
}
