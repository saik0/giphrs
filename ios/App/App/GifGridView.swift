//
//  GifGridView.swift
//  App
//
//  Created by esteban on 4/8/26.
//

import SwiftUI
import GiphRsCore

struct GifGridView: View {
    let gifs: [PreviewWebP]
    let columnWidth: CGFloat
    let spacing: CGFloat
    let onSeen: (String) -> Void
    
    private func balanceColumns(gifs: [PreviewWebP], columnWidth: CGFloat) -> ([PreviewWebP], [PreviewWebP]) {
        var leftColumn: [PreviewWebP] = []
        var rightColumn: [PreviewWebP] = []
        var leftHeight: CGFloat = 0
        var rightHeight: CGFloat = 0
        
        for gif in gifs {
            // Validate and clamp aspect ratio to reasonable bounds
            let aspectRatio = max(0.1, min(10.0, CGFloat(gif.aspectRatio ?? 1.0)))
            let itemHeight = columnWidth / aspectRatio
            
            // Add to shorter column
            if leftHeight <= rightHeight {
                leftColumn.append(gif)
                leftHeight += itemHeight + (leftColumn.count > 1 ? spacing : 0)
            } else {
                rightColumn.append(gif)
                rightHeight += itemHeight + (rightColumn.count > 1 ? spacing : 0)
            }
        }
        
        return (leftColumn, rightColumn)
    }
    
    var body: some View {
        let (leftColumnGifs, rightColumnGifs) = balanceColumns(gifs: gifs, columnWidth: columnWidth)
        
        ScrollView {
            HStack(alignment: .top, spacing: spacing) {
                // Left column
                LazyVStack(spacing: spacing) {
                    ForEach(leftColumnGifs, id: \.id) { preview in
                        PreviewWebPView(
                            preview: preview,
                            onSeen: { onSeen($0) }
                        )
                        .frame(width: columnWidth)
                        .clipped()
                    }
                }
                .frame(width: columnWidth)
                
                // Right column
                LazyVStack(spacing: spacing) {
                    ForEach(rightColumnGifs, id: \.id) { preview in
                        PreviewWebPView(
                            preview: preview,
                            onSeen: { onSeen($0) }
                        )
                        .frame(width: columnWidth)
                        .clipped()
                    }
                }
                .frame(width: columnWidth)
            }
            .padding()
        }
    }
}
