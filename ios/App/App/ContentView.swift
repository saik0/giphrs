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
    
    var body: some View {
        // Split gifs into two columns (alternating distribution)
        let leftColumnGifs = stride(from: 0, to: viewModel.gifs.count, by: 2).map { viewModel.gifs[$0] }
        let rightColumnGifs = stride(from: 1, to: viewModel.gifs.count, by: 2).map { viewModel.gifs[$0] }
        
        ScrollView {
            HStack(alignment: .top, spacing: gridSpacing) {
                // Left column
                LazyVStack(spacing: gridSpacing) {
                    ForEach(leftColumnGifs, id: \.id) { preview in
                        PreviewWebPView(
                            preview: preview,
                            on_seen: { viewModel.on_item_seen(id: $0) }
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
                            on_seen: { viewModel.on_item_seen(id: $0) }
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
