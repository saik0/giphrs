package com.joelpedraza.giphrs.ui.view

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import uniffi.giphrs.PreviewWebP

@Composable
fun MainStateFlipper(
    previews: List<PreviewWebP>,
    hasError: Boolean,
    modifier: Modifier = Modifier,
    onSeen: (String) -> Unit = {},
    onForcePageRequest: () -> Unit
) {
    when {
        hasError && previews.isEmpty() -> FullPageError(modifier = modifier)
        else -> PreviewWebpGridView(
            previews = previews,
            hasError = hasError,
            modifier = modifier,
            onSeen = onSeen,
            onForcePageRequest = onForcePageRequest
        )
    }
}