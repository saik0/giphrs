package com.joelpedraza.giphrs.ui.view

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp

@Composable
fun PaginationError(
    modifier: Modifier = Modifier,
    onForcePageRequest: () -> Unit
) {
    Text(
        "Page Error",
        textAlign = TextAlign.Center,
        modifier = modifier
            .fillMaxWidth()
            .padding(16.dp)
            .clickable {
                onForcePageRequest()
            }
    )
}