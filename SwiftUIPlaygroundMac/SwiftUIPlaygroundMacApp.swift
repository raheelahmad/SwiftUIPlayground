//
//  SwiftUIPlaygroundMacApp.swift
//  SwiftUIPlaygroundMac
//
//  Created by Raheel Ahmad on 8/11/22.
//

import SwiftUI

@main
struct SwiftUIPlaygroundMacApp: App {
    var body: some Scene {
        WindowGroup {
            PhotoGridView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
