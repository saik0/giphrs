//
//  ErrorView.swift
//  App
//
//  Created by esteban on 4/8/26.
//

import SwiftUI

struct ErrorView: View {
    let error: Error
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Error")
                .font(.headline)
            Text(error.localizedDescription)
                .foregroundColor(.secondary)
            Button("Retry") {
                onRetry()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview {
    ErrorView(
        error: NSError(
            domain: "com.giphrs.app",
            code: 1001,
            userInfo: [
                NSLocalizedDescriptionKey: "Failed to load GIFs",
                NSLocalizedRecoverySuggestionErrorKey: "Please check your internet connection and try again."
            ]
        ),
        onRetry: { }
    )
}
