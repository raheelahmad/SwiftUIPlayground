//
//  AdvancedAlignmentView.swift
//  SwiftUIPlayground
//
//  Created by Raheel Ahmad on 4/20/22.
//

import SwiftUI

struct Tree<A>: Identifiable {
    internal init(_ value: A, children: [Tree<A>] = []) {
        self.value = value
        self.children = children
        id = UUID()
    }

    let value: A
    let children: [Tree<A>]
    let id: UUID
}

let sample = Tree("Root", children: [
    Tree("First Child is the first", children:
        [
            Tree("First Grandchild", children: [
                Tree("Third"),
            ]
                )
        ]),
    Tree("Second"),
    Tree("Third"),
    Tree("A fourth one"),
])

struct LineShape: Shape {
    let start: CGPoint
    let end: CGPoint
    func path(in _: CGRect) -> Path {
        Path { p in
            p.move(to: start)
            p.addLine(to: end)
        }
    }
}

private struct FrameKey: PreferenceKey {
    static var defaultValue: [UUID: CGRect] = [:]

    typealias Value = [UUID: CGRect]
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

extension View {
    func measure(in coordinateSpace: CoordinateSpace, id: UUID) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear.preference(key: FrameKey.self, value: [id: proxy.frame(in: coordinateSpace)])
            }
        )
    }
}

extension CGRect {
    var bottom: CGPoint {
        .init(x: midX, y: maxY)
    }

    var top: CGPoint {
        .init(x: midX, y: minY)
    }
}

struct NodeAlignment: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        context[HorizontalAlignment.center]
    }
}

extension HorizontalAlignment {
    static let nodeCenter = Self(NodeAlignment.self)
}

struct Diagram<A, Node: View>: View {
    let tree: Tree<A>
    let node: (A) -> (Node)
    var coordinateSpaceName: String {
        tree.id.uuidString
    }

    func nodeCenterIds() -> [UUID] {
        var ids: Set<UUID> = []
        let count = tree.children.count
        ids.insert(tree.children[count / 2].id)
        if count.isMultiple(of: 2) {
            ids.insert(tree.children[count / 2 - 1].id)
        }
        return Array(ids)
    }

    var body: some View {
        VStack(alignment: .nodeCenter, spacing: 40) {
            node(tree.value)
                .measure(in: .named(coordinateSpaceName), id: tree.id)
            if !tree.children.isEmpty {
                let nodeIds = nodeCenterIds()
                HStack(alignment: .top, spacing: 20) {
                    ForEach(tree.children) { child in
                        let subtree = Diagram(tree: child, node: node)
                            .measure(in: .named(coordinateSpaceName), id: child.id)

                        let alignment: HorizontalAlignment = nodeIds.contains(child.id) ? .nodeCenter : .center
                            subtree
                                .alignmentGuide(alignment, computeValue: {
                                    $0[HorizontalAlignment.center]
                                })
                    }
                }
            }
        }.coordinateSpace(name: coordinateSpaceName)
            .overlayPreferenceValue(FrameKey.self) { frames in
                let rootFrame = frames.first { $0.key == tree.id }!
                let otherFrames: [(UUID, CGRect)] = frames.filter { $0.key != tree.id }
                ForEach(otherFrames, id: \.0) { frame in
                    LineShape(start: rootFrame.value.bottom, end: frame.1.top)
                        .stroke(.white)
                }
            }
            .transformPreference(FrameKey.self) { values in
                values = [:]
            }
            .font(.footnote)
    }
}

struct AdvancedAlignmentView: View {
    var body: some View {
        Diagram(tree: sample) { node in
            Text(node)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.gray)
        }
    }
}

struct AdvancedAlignmentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ZStack {
                Color.black
                AdvancedAlignmentView()
            }
            .edgesIgnoringSafeArea(.all)
        }.environment(\.colorScheme, .dark)
    }
}
