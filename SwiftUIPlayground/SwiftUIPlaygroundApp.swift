//
//  SwiftUIPlaygroundApp.swift
//  SwiftUIPlayground
//
//  Created by Raheel Ahmad on 10/26/21.
//

import SwiftUI

enum Example: String, Identifiable, CaseIterable {
    case clothAnimation
    case swiftUILabTransitions
    case slideFlip
    case geometryEffectView
    case transitionsView
    case flowLayoutRevisited
    case mapViewReader
    case maginificationEffect
    case twoWayToggle
    case fixedSizeBuiltInViews

    var id: String { rawValue }

    var title: String {
        switch self {
            case .clothAnimation:
                return "Cloth Animation"
            case .swiftUILabTransitions:
                return "SwiftUILab Transitions"
            case .slideFlip:
                return "Slide and Flip"
            case .geometryEffectView:
                return "Geometry Effect View"
            case .transitionsView:
                return "Transitions View"
            case .flowLayoutRevisited:
                return "Flow Layout Revisited"
            case .mapViewReader:
                return "Map View Reader"
            case .maginificationEffect:
                return "Magnification Effect"
            case .twoWayToggle:
                return "Two Way Toggle"
            case .fixedSizeBuiltInViews:
                return "Fixed Sizes for Built-inn Views"
        }
    }
}

extension Example: View {
    var body: some View {
        switch self {
            case .clothAnimation:
                ClothView()
            case .swiftUILabTransitions:
                SwiftUILabTransitionsView()
            case .slideFlip:
                FlipAndSlideView(cards: sampleCards)
            case .geometryEffectView:
                GeometryEffectView()
            case .transitionsView:
                TransitionsView()
            case .maginificationEffect:
                GesturesAnimations1()
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
            case .mapViewReader:
                MapViewReaderView()
            case .twoWayToggle:
                TwoWayTogglePreviewer()
            case .fixedSizeBuiltInViews:
                FixedSizeBuiltInViews()
        }
    }
}

@main
struct SwiftUIPlaygroundApp: App {
    var body: some Scene {
        WindowGroup {
            ClothView()
            //            NavigationView {
//                List(Example.allCases) { example in
//                    NavigationLink(example.title) {
//                        example
//                    }
//                }
//            }
        }
    }
}
