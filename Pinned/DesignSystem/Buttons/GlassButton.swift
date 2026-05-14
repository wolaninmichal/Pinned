//
//  GlassButton.swift
//  Pinned
//
//  Created by Michał Wolanin on 12/05/2026.
//

import SwiftUI

public struct GlassButtonStyle: ButtonStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.pinnedHeading)
            .foregroundStyle(Color.primaryText)
            .padding(12)
            .glassCard(.elevated)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring, value: configuration.isPressed)
    }
    
}

#Preview("Glass Button Style") {
    ZStack {
        Color.gray.opacity(0.2)
            .ignoresSafeArea()

        VStack(spacing: 16) {
            Button("Inspect connection") {
                print("Tapped")
            }
            .buttonStyle(GlassButtonStyle())

            Button {
                print("Tapped with icon")
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "link")
                    Text("Inspect connection")
                }
            }
            .buttonStyle(GlassButtonStyle())
        }
        .padding()
    }
}
