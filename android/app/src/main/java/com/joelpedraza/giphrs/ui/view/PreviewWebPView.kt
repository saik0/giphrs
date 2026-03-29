package com.joelpedraza.giphrs.ui.view

import android.content.Intent
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.MutableTransitionState
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.layout.onFirstVisible
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import coil3.compose.AsyncImagePainter
import coil3.compose.SubcomposeAsyncImage
import coil3.compose.SubcomposeAsyncImageContent
import com.joelpedraza.giphrs.R
import com.joelpedraza.giphrs.ui.MainActivity
import uniffi.giphrs.PreviewWebP
import kotlin.random.Random

@Composable
fun PreviewWebPView(gif: PreviewWebP, onSeen: (String) -> Unit) {
    val context = LocalContext.current
    val intent = Intent(context, MainActivity::class.java)
    val onClick: () -> Unit = {
        context.startActivity(intent)
    }

    SubcomposeAsyncImage(
        model = gif.url,
        contentDescription = gif.altText,
        modifier = Modifier
            .aspectRatio(ratio = gif.aspectRatio ?: 1f)
            .fillMaxWidth()
            .clip(RoundedCornerShape(4.dp))
            .onFirstVisible { onSeen(gif.id) }
            .background(MaterialTheme.colorScheme.surfaceVariant)

    ) {
        val painter = painter
        val state by painter.state.collectAsState()

        when (state) {
            is AsyncImagePainter.State.Loading, AsyncImagePainter.State.Empty -> {
                // A state that immediately transitions from not visible to visible
                val visibleState = remember {
                    MutableTransitionState(false).apply { targetState = true }
                }

                // Rotate by some random degrees so initial loads don't all look the same
                val randomRotation = remember { Random.nextFloat() * 90f - 45f }

                Box(
                    contentAlignment = Alignment.Center,
                    modifier = Modifier.fillMaxSize(),
                ) {
                    AnimatedVisibility(
                        visibleState = visibleState,
                        enter = fadeIn(
                            animationSpec = tween(delayMillis = 250, durationMillis = 500)
                        )
                    ) {
                        CircularProgressIndicator(
                            modifier = Modifier
                                .size(48.dp)
                                .rotate(randomRotation),
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }
                }
            }

            is AsyncImagePainter.State.Error -> {
                Box(
                    contentAlignment = Alignment.Center,
                    modifier = Modifier
                        .fillMaxSize()
                        .clickable { painter.restart() },
                ) {
                    Icon(
                        painter = painterResource(id = R.drawable.ic_error_outline_24),
                        contentDescription = "Tap to retry",
                        tint = MaterialTheme.colorScheme.onSurfaceVariant,
                        modifier = Modifier.size(48.dp)
                    )
                }
            }

            is AsyncImagePainter.State.Success -> {
                Box(
                    modifier = Modifier.fillMaxSize()
                ) {
                    this@SubcomposeAsyncImage.SubcomposeAsyncImageContent(
                        modifier = Modifier
                            .clickable { onClick() }
                            .fillMaxSize()
                    )
                }

            }
        }
    }
}