//
//  GeometryEffectView.swift
//  SwiftUIPlayground
//
//  Created by Raheel Ahmad on 3/7/22.
//

import SwiftUI

struct SomeGeometryEffect: GeometryEffect {
    var xOffset: Double
    var skew: Double

    func effectValue(size _: CGSize) -> ProjectionTransform {
        .init(.init(a: 1, b: 0, c: skew, d: 1, tx: xOffset, ty: 0))
    }

    var animatableData: AnimatablePair<Double, Double> {
        get {
            .init(xOffset, skew)
        }
        set {
            xOffset = newValue.first
            skew = newValue.second
        }
    }
}

struct GeometryEffectView: View {
    @State var xOffset = 0.0
    @State var skew = 0.0

    var body: some View {
        VStack {
            Text("Hello, World!")
                .foregroundColor(Color.white)
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).fill(.green))
                .modifier(SomeGeometryEffect(xOffset: xOffset, skew: skew))
            Button {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation {
                        xOffset = 0
                        skew = 0
                    }
                }
                withAnimation {
                    xOffset += 102
                    skew = 1
                }
            } label: {
                Text("Animate")
            }
        }
    }
}

struct GeometryEffectView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryEffectView()
    }
}
