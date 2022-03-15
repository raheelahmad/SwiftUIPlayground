//
//  FlowLayoutRevisitedView.swift
//  SwiftUIPlayground
//
//  Created by Raheel Ahmad on 3/14/22.
//

import SwiftUI

struct SizeValue: Equatable {
    let id: UUID
    let size: CGSize
}

struct SizeKey: PreferenceKey {
    static var defaultValue: [SizeValue] = []
    static func reduce(value: inout [SizeValue], nextValue: () -> [SizeValue]) {
        value.append(contentsOf: nextValue())
    }
}

struct Item: Identifiable, Hashable {
    let id: UUID
    let text: String
}

struct OriginValue {
    let id: UUID
    let origin: CGPoint
}

let flowLayoutId = UUID()

struct FlowLayout<Element: Identifiable, Content: View>: View where Element.ID == UUID {
    let items: [Element]
    let content: (Element) -> Content

    private func layout(sizes: [SizeValue], spacing: (horizontal: Double, vertical: Double) = (10, 10), containerWidth _: Double) -> [OriginValue] {
        var currentPoint: CGPoint = .init(x: 0, y: 0)
        var origins: [OriginValue] = []

        print(sizes.count)

        for size in sizes {
            origins.append(.init(id: size.id, origin: currentPoint))
            currentPoint.x += size.size.width + spacing.horizontal
        }
        print(sizes.map(\.size.width))
        print(origins.map(\.origin.x))

        return origins
    }

    @State var sizes: [SizeValue] = []
    @State var containerWidth: Double = 0

    var body: some View {
        let laidOut = layout(sizes: sizes, containerWidth: containerWidth)
        print("-------")
        return VStack(alignment: .leading, spacing: 0) {
            // Full-width reader
            GeometryReader { proxy in
                Color.clear.preference(key: SizeKey.self, value: [.init(id: flowLayoutId, size: proxy.size)])
            }
            .onPreferenceChange(SizeKey.self) { value in
                containerWidth = value[0].size.width
            }
            .frame(height: 0) // Don't need this showing up.

            ZStack(alignment: .topLeading) {
                ForEach(items) { item in
                    content(item)
                        .fixedSize() // TODO: what happens if we remove this?
                            .background(
                                GeometryReader { proxy in
                                    Color.clear
                                        .preference(
                                            key: SizeKey.self,
                                            value: [SizeValue(id: item.id, size: proxy.size)]
                                        )
                                }
                            )
                            .alignmentGuide(.leading) { _ in
                                guard !laidOut.isEmpty else { return 0 }
                                let x = laidOut.first { $0.id == item.id }!.origin.x
                                print(item)
                                print(x)
                                print("......")
                                return -x
                            }
                            .alignmentGuide(.top) { _ in
                                guard !laidOut.isEmpty else { return 0 }
                                return laidOut.first { $0.id == item.id }!.origin.y
                            }
                }
            }.onPreferenceChange(SizeKey.self) { sizes in
                print(sizes)
                print("+++++++")
                self.sizes = sizes
            }
//            .id(containerWidth)
            .border(Color.red)
        }
    }
}

struct FlowLayoutRevisitedView: View {
    let items: [Item]

    @State private var fullWidth = 0.0

    var body: some View {
        FlowLayout(items: items, content: { item in
            Text(item.text)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 4).fill(Color.blue)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.black))
                )
        })
            // TODO: should this be in FlowLayout?
            // TODO: what happens if we remove this?
                .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FlowLayoutRevisitedView_Previews: PreviewProvider {
    static var previews: some View {
        FlowLayoutRevisitedView(
            items: (0 ..< 2).map {
                Item(id: UUID(), text: "Item \($0) " + (Bool.random() ? "\n" : "") + String(repeating: "x", count: Int.random(in: 0 ... 10)))
            }
        )
    }
}
