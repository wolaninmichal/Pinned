//
//  TabBarChrome.swift
//  Pinned
//
//  Created by Michał Wolanin on 12/05/2026.
//

import SwiftUI

public struct TabBarChrome: View {
    public enum Tab: Hashable {
        case inspect, pins
    }
    
    @Binding var selection: Tab
    @Namespace private var bubbleNamespace
    
    public init(selection: Binding<Tab>) {
        self._selection = selection
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            tabButton(.inspect, icon: "scope", label: "Inspect")
            tabButton(.pins, icon: "pin", label: "Pins")
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 6)
        .glassCard(.elevated, cornerRadius: 28)
        .animation(
            .interactiveSpring(
                response: 0.36,
                dampingFraction: 0.68,
                blendDuration: 0.12
            ),
            value: selection
        )
    }
}

public extension TabBarChrome {
    private func tabButton(
        _ tab: Tab,
        icon: String,
        label: String
    ) -> some View {
        Button {
            withAnimation(
                .interactiveSpring(
                    response: 0.38,
                    dampingFraction: 0.62,
                    blendDuration: 0.1
                )
            ) {
                selection = tab
            }
        } label: {
            VStack(spacing: 0) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                
                Text(label)
                    .font(.pinnedCaption)
            }
            .foregroundStyle(Color.primaryText)
            .opacity(selection == tab ? 1.0 : 0.55)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .padding(.horizontal, 20)
            .background {
                if selection == tab {
                    GlassTabBubble()
                        .matchedGeometryEffect(
                            id: "tabBubble",
                            in: bubbleNamespace
                        )
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct GlassTabBubble: View {
    var body: some View {
        Capsule()
            .fill(.ultraThinMaterial)
            .overlay {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.34),
                                .white.opacity(0.12),
                                .white.opacity(0.04)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .overlay {
                Capsule()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.75),
                                .white.opacity(0.18),
                                .black.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            }
            .shadow(
                color: .black.opacity(0.10),
                radius: 10,
                x: 0,
                y: 6
            )
            .shadow(
                color: .white.opacity(0.28),
                radius: 2,
                x: -1,
                y: -1
            )
    }
}

#Preview("Tab Bar Chrome") {
    @Previewable @State var selection: TabBarChrome.Tab = .inspect
    
    ZStack {
        VStack {
            Spacer()
            TabBarChrome(selection: $selection)
                .padding(.horizontal, 62)
                .padding(.bottom, 24)
        }
    }
    .preferredColorScheme(.light)
}
