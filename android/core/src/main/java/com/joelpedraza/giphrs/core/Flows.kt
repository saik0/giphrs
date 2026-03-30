package com.joelpedraza.giphrs.core

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.Dispatchers
import kotlin.coroutines.CoroutineContext
import kotlin.coroutines.EmptyCoroutineContext
import kotlinx.coroutines.channels.BufferOverflow.DROP_OLDEST
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.buffer
import kotlinx.coroutines.flow.channelFlow
import kotlinx.coroutines.flow.conflate
import kotlinx.coroutines.flow.flowOn
import kotlinx.coroutines.flow.stateIn
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
        .conflate()
        .flowOn(context)

fun <T : Any> ViewModel.signalAsStateFlow(
    initialValue: T,
    pollSignal: suspend () -> T?
): StateFlow<T> = signalOn(Dispatchers.Default) { pollSignal() }
    .stateIn(
        scope = viewModelScope,
        initialValue = initialValue,
        started = SharingStarted.WhileSubscribed(5000)
    )
