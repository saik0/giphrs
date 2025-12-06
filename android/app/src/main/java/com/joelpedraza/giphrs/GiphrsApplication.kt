package com.joelpedraza.giphrs

import android.app.Application
import uniffi.giphrs.initialize

class GiphrsApplication: Application() {
  external fun javaInit()

  override fun onCreate() {
    super.onCreate()
    System.loadLibrary("giphrs")
    javaInit()
    initialize()
  }
}