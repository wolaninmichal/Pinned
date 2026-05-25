//
//  CertificateChainView.swift
//  Pinned
//
//  Created by Michał Wolanin on 20/05/2026.
//

import SwiftUI

struct CertificateChainView: View {
    let chain: CertificateChain

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            header
                .padding(.bottom, 2)

            ForEach(Array(chain.certificates.enumerated()), id: \.element.id) { index, cert in
                CertificateCardView(
                    certificate: cert,
                    position: chain.position(at: index)
                )
            }
        }
    }
}

// MARK: - Subviews
private extension CertificateChainView {

    var header: some View {
        HStack {
            Text(.Chain.count(chain.certificates.count))
                .plexStyle(.pinnedCaption.with(color: .primaryText.opacity(0.55)))
                .tracking(0.8)
            Spacer()
            Text("TLS 1.3")
                .plexStyle(.pinnedCaption.with(color: .primaryText.opacity(0.55)))
        }
    }
}

#Preview("Certificate Chain") {
    let chain = CertificateChain(certificates: [
        Certificate(
            subjectCommonName: "api.example.com",
            issuerCommonName: "GTS CA 1P5",
            keyType: .ecdsaP256,
            spkiHash: "r/mIkG3eEpVdm+u/ko/cwxzOMo1bk4TyHIlByibiA5E=",
            notBefore: Date(),
            notAfter: Date().addingTimeInterval(86400 * 60)
        ),
        Certificate(
            subjectCommonName: "GTS CA 1P5",
            issuerCommonName: "GTS Root R1",
            keyType: .rsa2048,
            spkiHash: "YZPgTZ+woNCCCIW3LH2CxQeLzB/0pxKj2KkmF5pj9rE=",
            notBefore: Date(),
            notAfter: Date().addingTimeInterval(86400 * 1500)
        )
    ])

    return ZStack {
        Color.primaryBackground.ignoresSafeArea()
        ScrollView {
            CertificateChainView(chain: chain)
                .padding()
        }
    }
    .preferredColorScheme(.light)
}
