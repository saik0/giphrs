//
//  ErrorView.swift
//  App
//
//  Created by esteban on 4/8/26.
//

import SwiftUI
import GiphRsCore

struct ErrorView: View {
    let error: Error
    let onRetry: () -> Void
    
    private var errorMessage: String {
        if let giphRsError = error as? GiphRsError {
            return giphRsError.message
        }
        return error.localizedDescription
    }
    
    private var recoverySuggestion: String? {
        if let giphRsError = error as? GiphRsError {
            return giphRsError.recoverySuggestion
        }
        return (error as NSError).localizedRecoverySuggestion
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Error")
                .font(.headline)
            
            Text(errorMessage)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if let suggestion = recoverySuggestion {
                Text(suggestion)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Retry") {
                onRetry()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Previews

#Preview("Network Error") {
    ErrorView(
        error: GiphRsError.NetworkError(message: "Failed to connect to the server"),
        onRetry: { }
    )
}

#Preview("Parse Error") {
    ErrorView(
        error: GiphRsError.ParseError(message: "Invalid JSON response from server"),
        onRetry: { }
    )
}

#Preview("API Error") {
    ErrorView(
        error: GiphRsError.ApiError(message: "API error 429"),
        onRetry: { }
    )
}
#Preview("Unknown Error") {
    ErrorView(
        error: GiphRsError.Unknown(message: "An unexpected error occurred"),
        onRetry: { }
    )
}

