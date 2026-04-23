package com.joelpedraza.giphrs.core

import uniffi.giphrs.GiphRsException
import java.io.IOException

/**
 * Converts a GiphRsException to a standard Kotlin Exception
 */
fun GiphRsException.toException(): Exception {
    return when (this) {
        is GiphRsException.NetworkException ->
            IOException("Network Error: ${this.message}")

        is GiphRsException.ParseException ->
            IllegalStateException("Parse Error: ${this.message}")

        is GiphRsException.ApiException ->
            Exception("API Error: ${this.message}")

        is GiphRsException.Unknown ->
            Exception("Unknown Error: ${this.message}")
    }
}

/**
 * Gets a user-friendly error message from a GiphRsException
 */
fun GiphRsException.getUserMessage(): String {
    return when (this) {
        is GiphRsException.NetworkException ->
            "Network error. Please check your connection and try again."

        is GiphRsException.ParseException ->
            "Failed to load GIFs. Please try again later."

        is GiphRsException.ApiException ->
            "The server returned an error. Please try again later."

        is GiphRsException.Unknown ->
            "An unexpected error occurred. Please try again."
    }
}
