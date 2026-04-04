//
//  ContentView.swift
//  App
//
//  Created by saik0 on 10/9/25.
//

import AVKit
import SwiftUI
import GiphRsCore
import UniFFI
import Foundation
import Observation
import Combine
import _Concurrency
import SDWebImage
import SDWebImageSwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = SwiftViewModel()
    
    private let fixedWidthSize: CGFloat = 200.0
    private let gridSpacing: CGFloat = 12
    private let numCols: Int = 2
    
    private func balanceColumns(gifs: [PreviewWebP], columnWidth: CGFloat) -> ([PreviewWebP], [PreviewWebP]) {
        var leftColumn: [PreviewWebP] = []
        var rightColumn: [PreviewWebP] = []
        var leftHeight: CGFloat = 0
        var rightHeight: CGFloat = 0
        
        for gif in gifs {
            let aspectRatio = CGFloat(gif.aspectRatio ?? 1.0)
            let itemHeight = columnWidth / aspectRatio + gridSpacing
            
            if leftHeight <= rightHeight {
                leftColumn.append(gif)
                leftHeight += itemHeight
            } else {
                rightColumn.append(gif)
                rightHeight += itemHeight
            }
        }
        
        return (leftColumn, rightColumn)
    }
    
    var body: some View {
        // Split gifs into two columns (balanced distribution by height)
        let (leftColumnGifs, rightColumnGifs) = balanceColumns(gifs: viewModel.gifs, columnWidth: fixedWidthSize)
        
        ScrollView {
            HStack(alignment: .top, spacing: gridSpacing) {
                // Left column
                LazyVStack(spacing: gridSpacing) {
                    ForEach(leftColumnGifs, id: \.id) { preview in
                        PreviewWebPView(
                            preview: preview,
                            onSeen: { viewModel.on_item_seen(id: $0) }
                        )
                        .frame(width: fixedWidthSize)
                        .clipped()
                    }
                }
                .frame(width: fixedWidthSize)
                
                // Right column
                LazyVStack(spacing: gridSpacing) {
                    ForEach(rightColumnGifs, id: \.id) { preview in
                        PreviewWebPView(
                            preview: preview,
                            onSeen: { viewModel.on_item_seen(id: $0) }
                        )
                        .frame(width: fixedWidthSize)
                        .clipped()
                    }
                }
                .frame(width: fixedWidthSize)
            }
            .padding()
        }.refreshable {
            viewModel.refresh()
        }
    }
    
}

extension PreviewWebP: @retroactive Identifiable {}
