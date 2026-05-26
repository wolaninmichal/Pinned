//
//  URLInputField.swift
//  Pinned
//
//  Created by Michał Wolanin on 20/05/2026.
//

import SwiftUI

struct URLInputField: View {
    @Binding var text: String
    var isLoading: Bool = false
    var onSubmit: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Text("https://")
                .plexStyle(.pinnedCaption.with(color: .primaryText.opacity(0.5)))

            TextField(
                "",
                text: $text,
                prompt: Text("api.example.com")
                    .font(PlexTextStyle.pinnedCaption.font)
                    .tracking(PlexTextStyle.pinnedCaption.tracking)
                    .foregroundColor(.primaryText.opacity(0.5))
            )
            .plexStyle(.pinnedCaption.with(color: .primaryText.opacity(0.7)))
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .keyboardType(.URL)
            .submitLabel(.go)
            .onSubmit(onSubmit)

            trailingControl
        }
        .padding(.leading, 16)
        .padding(.trailing, 8)
        .frame(height: 48)
        .glassCard()
    }
}

// MARK: - Subviews
private extension URLInputField {

    @ViewBuilder
    var trailingControl: some View {
        if isLoading {
            ProgressView()
                .controlSize(.small)
                .tint(.primaryText)
                .frame(width: 32, height: 32)
        } else if !text.isEmpty {
            Button(action: onSubmit) {
                IconButton("scope", size: .compact, action: onSubmit)
                    .disabled(!canSubmit)
                    .transition(.opacity.combined(with: .scale(scale: 0.85)))
            }
            .buttonStyle(.plain)
            .disabled(!canSubmit)
            .transition(.opacity.combined(with: .scale(scale: 0.85)))
        }
    }
}

// MARK: - Helpers
private extension URLInputField {

    var canSubmit: Bool {
        !text.trimmingCharacters(in: .whitespaces).isEmpty && !isLoading
    }
}

#Preview("Empty") {
    URLInputField(text: .constant(""), onSubmit: {})
        .padding()
        .background(Color.primaryBackground)
        .preferredColorScheme(.light)
}

#Preview("With text") {
    @Previewable @State var text = "api.example.com"
    return URLInputField(text: $text, onSubmit: {})
        .padding()
        .background(Color.primaryBackground)
        .preferredColorScheme(.light)
}

#Preview("Loading") {
    URLInputField(text: .constant("api.example.com"), isLoading: true, onSubmit: {})
        .padding()
        .background(Color.primaryBackground)
        .preferredColorScheme(.light)
}
