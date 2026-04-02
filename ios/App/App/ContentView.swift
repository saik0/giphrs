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
        let columns = Array(
            repeating: GridItem(
                .adaptive(minimum: fixedWidthSize, maximum: .greatestFiniteMagnitude),
                spacing: gridSpacing
            ),
            count: numCols
        )
        
        ScrollView {
            LazyVGrid(columns: columns, spacing: gridSpacing) {
                ForEach(viewModel.gifs, id: \.id) { preview in
                    PreviewWebPView(
                        preview: preview,
                        on_seen: { viewModel.on_item_seen(id: $0) }
                    )//.frame(width: fixedWidthSize)
                    // , height: fixedWidthSize / CGFloat(preview.aspectRatio ?? 1.0))
                }
            }
            .padding()
        }.refreshable {
            viewModel.refresh()
        }
    }
    
}

extension PreviewWebP: @retroactive Identifiable {}
