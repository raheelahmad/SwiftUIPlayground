//
//  GesturesAnimations1.swift
//  SwiftUIPlayground
//
//  Created by Raheel Ahmad on 3/16/22.
//

import SwiftUI
import Combine

struct MagnificationItem: Identifiable {
    let id = UUID()
    let color = Color(hue: .random(in: 0.1 ... 0.9), saturation: .random(in: 0.1 ... 0.3), brightness: 0.8)
}

private struct CardItemView: View {
    let item: MagnificationItem

    var body: some View {
        Text("An Item")
            .font(.caption)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(item.color)
            )
    }
}

struct SizeMeasurementKey: PreferenceKey {
    static var defaultValue: CGSize?
    static func reduce(value: inout CGSize?, nextValue: () -> CGSize?) {
        value = value ?? nextValue()
    }
}

extension View {
    func measure() -> some View {
        background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: SizeMeasurementKey.self, value: proxy.size)
            }
        )
    }
}

struct GesturesAnimations1: View {
    let items = (0 ..< 4).map { _ in MagnificationItem() }
    @State private var magnification = 1.0
    @State private var fullScreenMagnification = 1.0

    @State private var magnifyingId: Item.ID?
    @State private var endSize: CGSize = .zero
    @State private var fullScreen = false
    let cardSize = CGSize(width: 80, height: 40)

    private var maginifyingItem: MagnificationItem? {
        items.first { $0.id == magnifyingId }
    }

    private var factor: Double {
        (magnification - 1) / 2
    }

    private func cardSize(for id: Item.ID) -> CGSize {
        guard id == magnifyingId else {
            return cardSize
        }
        return interpolatedSize(factor: (magnification - 1) / 2)
    }

    private func fullscreenSize() -> CGSize {
        interpolatedSize(factor: (fullScreenMagnification + 1)/2)
    }

    func interpolatedSize(factor: Double) -> CGSize {
        let width = cardSize.width + (endSize.width - cardSize.width) * factor
        let height = cardSize.height + (endSize.height - cardSize.height) * factor
        let size = CGSize(width: max(width, 0), height: max(0, height))
        return size
    }

    @Namespace var ns

    private var animation: Animation { .default.speed(slowAnimation ? 0.2 : 1) }

    private func openGesture(for id: MagnificationItem.ID) -> some Gesture {
        let pinch = MagnificationGesture()
            .onChanged {
                self.magnification = $0
                self.magnifyingId = id
            }.onEnded { _ in
                withAnimation(animation) {
                    fullScreen = true
                }

                magnification = 1
            }
        let tap = TapGesture()
            .onEnded {
                withAnimation(animation) {
                    // let's switch to the fullscreen view
                    fullScreen = true
                    magnifyingId = id
                }
            }

        return pinch.exclusively(before: tap)
    }

    var closeGesture: some Gesture {
        let tap = TapGesture().onEnded {
            withAnimation(animation) {
                fullScreen = false
            }
        }
        let pinch = MagnificationGesture()
            .onChanged {
                fullScreenMagnification = $0
            }
            .onEnded { _ in
                withAnimation {
                    fullScreen = false
                }
                fullScreenMagnification = 1
            }
        let drag = DragGesture()
            .onEnded { _ in
                withAnimation {
                    fullScreen = false
                }
                fullScreenMagnification = 1
            }
        return pinch.exclusively(before: tap).simultaneously(with: drag)
        //                        magnifyingId = nil
    }

    var content: some View {
        ZStack {
            HStack {
                ForEach(items) { item in
                    let s = cardSize(for: item.id)
                    let shouldHide = fullScreen && magnifyingId == item.id
                    VStack {
                        if !shouldHide {
                            CardItemView(item: item)
                                .matchedGeometryEffect(id: item.id, in: ns)
                                .frame(width: s.width, height: s.height)
                                .transition(.asymmetric(insertion: .identity, removal: .identity))
                        }
                    }
                    .frame(width: cardSize.width, height: cardSize.height)
                    .zIndex(item.id == magnifyingId ? 2 : 1)
                    .gesture(openGesture(for: item.id))
                }
            }

            Color.clear
                .measure()
                .onPreferenceChange(SizeMeasurementKey.self) { value in
                    endSize = value ?? .zero
                }

            if let item = maginifyingItem, fullScreen {
                let size = fullscreenSize()
                CardItemView(item: item)
                    .matchedGeometryEffect(id: item.id, in: ns)
                    .gesture(closeGesture)
                    .frame(width: size.width, height: size.height)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                //                    .frame(width: endSize.width, height: endSize.height)
                    .transition(.asymmetric(insertion: .identity, removal: .identity))
            }
        }
        .padding(50)
    }

    @State var slowAnimation = false

    var body: some View {
        VStack {
            content

            Button {
                slowAnimation.toggle()

            } label: {
                Text("Toggle animation: \(slowAnimation ? "Fast" : "Slow")")
            }
        }
    }
}

struct GesturesAnimations1_Previews: PreviewProvider {
    static var previews: some View {
        GesturesAnimations1()
    }
}
