//
//  IconButton.swift
//  Pinned
//
//  Created by Michał Wolanin on 25/05/2026.
//

import SwiftUI

struct IconButton: View {
    enum Size {
        case compact
        case standard

        var side: CGFloat { self == .compact ? 32 : 36 }
        var iconSize: CGFloat { self == .compact ? 16 : 15 }
        var cornerRadius: CGFloat { self == .compact ? 10 : side / 2 }
    }

    private let systemImage: String
    private let size: Size
    private let role: ButtonRole?
    private let action: () -> Void

    init(
        _ systemImage: String,
        size: Size = .standard,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) {
        self.systemImage = systemImage
        self.size = size
        self.role = role
        self.action = action
    }

    var body: some View {
        Button(role: role, action: action) {
            Image(systemName: systemImage)
                .font(.system(size: size.iconSize, weight: .medium))
        }
        .buttonStyle(GlassIconButtonStyle(size: size))
    }
}

struct GlassIconButtonStyle: ButtonStyle {
    let size: IconButton.Size

    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.primaryText)
            .frame(width: size.side, height: size.side)
            .glassCard(.elevated, cornerRadius: size.cornerRadius)
            .opacity(isEnabled ? 1 : 0.4)
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7),
                       value: configuration.isPressed)
    }
}

#Preview("Icon Buttons") {
    ZStack {
        Color.primaryBackground.ignoresSafeArea()
        HStack(spacing: 16) {
            IconButton("plus", size: .standard) {}
            IconButton("xmark", size: .standard) {}
            IconButton("plus", size: .compact) {}
            IconButton("scope", size: .compact) {}
            IconButton("plus", size: .compact) {}.disabled(true)
        }
    }
    .preferredColorScheme(.light)
}   
