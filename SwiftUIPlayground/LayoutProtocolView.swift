//
//  LayoutProtocolView.swift
//  SwiftUIPlayground
//
//  Created by Raheel Ahmad on 6/25/22.
//

import SwiftUI

struct LayoutProtocolView: View {
    var body: some View {
        VStack {
            ForEach(1..<6, id: \.self) { id in
                Text("Item \(id)")
                    .padding()
                    .background(
                        Capsule()
                            .fill(Color(hue: Double(id)/6, saturation: 0.4, brightness: 0.8))
                    )
            }
        }
    }
}

struct LayoutProtocolView_Previews: PreviewProvider {
    static var previews: some View {
        LayoutProtocolView()
    }
}
