//
//  PinsUpsertView.swift
//  Pinned
//
//  Created by Michał Wolanin on 22/05/2026.
//

import SwiftUI

struct PinUpsertView: View {

    @Bindable var vm: PinUpsertViewModel

    let onSave: (PinSet) -> Void
    let onCancel: () -> Void

    @FocusState private var hashFieldFocused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header

                domainSection
        
                subdomainsToggle
                    .padding(.top, -8) // todo

                hashesSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .background(Color.primaryBackground.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            saveBar
        }
    }
}

// MARK: - Subviews
private extension PinUpsertView {

    var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(vm.isEditing ? .PinEditor.editEyebrow : .PinEditor.createEyebrow)
                    .plexStyle(.pinnedCaption.with(color: .primaryText.opacity(0.55)))
                    .tracking(1.2)
                Text(vm.isEditing ? .PinEditor.editTitle : .PinEditor.createTitle)
                    .plexStyle(.pinnedTitle.with(color: .primaryText))
            }

            Spacer()

            IconButton("xmark", role: .cancel, action: onCancel)
        }
    }

    var domainSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(.PinEditor.domainLabel)
                .plexStyle(.pinnedCaption.with(color: .primaryText.opacity(0.55)))
                .tracking(0.8)

            HStack(spacing: 0) {
                Text("https://")
                    .plexStyle(.pinnedCaption.with(color: .primaryText.opacity(0.5)))

                TextField(
                    "",
                    text: $vm.domain,
                    prompt: Text(.PinEditor.domainPrompt)
                        .font(PlexTextStyle.pinnedCaption.font)
                        .foregroundColor(.primaryText.opacity(0.5))
                )
                .plexStyle(.pinnedCaption.with(color: .primaryText.opacity(0.7)))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.URL)
            }
            .padding(.horizontal, 16)
            .frame(height: 48)
            .glassCard()
        }
    }

    var subdomainsToggle: some View {
        Toggle(isOn: $vm.includeSubdomains) {
            Text(.PinEditor.includeSubdomains)
                .plexStyle(.pinnedBody.with(color: .primaryText))
        }
        .tint(Color.glassFillElevated)
        .padding(.horizontal, 16)
        .frame(minHeight: 48)
        .glassCard()
    }

    var hashesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(vm.hashes.isEmpty ? .PinEditor.hashesLabel : .PinEditor.hashCount(vm.hashes.count))
                .plexStyle(.pinnedCaption.with(color: .primaryText.opacity(0.55)))
                .tracking(0.8)
                .animation(nil, value: vm.hashes.count)
            
            hashInputRow
            
            if let error = vm.validationError {
                validationLabel(error)
            }
            
            if vm.hashes.isEmpty {
                hashesPlaceholder
            } else {
                ForEach(vm.hashes, id: \.self) { hash in
                    UpsertHashRow(hash: hash) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            vm.removeHash(hash)
                        }
                    }
                }
            }
        }
    }

    var hashInputRow: some View {
        HStack(spacing: 8) {
            TextField(
                "",
                text: $vm.draftHash,
                prompt: Text(.PinEditor.hashPrompt)
                    .font(PlexTextStyle.pinnedHash.font)
                    .foregroundColor(.primaryText.opacity(0.5))
            )
            .plexStyle(.pinnedHash.with(color: .primaryText))
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .focused($hashFieldFocused)
            .submitLabel(.done)
            .onSubmit(addHashAndRefocus)

            IconButton("plus", size: .compact, action: addHashAndRefocus)
                .disabled(!vm.canAddHash)
                .opacity(vm.canAddHash ? 1 : 0.4)
        }
        .padding(.leading, 16)
        .padding(.trailing, 8)
        .frame(height: 48)
        .glassCard()
    }

    func hashRow(_ hash: String) -> some View {
        HStack(spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false){
                Text(hash)
                    .plexStyle(.pinnedHash.with(color: .primaryText))
                    .textSelection(.enabled)
                    .padding(.horizontal, 6)
            }
            .scrollClipDisabled(false)

            Spacer(minLength: 0)

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    vm.removeHash(hash)
                }
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.primaryText.opacity(0.55))
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
        }
        .padding(.leading, 14)
        .padding(.trailing, 6)
        .frame(height: 44)
        .glassCard()
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    var hashesPlaceholder: some View {
        Text(.PinEditor.hashesEmpty)
            .plexStyle(.pinnedCaption.with(color: .primaryText.opacity(0.45)))
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 24)
    }

    func validationLabel(_ error: PinUpsertViewModel.ValidationError) -> some View {
        Text(messageFor(error))
            .plexStyle(.pinnedCaption.with(color: .matchFailure))
            .transition(.opacity)
    }

    var saveBar: some View {
        Button(action: { onSave(vm.buildPinSet()) }) {
            Text(.PinEditor.save)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(GlassButtonStyle())
        .disabled(!vm.canSave)
        .opacity(vm.canSave ? 1 : 0.5)
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 12)
    }
}

// MARK: - Helpers
private extension PinUpsertView {

    func addHashAndRefocus() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            vm.addHash()
        }
        hashFieldFocused = true
    }

    func messageFor(_ error: PinUpsertViewModel.ValidationError) -> LocalizedStringResource {
        switch error {
        case .invalidFormat: .PinEditor.invalidHashFormat
        case .duplicate: .PinEditor.duplicateHash
        }
    }
}

// MARK: - Previews

#Preview("Create") {
    PinUpsertView(
        vm: PinUpsertViewModel(mode: .create),
        onSave: { _ in },
        onCancel: {}
    )
    .preferredColorScheme(.light)
}

#Preview("Edit") {
    PinUpsertView(
        vm: PinUpsertViewModel(mode: .edit(
            PinSet(
                domain: "api.example.com",
                hashes: [
                    "r/mIkG3eEpVdm+u/ko/cwxzOMo1bk4TyHIlByibiA5E=",
                    "YZPgTZ+woNCCCIW3LH2CxQeLzB/0pxKj2KkmF5pj9rE="
                ],
                includeSubdomains: true
            )
        )),
        onSave: { _ in },
        onCancel: {}
    )
    .preferredColorScheme(.light)
}
