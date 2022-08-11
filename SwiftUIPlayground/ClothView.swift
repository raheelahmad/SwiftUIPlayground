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



struct Col: Hashable, Equatable, Codable {
    var r: Double
    var g: Double
    var b: Double

    init(col: Color) {
        r = Double(col.cgColor?.components?[0] ?? 0)
        g = Double(col.cgColor?.components?[1] ?? 0)
        b = Double(col.cgColor?.components?[2] ?? 0)
    }

    var color: Color {
        Color(red: r, green: g, blue: b)
    }
}
struct Cols: Hashable, Equatable, Codable {
    var a: Col
    var b: Col
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
        var colors: Cols

        static var byDefault: Self {
            .init(name: "Default", rows: 12, cols: 15, side: 20, elementsAffected: 5, itemSpacing: 1.0, colors: .init(a: Col(col: .red), b: .init(col: .yellow)))
        }
    }

    init(params: Params = .byDefault) {
        rows = params.rows
        cols = params.cols
        side = params.side
        itemSpacing = params.itemSpacing
        elementsAffected = params.elementsAffected
        colA = params.colors.a.color
        colB = params.colors.b.color

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
    @State private var colA: Color
    @State private var colB: Color
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
    @State private var itemProps: [(CGRect, Opacity)]?

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
                if let tapped = tapped {

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

        self.itemProps = rects
    }

    private func rect(_ row: Int, _ col: Int) -> CGRect {
        mod(row, col)?.0 ?? .zero
    }

    private func mod(_ row: Int, _ col: Int) -> (CGRect, Double)? {
        guard let mods = itemProps else {
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
        LinearGradient(colors: [colA, colB], startPoint: .topLeading, endPoint: .bottomTrailing)
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
            .drawingGroup()
    }

    @State private var showingParams = true
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
                    colA = param.colors.a.color
                    colB = param.colors.b.color
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
                        .init(
                            name: saveParamsName,
                            rows: rows,
                            cols: cols,
                            side: side,
                            elementsAffected: elementsAffected,
                            itemSpacing: itemSpacing,
                            colors: .init(a: .init(col: colA), b: .init(col: colB))
                        )
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

    private var paramsControl: some View {
        ZStack {
            VStack(spacing: 10) {
                HStack(spacing: 20) {
                    Button {
                        withAnimation {
                            showingParams.toggle()
                        }
                    } label: { Text(showingParams ? "Hide" : "Show") }
                        .font(.callout.smallCaps())
                        .animation(nil, value: showingParams)

                    Spacer()

                    Button {
                        showingSaveParamsAlert = true
                    } label: { Text("Save") }

                    Divider()
                        .frame(height: 22)

                    Button {
                        showingLoadParams = true
                    } label: {
                        Text("Load")
                    }
                }.font(.callout.bold())

                if showingSaveParamsAlert {
                    ClosableContainer(content: saveSheet, showing: $showingSaveParamsAlert)
                }
            }
            .sheet(isPresented: $showingLoadParams) {
                loadSheet
            }
        }
    }

    private var params: [DoubleParam] {
        [
            .init(param: $itemSpacing, range: 1.0...(20.0), name: "Cell Spacing"),
            .init(param: $animUp, range: 0.0...(2.0), name: "Animation Up"),
            .init(param: $animDown, range: 0.0...(2.0), name: "Animation Down"),
            .init(param: $rows, range: 0...(200), name: "Rows"),
            .init(param: $cols, range: 0...(200), name: "Columns"),
            .init(param: $side, range: 0...(200), name: "Cell Size"),
            .init(param: $elementsAffected, range: 0...(200), name: "Spread"),
        ]
    }

    private var colorParams: [ColorParam] {
        [
            .init(color: $colA, name: "Color A"),
            .init(color: $colB, name: "Color B"),
        ]
    }

    private var paramsView: some View {
        VStack {
            if showingParams {
                ParamsView(doubles: params, colors: colorParams)
            }

            paramsControl

            Text("Params")
                .font(.caption.monospaced())
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.thinMaterial)
        )
        .padding(.horizontal)
        .frame(maxHeight: .infinity, alignment: .bottom)

    }

    var body: some View {
        Color.clear
            .overlay(
                VStack {
                    content
                    Spacer()
                }
            )
            .overlay(paramsView)
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

struct TweakerView: View {
    @Binding var param: DoubleParam
    var body: some View {
        VStack {
            Slider(value: $param.param, in: param.range, step: 0.1)
                .frame(width: 220)
            Text("\(param.name): \(nf.string(from: .init(value: param.param)) ?? "")")
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
