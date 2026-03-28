package com.joelpedraza.giphrs.core

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.Dispatchers.Main
import kotlinx.coroutines.launch
import uniffi.giphrs.RustViewModel

class KotlinViewModel private constructor(private val nativeViewModel: RustViewModel) :
    ViewModel(nativeViewModel) {
  constructor() : this(RustViewModel())

  val previews
    get() = nativeViewModel.getItems()

  val isLoading
    get() = nativeViewModel.isLoading()

  val hasError
    get() = nativeViewModel.hasError()

  val previewsFlow
    get() = signalOn(Main) { nativeViewModel.pollItems() }

  val isLoadingFlow
    get() = signalOn(Main) { nativeViewModel.pollLoading() }

  val hasErrorFlow
    get() = signalOn(Main) { nativeViewModel.pollError() }

  init {
    refresh()
  }

  fun refresh() {
    viewModelScope.launch(Main) { nativeViewModel.refresh() }
  }

  fun onSeen(id: String) {
    viewModelScope.launch(Main) { nativeViewModel.onItemSeen(id) }
  }

  fun requestNextPage() {
    viewModelScope.launch(Main) { nativeViewModel.requestNextPage() }
  }
}
