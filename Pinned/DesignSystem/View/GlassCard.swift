//
//  GlassCard.swift
//  Pinned
//
//  Created by Michał Wolanin on 12/05/2026.
//

import SwiftUI

public struct GlassCard: ViewModifier {
    
    public enum Style {
        case regular
        case elevated
    }
    
    private let style: Style
    private let cornerRadius: CGFloat
    
    public init(
        style: Style = .regular,
        cornerRadius: CGFloat = 14
    ) {
        self.style = style
        self.cornerRadius = cornerRadius
    }
    
    public func body(content: Content) -> some View {
        content
            .background {
                if #available(iOS 26.0, *) {
                    Color.clear
                        .glassEffect(
                            .clear.tint(tintColor),
                            in: .rect(cornerRadius: cornerRadius)
                        )
                } else {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .background(
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .fill(tintColor)
                        )
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.glassStroke, lineWidth: 0.5)
            }
    }
    
    private var tintColor: Color {
        switch style {
        case .regular:
            return Color.glassFill
        case .elevated:
            return Color.glassFillElevated
        }
    }
}

public extension View {
    func glassCard(
        _ style: GlassCard.Style = .regular,
        cornerRadius: CGFloat = 14
    ) -> some View {
        modifier(
            GlassCard(
                style: style,
                cornerRadius: cornerRadius
            )
        )
    }
}

#Preview("Glass Card") {
    ZStack {
        Color.gray.opacity(0.2)
            .ignoresSafeArea()
        
        
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Regular Glass Card")
                    .font(.headline)
                    .foregroundStyle(Color.primaryText)
                
                Text("Delicate")
                    .font(.subheadline)
                    .foregroundStyle(Color.primaryText.opacity(0.75))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .glassCard(.regular)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Elevated Glass Card")
                    .font(.headline)
                    .foregroundStyle(Color.primaryText)
                
                Text("Stronger")
                    .font(.subheadline)
                    .foregroundStyle(Color.primaryText.opacity(0.75))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .glassCard(.elevated)
        }
        .padding()
    }
}
