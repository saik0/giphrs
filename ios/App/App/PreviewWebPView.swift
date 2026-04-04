//
//  PreviewWebPView.swift
//  App
//
//  Created by saik0 on 12/1/25.
//


import AVKit
import SwiftUI
import GiphRsCore
import UniFFI
import Foundation
import Observation
import Combine
import SDWebImage
import SDWebImageSwiftUI

struct PreviewWebPView: View {
    private let preview: PreviewWebP
    private let onSeen: (String) -> ()
    
    init(preview: PreviewWebP, onSeen: @escaping (String) -> ()) {
        self.preview = preview
        self.onSeen = onSeen
    }
    
    var body: some View {
        AnimatedImage(url: URL(string: preview.url).unsafelyUnwrapped) {
            ShimmerPlaceholder()
                .aspectRatio(CGFloat(preview.aspectRatio ?? 1.0), contentMode: .fit)
        }
        .resizable()
        .scaledToFit()
        .aspectRatio(CGFloat(preview.aspectRatio ?? 1.0), contentMode: .fit)
        .accessibilityLabel(preview.altText)
        .onAppear { onSeen(preview.id) }
    }
}
// Shimmer loading placeholder
struct ShimmerPlaceholder: View {
    @State private var phase: CGFloat = 0
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(white: 0.9),  // Light grey at top-left
                        Color(white: 0.75)  // Darker grey at bottom-right
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .clear, location: phase - 0.2),
                        .init(color: Color.white.opacity(0.5), location: phase),
                        .init(color: .clear, location: phase + 0.2)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .onAppear {
                withAnimation(.linear(duration: 0.5).repeatForever(autoreverses: true)) {
                    phase = 1.4
                }
            }
    }
}


#Preview {
    ShimmerPlaceholder()
        .aspectRatio(CGFloat(1.0), contentMode: .fit)
}

#Preview {
    PreviewWebPView(preview: .init(id: "", altText: "", url: "", aspectRatio: 1.0)) {_ in }
}
