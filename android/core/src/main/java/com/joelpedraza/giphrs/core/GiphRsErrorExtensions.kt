package com.joelpedraza.giphrs.core

import uniffi.giphrs.GiphRsError
import java.io.IOException

/**
 * Converts a GiphRsError to a standard Kotlin Exception
 */
fun GiphRsError.toException(): Exception {
    return when (this) {
        is GiphRsError.NetworkError ->
            IOException("Network Error: ${this.message}")

        is GiphRsError.ParseError ->
            IllegalStateException("Parse Error: ${this.details}")

        is GiphRsError.ApiError ->
            Exception("API Error ${this.code}: ${this.message}")

        is GiphRsError.Unknown ->
            Exception("Unknown Error: ${this.message}")
    }
}

/**
 * Gets a user-friendly error message from a GiphRsError
 */
fun GiphRsError.getUserMessage(): String {
    return when (this) {
        is GiphRsError.NetworkError ->
            "Network error. Please check your connection and try again."

        is GiphRsError.ParseError ->
            "Failed to load GIFs. Please try again later."

        is GiphRsError.ApiError ->
            "The server returned an error. Please try again later."

        is GiphRsError.Unknown ->
            "An unexpected error occurred. Please try again."
    }
}
