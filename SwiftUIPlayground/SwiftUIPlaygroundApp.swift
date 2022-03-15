//
//  SwiftUIPlaygroundApp.swift
//  SwiftUIPlayground
//
//  Created by Raheel Ahmad on 10/26/21.
//

import SwiftUI

@main
struct SwiftUIPlaygroundApp: App {
    var body: some Scene {
        WindowGroup {
            FlowLayoutRevisitedView(
                items: [
                    Item(
                        id: UUID(),
                        text: "Once Upon a time"
                    ),
                    Item(
                        id: UUID(),
                        text: "Nowhere to go"
                    ),
                    Item(
                        id: UUID(),
                        text: "Lala"
                    )
                ].shuffled()
            )
        }
    }
}
