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
    private let on_seen: (String) -> ()
    
    init(preview: PreviewWebP, on_seen: @escaping (String) -> ()) {
        self.preview = preview
        self.on_seen = on_seen
    }
    
    var body: some View {
        AnimatedImage(url: URL(string: preview.url).unsafelyUnwrapped)
            .resizable()
            .scaledToFit()
            .aspectRatio(CGFloat(preview.aspectRatio ?? 1.0), contentMode: .fit)
            .accessibilityLabel(preview.altText)
            .onAppear(perform: {on_seen(preview.id)})
    }
}
