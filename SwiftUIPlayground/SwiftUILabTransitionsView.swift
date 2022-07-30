//
//  SwiftUILabTransitionsView.swift
//  SwiftUIPlayground
//
//  Created by Raheel Ahmad on 6/27/22.
//

import SwiftUI

extension AnyTransition {
    static var myOpacity: AnyTransition {
        .modifier(active: MyOpacityModifier(opacity: 0), identity: MyOpacityModifier(opacity: 1))
    }

    static var myFlip: AnyTransition {
        .modifier(active: FlipTransition(pct: 0), identity: FlipTransition(pct: 1))
    }
}

struct MyOpacityModifier: ViewModifier {
    let opacity: Double

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
    }
}

struct FlipTransition: GeometryEffect {
    var pct: CGFloat

    var animatableData: CGFloat {
        get { pct }
        set { pct = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let rotationPercent = pct
                let a = CGFloat(Angle(degrees: 90 * (1-rotationPercent)).radians)

                var transform3d = CATransform3DIdentity;
                transform3d.m34 = -1/max(size.width, size.height)

                transform3d = CATransform3DRotate(transform3d, a, 1, 0, 0)
                transform3d = CATransform3DTranslate(transform3d, -size.width/2.0, -size.height/2.0, 0)

                let affineTransform1 = ProjectionTransform(CGAffineTransform(translationX: size.width/2.0, y: size.height / 2.0))
                let affineTransform2 = ProjectionTransform(CGAffineTransform(scaleX: CGFloat(pct * 2), y: CGFloat(pct * 2)))

                if pct <= 0.5 {
                    return ProjectionTransform(transform3d).concatenating(affineTransform2).concatenating(affineTransform1)
                } else {
                    return ProjectionTransform(transform3d).concatenating(affineTransform1)
                }
    }
}

struct StripesShape: Shape, Animatable {
    var pct: Double
    var animatableData: Double {
        get { pct }
        set { pct = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let numStripes = 50
        var p = Path()
        let w = rect.width / Double(numStripes)
        for i in 0..<numStripes {
            let x = Double(i) * w
            let width = w * pct
            p.addRect(.init(x: x, y: 0, width: width, height: rect.height))
        }
        return p
    }
}

struct SwiftUILabTransitionsView: View {
    @State private var answered = false

    var body: some View {
        VStack(spacing: 40) {
            Text(answered ? "Thanks!" : "Hello World")
                .font(.caption)
                .padding(20)
                .background(answered ? .red : .green)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .id(answered)
                .transition(.myFlip)
            Button {
                withAnimation(.easeInOut(duration: 3)) {
                    answered.toggle()
                }
            } label: {
                Text(answered ? "Reset" : "Answer")
            }

            Image("lib")
                .overlay {
                    StripesShape(pct: answered ? 0 : 1)
                        .fill(.red)
                        .transformEffect(.init(rotationAngle: 0.3))
                }
        }.padding(50)
    }
}

struct SwiftUILabTransitionsView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUILabTransitionsView()
    }
}
