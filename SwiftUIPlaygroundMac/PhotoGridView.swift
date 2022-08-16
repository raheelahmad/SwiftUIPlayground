//
//  PhotoGridView.swift
//  SwiftUIPlaygroundMac
//
//  Created by Raheel Ahmad on 8/11/22.
//

import SwiftUI

struct TransitionModifier: ViewModifier {
    var active: Bool

    func body(content: Content) -> some View {
        content
            .overlay(active ? Color.red : .clear)
    }
}

struct PhotoGridView: View {
    private let imageNames = "a b c d e f g h i".split(separator: " ")
        .map { String($0) }
    @State private var selected: String?
    @State private var slowAnimations = false
    @Namespace var ns
    @Namespace var dummyNS

    private var photoGrid: some View {

        ScrollView {
            LazyVGrid(columns: [.init(.adaptive(minimum: 100, maximum: .infinity), spacing: 3)]) {
                ForEach(imageNames, id: \.self) { name in
                    Image(name)
                        .resizable()
                        .matchedGeometryEffect(id: name, in: ns)
                        .aspectRatio(contentMode: .fill)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .clipped()
                        .aspectRatio(1, contentMode: .fit)
                        .onTapGesture {
                            selected = name
                        }
                }
            }
        }

    }
    var body: some View {
        ZStack {
            VStack {
                Toggle("Slow Animations", isOn: $slowAnimations)

                photoGrid
                    .opacity(selected == nil ? 1 : 0.2)
            }

            if let selected = selected {
                Image(selected)
                    .resizable()
                    .matchedGeometryEffect(id: selected, in: ns, isSource: false)
                    .aspectRatio(contentMode: .fit)
                    .onTapGesture {
                        self.selected = nil
                    }
                    .transition(.modifier(active: TransitionModifier(active: true), identity: TransitionModifier(active: false)))
            }
        }.animation(.easeInOut(duration: slowAnimations ? 2.0 : 0.3), value: selected)
    }
}

struct PhotoGridView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoGridView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
