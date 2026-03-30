//
//  WebImageView.swift
//  App
//
//  SwiftUI wrapper for WKWebView to display animated images
//

import SwiftUI
import WebKit

struct WebImageView: UIViewRepresentable {
    let url: URL
    let aspectRatio: CGFloat
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.suppressesIncrementalRendering = false
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Generate HTML with the image, maintaining aspect ratio
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
                * {
                    margin: 0;
                    padding: 0;
                }
                body {
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    width: 100vw;
                    height: 100vh;
                    overflow: hidden;
                    background: transparent;
                }
                img {
                    width: 100%;
                    height: 100%;
                    object-fit: cover;
                    display: block;
                }
            </style>
        </head>
        <body>
            <img src="\(url.absoluteString)" alt="Animated image">
        </body>
        </html>
        """
        
        webView.loadHTMLString(html, baseURL: nil)
    }
}
