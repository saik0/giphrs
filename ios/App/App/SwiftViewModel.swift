//
//  MyViewModel.swift
//  App
//
//  Created by saik0 on 12/1/25.
//

import SwiftUI
import GiphRsCore
import UniFFI
import Foundation
import Combine

@MainActor class SwiftViewModel : ObservableObject {
    private let nativeViewModel = RustViewModel()
    @Published var gifs: [PreviewWebP];
    @Published var is_loading: Bool;
    
    init() {
        self.gifs = nativeViewModel.getItems()
        self.is_loading = nativeViewModel.isLoading()
        
        Task {
            while !Task.isCancelled {
                guard let gifs = await nativeViewModel.pollItems() else { break }
                self.gifs = gifs
            }
        }
        
        Task {
            while !Task.isCancelled {
                guard let is_loading = await nativeViewModel.pollLoading() else { break }
                self.is_loading = is_loading
            }
        }
        
        self.refresh()
    }
    
    func refresh() {
        Task {
            await nativeViewModel.refresh()
        }
    }
    
    func on_item_seen(id: String) {
        Task {
            await nativeViewModel.onItemSeen(id: id)
        }
    }
}
