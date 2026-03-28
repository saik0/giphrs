package com.joelpedraza.giphrs.core

import kotlin.coroutines.CoroutineContext
import kotlin.coroutines.EmptyCoroutineContext
import kotlinx.coroutines.channels.BufferOverflow.DROP_OLDEST
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.buffer
import kotlinx.coroutines.flow.channelFlow
import kotlinx.coroutines.flow.flowOn
import kotlinx.coroutines.isActive

fun <T : Any> signalOn(
    context: CoroutineContext = EmptyCoroutineContext,
    pollSignal: suspend () -> T?
): Flow<T> =
    channelFlow {
          while (isActive) {
            val item = pollSignal() ?: break
            send(item)
          }
        }
        .buffer(capacity = 0, onBufferOverflow = DROP_OLDEST)
        .flowOn(context)
