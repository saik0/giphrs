//
//  ContentView.swift
//  App
//
//  Created by saik0 on 10/9/25.
//

import SwiftUI
import GiphRsCore
import Combine

struct ContentView<VM: ViewModelProtocol>: View {
    @ObservedObject var viewModel: VM
    
    private let fixedWidthSize: CGFloat = 200.0
    private let gridSpacing: CGFloat = 12
    
    init(viewModel: VM) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            case .loaded(let gifs):
                GifGridView(
                    gifs: gifs,
                    columnWidth: fixedWidthSize,
                    spacing: gridSpacing,
                    onSeen: viewModel.onSeen,
                    onRequestNextPage: viewModel.requestNextPage
                )
                .refreshable {
                    viewModel.refresh()
                }
                
            case .error(let error):
                ErrorView(error: error, onRetry: viewModel.refresh)
            }
        }
        .onAppear {
            viewModel.start()
        }
    }
}

extension PreviewWebP: @retroactive Identifiable {}

// MARK: - Previews

#Preview("Loading State") {
    ContentView(viewModel: MockViewModel(state: .loading))
}

#Preview("Loaded State") {
    let mockGifs = [
        PreviewWebP(id: "1", altText: "Cat GIF", url: "https://media.giphy.com/media/placeholder1/giphy.gif", aspectRatio: 1.0),
        PreviewWebP(id: "2", altText: "Dog GIF", url: "https://media.giphy.com/media/placeholder2/giphy.gif", aspectRatio: 1.5),
        PreviewWebP(id: "3", altText: "Bird GIF", url: "https://media.giphy.com/media/placeholder3/giphy.gif", aspectRatio: 0.75),
        PreviewWebP(id: "4", altText: "Fish GIF", url: "https://media.giphy.com/media/placeholder4/giphy.gif", aspectRatio: 1.2),
    ]
    ContentView(viewModel: MockViewModel(state: .loaded(mockGifs)))
}

#Preview("Error State") {
    let error = NSError(domain: "PreviewError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load GIFs. Please try again."])
    ContentView(viewModel: MockViewModel(state: .error(error)))
}

// MARK: - Mock ViewModel for Previews

@MainActor
class MockViewModel: ViewModelProtocol, ObservableObject {
    
    @Published var state: SwiftViewModel.State
    
    init(state: SwiftViewModel.State) {
        self.state = state
    }
    
    func start() {}
    func refresh() {}
    func onSeen(id: String) {}
    func requestNextPage() {}
}

