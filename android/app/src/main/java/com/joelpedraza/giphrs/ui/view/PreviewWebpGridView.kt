package com.joelpedraza.giphrs.ui.view

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.lazy.staggeredgrid.LazyVerticalStaggeredGrid
import androidx.compose.foundation.lazy.staggeredgrid.StaggeredGridCells
import androidx.compose.foundation.lazy.staggeredgrid.items
import androidx.compose.foundation.lazy.staggeredgrid.rememberLazyStaggeredGridState
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import uniffi.giphrs.PreviewWebP

@Composable
fun PreviewWebpGridView(
  previews: List<PreviewWebP>,
  modifier: Modifier = Modifier,
  onSeen: (String) -> Unit = {}
) {
  val gridState = rememberLazyStaggeredGridState()

  LazyVerticalStaggeredGrid(
    state = gridState,
    columns = StaggeredGridCells.Adaptive(minSize = 175.dp),
    horizontalArrangement = Arrangement.spacedBy(12.dp),
    verticalItemSpacing = 12.dp,
    contentPadding = PaddingValues(start = 12.dp, top = 12.dp, end = 12.dp, bottom = 0.dp),
    modifier = modifier
  ) {
    items(
      items = previews,
      key = { gif -> gif.id },
      itemContent = { gif -> PreviewWebPView(gif, onSeen) }
    )
  }
}