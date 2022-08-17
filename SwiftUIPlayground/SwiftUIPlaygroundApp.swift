//
//  SwiftUIPlaygroundApp.swift
//  SwiftUIPlayground
//
//  Created by Raheel Ahmad on 10/26/21.
//

import SwiftUI

enum Example: String, Identifiable, CaseIterable {
    case clothAnimation
    case slideFlip

    var id: String { rawValue }

    var title: String {
        switch self {
            case .clothAnimation:
                return "Cloth Animation"
            case .slideFlip:
                return "Slide and Flip"
        }
    }
}

extension Example: View {
    var body: some View {
        switch self {
            case .clothAnimation:
                ClothView()
            case .slideFlip:
                FlipAndSlideView(cards: sampleCards)
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
