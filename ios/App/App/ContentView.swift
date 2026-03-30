//
//  ContentView.swift
//  App
//
//  Created by saik0 on 10/9/25.
//

import SwiftUI
import GiphRsCore
import UniFFI
import Foundation

let FIXED_WIDTH_SIZE: CGFloat = 200.0
let GRID_SPACING: CGFloat = 12
let MAX_COLS: Int = 4

struct ContentView: View {
    @ObservedObject var viewModel = SwiftViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            let num_cols = min(MAX_COLS, max(1, Int(geometry.size.width / (FIXED_WIDTH_SIZE + GRID_SPACING))))
            
            let columns = Array(repeating: GridItem(.flexible(minimum: FIXED_WIDTH_SIZE, maximum: FIXED_WIDTH_SIZE)), count: num_cols)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: GRID_SPACING) {
                    ForEach(viewModel.gifs, id: \.id) { preview in
                        PreviewWebPView(
                            preview: preview,
                            on_seen: { viewModel.on_item_seen(id: $0) }
                        ).frame(width: FIXED_WIDTH_SIZE, height: FIXED_WIDTH_SIZE / CGFloat(preview.aspectRatio ?? 1.0))
                    }
                }
                .padding()
            }.refreshable {
                viewModel.refresh()
            }
        }
    }
    
}

extension PreviewWebP: @retroactive Identifiable {}
