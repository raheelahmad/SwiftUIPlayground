//
//  FlipAndSlideView.swift
//  SwiftUIPlayground
//
//  Created by Raheel Ahmad on 5/9/22.
//

import SwiftUI

public struct FlipModifier: ViewModifier {
    public var angle: Double

    public init(angle: Double) {
        self.angle = angle
    }

    public func body(content: Content) -> some View {
        content.rotation3DEffect(.degrees(angle), axis: (0, 1, 0))
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
            active: FlipModifier(angle: direction * 180),
            identity: FlipModifier(angle: 0)
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

        var other: Self {
            switch self {
            case .front:
                return .back
            case .back:
                return .front
            }
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

    func sideView(side: Card.Side) -> some View {
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

    var body: some View {
        sideView(side: side)
//                .rotation3DEffect(.degrees(side == .front ? 0 : 180), axis: (0, 1, 0))
//                .opacity(side == .front ? 1 : 0)
//            sideView(side: .back)
//                .rotation3DEffect(.degrees(side == .back ? 0 : -180), axis: (0, 1, 0))
//                .opacity(side == .back ? 1 : 0)
//        }
    }
}

struct Navigation: View {
    @Binding var index: Int
    @Binding var side: Card.Side
    @Binding var forward: Bool
    let count: Int

    var animation: Animation {
        .easeInOut(duration: 0.6)
    }

    var body: some View {
        HStack {
            Button {
                withAnimation(animation) {
                    if index > 0 {
                        forward = false
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
                        forward = true
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
    @State var forward = true

    var card: Card {
        cards[index]
    }

    var fullTransition: AnyTransition {
        if side == .front {
            return .asymmetric(
                insertion: .move(edge: forward ? .trailing : .leading),
                removal: .flip(direction: 1).combined(with: .opacity)
            )
        } else {
            return .asymmetric(
                insertion: .flip(direction: -1).combined(with: .opacity),
                removal: .move(edge: .trailing)
            )
        }
    }

    var transition: AnyTransition {
        .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
//        .move(edge: .leading)
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
                .transition(fullTransition)

            VStack {
                if side == .back {
                    Navigation(index: $index, side: $side, forward: $forward, count: cards.count)
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
