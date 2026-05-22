//
//  CertificateCardView.swift
//  Pinned
//
//  Created by Michał Wolanin on 20/05/2026.
//

import SwiftUI

struct CertificateCardView: View {
    let certificate: Certificate
    let position: CertificateChain.Position

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(positionLabel)
                    .plexStyle(.pinnedCaption.with(color: .primaryText.opacity(0.7)))
                    .tracking(0.6)
                Spacer()
                keyTypeChip
            }
            .padding(.bottom, 8)

            Text(certificate.subjectCommonName)
                .plexStyle(.pinnedBody.with(color: .primaryText))
                .padding(.bottom, 2)

            Text(.Cert.issuedBy(certificate.issuerCommonName))
                .plexStyle(.pinnedCaption.with(color: .primaryText.opacity(0.6)))
                .padding(.bottom, 8)

            Divider()
                .overlay(Color.primaryText.opacity(0.15))
                .padding(.bottom, 8)

            Text(.Cert.spkiHash)
                .plexStyle(.pinnedCaption.with(color: .primaryText.opacity(0.55)))
                .tracking(0.6)
                .padding(.bottom, 3)

            Text(certificate.spkiHash)
                .plexStyle(.pinnedHash.with(color: .primaryText))
                .lineLimit(1)
                .truncationMode(.tail)
                .textSelection(.enabled)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }
}

// MARK: - Subviews
private extension CertificateCardView {

    var keyTypeChip: some View {
        Text(certificate.keyType.displayName)
            .plexStyle(.pinnedCaption.with(color: .primaryText))
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.primaryText.opacity(0.18))
            )
    }
}

// MARK: - Helpers
private extension CertificateCardView {

    var positionLabel: LocalizedStringResource {
        switch position {
        case .leaf: .Cert.positionLeaf
        case .intermediate(let index): .Cert.positionIntermediate(index)
        case .root: .Cert.positionRoot
        }
    }
}

#Preview("Certificate Card") {
   ZStack {
       Color.primaryBackground.ignoresSafeArea()
       VStack(spacing: 12) {
           CertificateCardView(
               certificate: Certificate(
                   subjectCommonName: "api.example.com",
                   issuerCommonName: "GTS CA 1P5",
                   keyType: .ecdsaP256,
                   spkiHash: "r/mIkG3eEpVdm+u/ko/cwxzOMo1bk4TyHIlByibiA5E=",
                   notBefore: Date(),
                   notAfter: Date().addingTimeInterval(86400 * 60)
               ),
               position: .leaf
           )

           CertificateCardView(
               certificate: Certificate(
                   subjectCommonName: "GTS CA 1P5",
                   issuerCommonName: "GTS Root R1",
                   keyType: .rsa2048,
                   spkiHash: "YZPgTZ+woNCCCIW3LH2CxQeLzB/0pxKj2KkmF5pj9rE=",
                   notBefore: Date(),
                   notAfter: Date().addingTimeInterval(86400 * 1500)
               ),
               position: .intermediate(index: 1)
           )
       }
       .padding()
   }
   .preferredColorScheme(.light)
}
