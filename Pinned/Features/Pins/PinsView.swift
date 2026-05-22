//
//  PinsView.swift
//  Pinned
//
//  Created by Michał Wolanin on 15/05/2026.
//

import SwiftUI

struct PinsView: View {
    
    let vm: PinsViewModel
    
    var body: some View {
        Text(.Pins.title)
            .font(.pinnedTitle)
            .foregroundStyle(Color.primaryText)
    }
    
}

#Preview {
    PinsView(vm: .init())
}
