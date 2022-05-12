//
//  TwoWayToggle.swift
//  SwiftUIPlayground
//
//  Created by Raheel Ahmad on 4/3/22.
//

import SwiftUI

struct FixedSizeBuiltInViews: View {
    var body: some View {
        VStack(spacing: 40) {
            VStack {
                Rectangle()
                    .fill(.yellow)
                    .overlay(
                        GeometryReader { proxy in
                            Text("\(proxy.size.width) x \(proxy.size.height)")
                        }
                    )
                    .fixedSize()
                Text("Fixed Size proposed")
            }

            VStack {
                Rectangle()
                    .fill(.yellow)
                    .overlay(
                        GeometryReader { proxy in
                            Text("\(proxy.size.width) x \(proxy.size.height)")
                        }
                    )
                    .frame(width: nil, height: nil)
                Text("Nil Size proposed")
            }

            VStack {
                Rectangle()
                    .fill(.blue)
                    .overlay(
                        GeometryReader { proxy in
                            Text("\(proxy.size.width) x \(proxy.size.height)")
                        }
                    )
                Text("No explicit size proposed")
            }
        }
    }
}

struct FixedSizeBuiltInViews_Previews: PreviewProvider {
    @State static var option: Side = .left

    static var previews: some View {
        FixedSizeBuiltInViews()
    }
}
