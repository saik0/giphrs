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

enum State {
    case isLoading
    case loaded([PreviewWebP])
    case error(_ error: Error)
}

@MainActor class SwiftViewModel : ObservableObject {
    private let nativeViewModel = RustViewModel()
    @Published var gifs: [PreviewWebP];
    @Published var is_loading: Bool;
    @Published var has_error: Bool;
    
    @Published var state: State = .isLoading
    
    init() {
        self.gifs = nativeViewModel.getItems()
        self.is_loading = nativeViewModel.isLoading()
        self.has_error = nativeViewModel.hasError()
        Task {
            while !Task.isCancelled {
                guard let gifs = await nativeViewModel.pollItems() else { break }
//                guard self.gifs != gifs else { break }
                self.gifs = gifs
                
                //  - 0 : "3hIMJ6iFK2omLMh5Nz"
                //   - 49 : "udmx3pgdiD7tm"
            }
        }
        
        Task {
            while !Task.isCancelled {
                guard let is_loading = await nativeViewModel.pollLoading() else { break }
                self.is_loading = is_loading
            }
        }
        
        Task {
            while !Task.isCancelled {
                guard let has_error = await nativeViewModel.pollError() else { break }
                self.has_error = has_error
            }
        }
        
        self.refresh()
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
