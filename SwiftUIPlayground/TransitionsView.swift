//
//  TransitionsView.swift
//  SwiftUIPlayground
//
//  Created by Raheel Ahmad on 3/10/22.
//

import SwiftUI

extension Color {
    static var random: Color {
        Color(red: Double.random(in: 0..<1.0), green: Double.random(in: 0..<1.0), blue: Double.random(in: 0..<1.0))
    }
}

struct TransitionsView: View {
    @State private var showingItem = true
    var body: some View {
        VStack {
            if showingItem {
                Text(showingItem ? "Goodbye" : "Hello")
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 9)
                            .fill(Color.random)
                    )
                    .zIndex(1)
                    .transition(
                        .asymmetric(insertion: .opacity, removal: .scale).animation(.easeInOut(duration: 2))
                    )
            }
        }

        Button {
            showingItem.toggle()
        } label: {
            Text(showingItem ? "Hide" : "Show")
        }
        .animation(.easeInOut(duration: 2), value: showingItem)
        .zIndex(2)
    }
}

struct TransitionsView_Previews: PreviewProvider {
    static var previews: some View {
        TransitionsView()
    }
}
