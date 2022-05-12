//
//  FlipAndSlideView.swift
//  SwiftUIPlayground
//
//  Created by Raheel Ahmad on 5/9/22.
//

import SwiftUI

public struct FlipModifier: ViewModifier {
    public var effect: Double

    public init(effect: Double) {
        self.effect = effect
    }

    public func body(content: Content) -> some View {
        content.rotation3DEffect(.degrees(effect), axis: (0, 1, 0))
    }
}

public struct SlideDownModifier: ViewModifier {
    public var effect: Double
    public let anchor: UnitPoint

    public func body(content: Content) -> some View {
        content.rotationEffect(.degrees(effect), anchor: anchor)
    }
}

public extension AnyTransition {
    static func flip(direction: Double) -> AnyTransition {
        AnyTransition.modifier(
            active: FlipModifier(effect: direction * 180),
            identity: FlipModifier(effect: 0)
        )
    }

    static func slideDown(direction: Double, anchor: UnitPoint) -> AnyTransition {
        AnyTransition.modifier(
            active: SlideDownModifier(effect: direction * 41, anchor: anchor),
            identity: SlideDownModifier(effect: 0, anchor: anchor)
        )
    }
}

struct Card: Identifiable {
    enum Side: String {
        var id: String {
            rawValue
        }

        var text: String {
            switch self {
            case .front:
                return "Question"
            case .back:
                return "Answer"
            }
        }

        case front, back

        var background: Color {
            switch self {
            case .front:
                return Color(red: 171 / 255.0, green: 189 / 255.0, blue: 211 / 255.0)
            case .back:
                return Color(red: 196 / 255.0, green: 123 / 255.0, blue: 99 / 255.0)
            }
        }

        var foreground: Color {
            switch self {
            case .front:
                return Color.black
            case .back:
                return Color.white
            }
        }
    }

    let id: String
    let front: String
    let back: String

    func text(side: Side) -> String {
        switch side {
        case .front:
            return front
        case .back:
            return back
        }
    }
}

struct CardView: View {
    let card: Card
    let side: Card.Side

    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(side.text.capitalized)
                        .font(.callout.smallCaps().bold())
                        .foregroundColor(side.foreground).opacity(0.6)
                    Spacer()
                }
                .padding(.horizontal, 20)

                Spacer()
            }

            Text(card.text(side: side))
                .font(.title3)
                .foregroundColor(side.foreground).opacity(0.9)
                .lineSpacing(2.4)
                .padding(.horizontal, 20)
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(side.background)
        )
    }
}

struct Navigation: View {
    @Binding var index: Int
    @Binding var side: Card.Side
    let count: Int

    var animation: Animation {
        .easeInOut(duration: 0.6)
    }

    var body: some View {
        HStack {
            Button {
                withAnimation(animation) {
                    if index > 0 {
                        index -= 1
                        side = .front
                    }
                }
            } label: {
                Image(systemName: "arrow.left.circle")
                    .resizable()
                    .frame(width: 34, height: 34)
            }.disabled(index < 1)

            Spacer()

            Button {
                withAnimation(animation) {
                    if index < count - 1 {
                        index += 1
                        side = .front
                    }
                }
            } label: {
                Image(systemName: "arrow.right.circle")
                    .resizable()
                    .frame(width: 34, height: 34)
            }.disabled(index >= count - 1)
        }.padding()
    }
}

struct FlipAndSlideView: View {
    let cards: [Card]
    @State var side: Card.Side = .front
    @State private var index = 0

    var card: Card {
        cards[index]
    }

    var transition: AnyTransition {
        if side == .front {
            // insertion: moving in the next card
            // removal: flipping front to back
            return .asymmetric(
                insertion: .move(edge: .trailing),
                removal: .flip(direction: -1).combined(with: .opacity)
            )
        } else {
            // insertion: flipping back to front
            // removal: removing the current card
            return .asymmetric(
                insertion: .flip(direction: 1).combined(with: .opacity),
                removal: .move(edge: .leading)
            )
        }
    }

    var animation: Animation {
        .easeInOut(duration: 0.8)
    }

    var flip: some View {
        Button {
            withAnimation(animation) {
                side = .back
            }
        } label: {
            Image(systemName: "arrow.triangle.swap")
                .resizable()
                .frame(width: 24, height: 24)
        }
    }

    var body: some View {
        VStack {
            CardView(card: card, side: side)
                .id(card.id + side.id)
                .onTapGesture {
                    if side == .front {
                        withAnimation(animation) {
                            side = .back
                        }
                    }
                }
                .padding()
                .zIndex(1)
                .transition(transition)

            VStack {
                if side == .back {
                    Navigation(index: $index, side: $side, count: cards.count)
                }
            }.frame(height: 64)
        }
    }
}

struct FlipAndSlideView_Previews: PreviewProvider {
    static var previews: some View {
        FlipAndSlideView(cards: sampleCards)
    }
}

let sampleCards: [Card] = [
    Card(
        id: UUID().uuidString,
        front: """
        Which best describes how a recession develops as demand and production decrease?

        a.)The recession accelerates.

        b.) The recession spirals out of control

        c.)The recession feeds on itself.

        d.) The recession starts and stops.
        """, back: """
        Demand greatly decreases.
        """
    ),
    Card(
        id: UUID().uuidString,
        front: """
        In which layer of Earth's interior does convection occur?
        crust
        mantle
        outer core
        inner core
        """, back: """
        mantle
        """
    ),
    Card(
        id: UUID().uuidString,
        front: """
        Foods labeled "fat free" can actually contain less than 0.5 grams of fat.

        True or False?
        """, back: """
        True
        """
    ),
]
