package com.joelpedraza.giphrs.ui.view

import android.content.Intent
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import coil3.compose.AsyncImage
import com.joelpedraza.giphrs.ui.MainActivity
import uniffi.giphrs.PreviewWebP

@Composable
fun PreviewWebPView(gif: PreviewWebP, onSeen: (String) -> Unit) {
    val context = LocalContext.current
    val intent = Intent(context, MainActivity::class.java)
    val onClick: () -> Unit = {
        context.startActivity(intent)
    }
    AsyncImage(
        model = gif.url,
        contentDescription = gif.altText,
        modifier = Modifier
            .aspectRatio(ratio = gif.aspectRatio ?: 1f)
            .fillMaxWidth()
            .clip(RoundedCornerShape(4.dp))
            .clickable(
                onClick = onClick
            ),
        onSuccess = { _ -> onSeen(gif.id) },
    )
}