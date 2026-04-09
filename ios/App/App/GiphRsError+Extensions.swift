//
//  GiphRsError+Extensions.swift
//  App
//
//  Created by esteban on 4/8/26.
//

import Foundation
import GiphRsCore

// Extension to convert UniFFI-generated GiphRsError to NSError
extension GiphRsError {
    func toNSError() -> NSError {
        switch self {
        case .networkError(let message):
            return NSError(
                domain: "com.giphrs.app",
                code: 1001,
                userInfo: [
                    NSLocalizedDescriptionKey: "Network Error",
                    NSLocalizedFailureReasonErrorKey: message,
                    NSLocalizedRecoverySuggestionErrorKey: "Please check your internet connection and try again."
                ]
            )
            
        case .parseError(let details):
            return NSError(
                domain: "com.giphrs.app",
                code: 1002,
                userInfo: [
                    NSLocalizedDescriptionKey: "Parse Error",
                    NSLocalizedFailureReasonErrorKey: details,
                    NSLocalizedRecoverySuggestionErrorKey: "The response format was unexpected. Please try again later."
                ]
            )
            
        case .apiError(let code, let message):
            return NSError(
                domain: "com.giphrs.app",
                code: Int(code),
                userInfo: [
                    NSLocalizedDescriptionKey: "API Error",
                    NSLocalizedFailureReasonErrorKey: message,
                    NSLocalizedRecoverySuggestionErrorKey: "The API returned an error. Please try again later."
                ]
            )
            
        case .unknown(let message):
            return NSError(
                domain: "com.giphrs.app",
                code: 9999,
                userInfo: [
                    NSLocalizedDescriptionKey: "Unknown Error",
                    NSLocalizedFailureReasonErrorKey: message,
                    NSLocalizedRecoverySuggestionErrorKey: "An unexpected error occurred. Please try again."
                ]
            )
        }
    }
}
