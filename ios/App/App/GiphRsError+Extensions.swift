//
//  GiphRsError+Extensions.swift
//  App
//
//  Created by esteban on 4/8/26.
//

import Foundation
import GiphRsCore

extension GiphRsError {
    var message: String {
        switch self {
        case .NetworkError(let message):
            return message
        case .ParseError(let message):
            return message
        case .ApiError(let message):
            return message
        case .Unknown(let message):
            return message
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .NetworkError:
            return "Please check your internet connection and try again."
        case .ParseError:
            return "The response format was unexpected. Please try again later."
        case .ApiError:
            return "The API returned an error. Please try again later."
        case .Unknown:
            return "An unexpected error occurred. Please try again."
        }
    }
}
