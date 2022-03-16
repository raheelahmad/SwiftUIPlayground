//
//  SwiftUIPlaygroundApp.swift
//  SwiftUIPlayground
//
//  Created by Raheel Ahmad on 10/26/21.
//

import SwiftUI

enum Example: String, Identifiable, CaseIterable {
    case geometryEffectView
    case transitionsView
    case flowLayoutRevisited

    var id: String { rawValue }

    var title: String {
        switch self {
            case .geometryEffectView:
                return "Geometry Effect View"
            case .transitionsView:
                return "Transitions View"
            case .flowLayoutRevisited:
                return "Flow Layout Revisited"
        }
    }
}

extension Example: View {
    var body: some View {
        switch self {
        case .geometryEffectView:
            GeometryEffectView()
        case .transitionsView:
            TransitionsView()
        case .flowLayoutRevisited:

            FlowLayoutRevisitedView(
                items: (
                    (1 ..< Int.random(in: 4 ..< 20)).map { _ in
                        Item(id: UUID(), text: "Once Upon a time in a land very far away there lived a man!")
                    }
                        +
                        (1 ..< Int.random(in: 5 ..< 20)).map { _ in
                            Item(id: UUID(), text: "Lasseter")
                        }
                        +
                        (1 ..< Int.random(in: 4 ..< 20)).map { _ in
                            Item(id: UUID(), text: "Mt. Gorakh")
                        }
                ).shuffled()
            )
        }
    }
}

@main
struct SwiftUIPlaygroundApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                List(Example.allCases) { example in
                    NavigationLink(example.title) {
                        example
                    }
                }
            }
        }
    }
}
