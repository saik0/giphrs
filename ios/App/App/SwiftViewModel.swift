//
//  MyViewModel.swift
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
import _Concurrency
import SDWebImage
import SDWebImageSwiftUI


@MainActor class SwiftViewModel : ObservableObject {

    public enum State {
        case loading
        case loaded([PreviewWebP])
        case error(_ error: Error)
    }

    private let nativeViewModel = RustViewModel()
    
    @Published var state: State
    
    private var itemsPollingTask: Task<Void, Never>?
    private var loadingPollingTask: Task<Void, Never>?
    private var errorPollingTask: Task<Void, Never>?
    
    init() {
        // Initialize state with current items
        let initialGifs = nativeViewModel.getItems()
        if !initialGifs.isEmpty {
            self.state = .loaded(initialGifs)
        } else {
            self.state = .loading
        }
    }
    
    func start() {
        startPolling()
        refresh()
    }
    
    private func startPolling() {
        // Poll for items updates
        itemsPollingTask = Task {
            while !Task.isCancelled {
                guard let gifs = await nativeViewModel.pollItems() else { break }
                if !gifs.isEmpty, case .loading = self.state {
                    self.state = .loaded(gifs)
                } else if case .loaded = self.state {
                    self.state = .loaded(gifs)
                }
            }
        }
        
        // Poll for loading state
        loadingPollingTask = Task {
            while !Task.isCancelled {
                guard let isLoading = await nativeViewModel.pollLoading() else { break }
                if isLoading, case .loading = self.state {
                    // Only set loading if we're already in loading state
                    self.state = .loading
                } else if isLoading, case .error = self.state {
                    // Transition from error to loading if refreshing
                    self.state = .loading
                }
            }
        }
        
        // Poll for error state
        errorPollingTask = Task {
            while !Task.isCancelled {
                guard let hasError = await nativeViewModel.pollError() else { break }
                if hasError {
                    self.state = .error(NSError(
                        domain: "com.giphrs.app",
                        code: 1001,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Failed to load GIFs",
                            NSLocalizedRecoverySuggestionErrorKey: "Please check your internet connection and try again."
                        ]
                    ))
                }
            }
        }
    }
    
    deinit {
        itemsPollingTask?.cancel()
        loadingPollingTask?.cancel()
        errorPollingTask?.cancel()
    }
    
    func refresh() {
        Task {
            await nativeViewModel.refresh()
        }
    }
    
    func onSeen(id: String) {
        Task {
            await nativeViewModel.onItemSeen(id: id)
        }
    }
    
    func requestNextPage() {
        Task {
            await nativeViewModel.requestNextPage()
        }
    }
}
