package com.joelpedraza.giphrs.core

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import uniffi.giphrs.RustViewModel

class KotlinViewModel private constructor(private val nativeViewModel: RustViewModel) :
    ViewModel(nativeViewModel) {
    constructor() : this(RustViewModel())

    val previewsFlow =
        signalAsStateFlow(nativeViewModel.getItems()) { nativeViewModel.pollItems() }

    val isLoadingFlow =
        signalAsStateFlow(nativeViewModel.isLoading()) { nativeViewModel.pollLoading() }

    val hasErrorFlow =
        signalAsStateFlow(nativeViewModel.hasError()) { nativeViewModel.pollError() }

    init {
        refresh()
    }

    fun refresh() {
        viewModelScope.launch(Dispatchers.Default) { nativeViewModel.refresh() }
    }

    fun onSeen(id: String) {
        viewModelScope.launch(Dispatchers.Default) { nativeViewModel.onItemSeen(id) }
    }

    fun requestNextPage() {
        viewModelScope.launch(Dispatchers.Default) { nativeViewModel.requestNextPage() }
    }
}
