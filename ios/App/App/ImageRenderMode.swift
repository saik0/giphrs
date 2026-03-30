//
//  ImageRenderMode.swift
//  App
//
//  Configuration for image rendering mode
//

import Foundation

enum ImageRenderMode: String, CaseIterable, Identifiable {
    case sdWebImage = "SDWebImage"
    case wkWebView = "WKWebView"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .sdWebImage:
            return "SDWebImage (Optimized)"
        case .wkWebView:
            return "WKWebView (WebKit)"
        }
    }
}

@MainActor
class RenderConfiguration: ObservableObject {
    @Published var renderMode: ImageRenderMode = .sdWebImage
    
    static let shared = RenderConfiguration()
    
    private init() {}
}
