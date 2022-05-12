//
//  TwoWayToggle.swift
//  SwiftUIPlayground
//
//  Created by Raheel Ahmad on 4/3/22.
//

import SwiftUI

enum Side { case left, right }

struct HalfCapsule: Shape {
    let side: Side

    private var corners: UIRectCorner {
        switch side {
            case .left:
                return [.topLeft, .bottomLeft]
            case .right:
                return [.topRight, .bottomRight]
        }
    }

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: .init(width: rect.height/2, height: rect.height/2)
        )
        return Path(path.cgPath)
    }
}

private struct Segment: View {
    let text: String
    @Binding var selected: Side
    let side: Side
    @State private var pressed = false
    @State var scale = 1.0

    private var color: Color {
        selected == side ? Color.yellow : Color.gray
    }

    private var rotation: Double {
        if !pressed { return 0 }
        switch side {
        case .right: return -7.0
        case .left: return 7.0
        }
    }

    var simpleCapsule: some View {
        HalfCapsule(side: side)
            .fill(selected == side ? Color.yellow : Color.white)
    }

    var body: some View {
        Text(text)
            .foregroundColor(selected == side ? .black : .black.opacity(0.6))
            .font(.body).bold()
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                simpleCapsule
            )
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { _ in
                        if !pressed {
                            withAnimation {
                                pressed = true
                            }
                        }
                    }
                    .onEnded { _ in
                        withAnimation {
                            pressed = false
                            selected = side
                        }
                    }
            )
            .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 20, z: 0))
    }
}

struct TwoWayToggle: View {
    let left: String
    let right: String
    @Binding var selected: Side

    var body: some View {
        HStack(spacing: 0) {
            Segment(text: left, selected: $selected, side: .left)
            Segment(text: right, selected: $selected, side: .right)
        }
    }
}

struct TwoWayTogglePreviewer: View {
    @State private var selected: Side = .left
    var body: some View {
        TwoWayToggle(left: "Question", right: "Answer", selected: $selected)
    }
}

struct TwoWayToggle_Previews: PreviewProvider {
    @State static var option: Side = .left

    static var previews: some View {
        TwoWayToggle(
            left: "Transmutation",
            right: "Answer",
            selected: $option
        )
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(white: 0.3))
            )
    }
}
