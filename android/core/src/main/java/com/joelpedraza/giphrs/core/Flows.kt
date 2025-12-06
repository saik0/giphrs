package com.joelpedraza.giphrs.core

import kotlinx.coroutines.channels.BufferOverflow.DROP_OLDEST
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.buffer
import kotlinx.coroutines.flow.channelFlow
import kotlinx.coroutines.flow.flowOn
import kotlinx.coroutines.isActive
import kotlin.coroutines.CoroutineContext
import kotlin.coroutines.EmptyCoroutineContext

fun <T : Any> signalOn(
  context: CoroutineContext = EmptyCoroutineContext,
  pollSignal: suspend () -> T?
): Flow<T> =
  channelFlow {
    while (isActive) {
      val item = pollSignal()
      if (item == null) break
      send(item)
    }
  }.buffer(capacity = 0, onBufferOverflow = DROP_OLDEST)
    .flowOn(context)