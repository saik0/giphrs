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
    let onRequestNextPage: () -> Void
    
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
                    ForEach(Array(leftColumnGifs.enumerated()), id: \.element.id) { index, preview in
                        PreviewWebPView(
                            preview: preview,
                            onSeen: { onSeen($0) }
                        )
                        .frame(width: columnWidth)
                        .clipped()
                        .onAppear {
                            // Request next page when approaching the end (last 3 items)
                            if index >= leftColumnGifs.count - 3 {
                                onRequestNextPage()
                            }
                        }
                    }
                }
                .frame(width: columnWidth)
                
                // Right column
                LazyVStack(spacing: spacing) {
                    ForEach(Array(rightColumnGifs.enumerated()), id: \.element.id) { index, preview in
                        PreviewWebPView(
                            preview: preview,
                            onSeen: { onSeen($0) }
                        )
                        .frame(width: columnWidth)
                        .clipped()
                        .onAppear {
                            // Request next page when approaching the end (last 3 items)
                            if index >= rightColumnGifs.count - 3 {
                                onRequestNextPage()
                            }
                        }
                    }
                }
                .frame(width: columnWidth)
            }
            .padding()
        }
    }
}

// MARK: - Preview

#Preview {
    let mockGifs = [
        PreviewWebP(id: "1", altText: "Cat GIF", url: "https://media.giphy.com/media/placeholder1/giphy.gif", aspectRatio: 1.0),
        PreviewWebP(id: "2", altText: "Dog GIF", url: "https://media.giphy.com/media/placeholder2/giphy.gif", aspectRatio: 1.5),
        PreviewWebP(id: "3", altText: "Bird GIF", url: "https://media.giphy.com/media/placeholder3/giphy.gif", aspectRatio: 0.75),
        PreviewWebP(id: "4", altText: "Fish GIF", url: "https://media.giphy.com/media/placeholder4/giphy.gif", aspectRatio: 1.2),
        PreviewWebP(id: "5", altText: "Rabbit GIF", url: "https://media.giphy.com/media/placeholder5/giphy.gif", aspectRatio: 0.9),
        PreviewWebP(id: "6", altText: "Turtle GIF", url: "https://media.giphy.com/media/placeholder6/giphy.gif", aspectRatio: 1.3),
    ]
    
    GifGridView(
        gifs: mockGifs,
        columnWidth: 200,
        spacing: 12,
        onSeen: { _ in },
        onRequestNextPage: { }
    )
}
