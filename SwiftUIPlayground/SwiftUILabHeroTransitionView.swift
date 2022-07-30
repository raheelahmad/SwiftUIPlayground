//
//  SwiftUILabHeroTransitionView.swift
//  SwiftUIPlayground
//
//  Created by Raheel Ahmad on 6/30/22.
//

import SwiftUI

public struct PolygonSidesKey: EnvironmentKey {
    public static let defaultValue: Double = 4
}

extension EnvironmentValues {
    var polygonSides: Double {
        get { self[PolygonSidesKey.self] }
        set { self[PolygonSidesKey.self] = newValue }
    }
}

struct Polygon: View {
    @Environment(\.polygonSides) var sides: Double
    let color: Color

    var body: some View {
        Group {
            if sides > 30 {
                Circle()
                    .stroke(color, lineWidth: 3)
            } else {
                PolygonShape(sides: sides)
                    .stroke(color, lineWidth: 3)
            }
        }
    }

    struct PolygonShape: Shape {
        var sides: Double

        func path(in rect: CGRect) -> Path {
            var path = Path()
            let h = Double(min(rect.size.width, rect.size.height)) / 2.0


            let c = CGPoint(x: rect.size.width / 2.0, y: rect.size.height / 2.0)
            let extra: Int = Double(sides) != Double(Int(sides)) ? 1 : 0

            for i in 0..<Int(sides) + extra {
                let angle = (Double(i) * (360.0 / Double(sides))) * Double.pi / 180

                let pt = CGPoint(x: c.x + CGFloat(cos(angle) * h), y: c.y + CGFloat(sin(angle) * h))

                if i == 0 {
                    path.move(to: pt) // move to first vertex
                } else {
                    path.addLine(to: pt) // draw line to next vertex
                }
            }

            path.closeSubpath()

            return path
        }
    }
}
extension AnyTransition {
    static var polygonTriangle: AnyTransition {
        AnyTransition.modifier(
            active: PolygonModifier(sides: 30, opacity: 0),
            identity: PolygonModifier(sides: 3, opacity: 1)
        )
    }

    static var polygonCircle: AnyTransition {
        AnyTransition.modifier(
            active: PolygonModifier(sides: 3, opacity: 0),
            identity: PolygonModifier(sides: 30, opacity: 1)
        )
    }

    struct PolygonModifier: AnimatableModifier {
        var sides, opacity: Double

        var animatableData: Double {
            get { sides }
            set { sides = newValue }
        }

        func body(content: Content) -> some View {
            content
                .environment(\.polygonSides, sides)
                .opacity(opacity)
        }
    }
}

struct SwiftUILabHeroTransitionView: View {
    @Namespace private var nspace
    @State private var flag = true
    var body: some View {
        HStack {
            if flag {
                VStack {
                    Polygon(color: Color.green)
                        .matchedGeometryEffect(id: "geoeffect1", in: nspace)
                        .frame(width: 200, height: 200)
                }
                .transition(.polygonTriangle)
            }

            Spacer()

            Button("Switch") { withAnimation(.easeInOut(duration: 2.0)) { flag.toggle() } }

            Spacer()

            VStack {
                Rectangle().fill(Color.yellow).frame(width: 50, height: 50)

                if !flag {
                    VStack {
                        Polygon(color: Color.blue)
                            .matchedGeometryEffect(id: "geoeffect1", in: nspace)
                            .frame(width: 200, height: 200)
                    }
                    .transition(.polygonCircle)
                }

                Rectangle().fill(Color.yellow).frame(width: 50, height: 50)
            }
        }
        .frame(width: 350).padding(10).border(Color.gray, width: 3)
    }
}

struct SwiftUILabHeroTransitionView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUILabHeroTransitionView()
            .frame(width: 120, height: 120)
            .environment(\.polygonSides, 10)
    }
}
