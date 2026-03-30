//
//  PreviewWebPView.swift
//  App
//
//  Created by saik0 on 12/1/25.
//

import SwiftUI
import GiphRsCore
import UniFFI
import Foundation

struct PreviewWebPView: View {
    private let preview: PreviewWebP
    private let on_seen: (String) -> ()
    
    init(preview: PreviewWebP, on_seen: @escaping (String) -> ()) {
        self.preview = preview
        self.on_seen = on_seen
    }
    
    var body: some View {
        if let url = URL(string: preview.url) {
            WebImageView(url: url, aspectRatio: CGFloat(preview.aspectRatio ?? 1.0))
                .aspectRatio(CGFloat(preview.aspectRatio ?? 1.0), contentMode: .fill)
                .accessibilityLabel(preview.altText)
                .onAppear(perform: {on_seen(preview.id)})
        } else {
            Color.gray
                .aspectRatio(CGFloat(preview.aspectRatio ?? 1.0), contentMode: .fill)
        }
    }
}
