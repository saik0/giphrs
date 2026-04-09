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
    
    @Published var state: State = .loading
    
    private var itemsPollingTask: Task<Void, Never>?
    private var loadingPollingTask: Task<Void, Never>?
    private var errorPollingTask: Task<Void, Never>?
    
    init() {
        // Initialize state with current items
        let initialGifs = nativeViewModel.getItems()
        if !initialGifs.isEmpty {
            self.state = .loaded(initialGifs)
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
                guard let is_loading = await nativeViewModel.pollLoading() else { break }
                if is_loading, case .loading = self.state {
                    // Only set loading if we're already in loading state
                    self.state = .loading
                } else if is_loading, case .error = self.state {
                    // Transition from error to loading if refreshing
                    self.state = .loading
                }
            }
        }
        
        // Poll for error state
        errorPollingTask = Task {
            while !Task.isCancelled {
                guard let has_error = await nativeViewModel.pollError() else { break }
                if has_error {
                    // Get the current items to include in error state if needed
                    let currentGifs = nativeViewModel.getItems()
                    self.state = .error(NSError(domain: "SwiftViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "An error occurred"]))
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
