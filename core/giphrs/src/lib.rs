mod api_client;
mod api_model;
mod domain_model;
mod offset_paginator;
mod rust_view_model;
mod broadcast_signal;

use log::trace;
use once_cell::sync::OnceCell;
use std::sync::Arc;
use tokio::runtime::Runtime;

// You must call this once
uniffi::setup_scaffolding!();

pub fn init_log() {
    #[cfg(target_os = "ios")]
    oslog::OsLogger::new("giphrs-rs")
        .level_filter(log::LevelFilter::Trace)
        // .category_level_filter("Settings", LevelFilter::Trace)
        .init()
        .expect("failed to init log");

    #[cfg(target_os = "android")]
    android_log::init("giphy").expect("failed to init log");

    trace!("Initialized log");
}

static RUNTIME: OnceCell<Arc<Runtime>> = OnceCell::new();

fn new_runtime() -> Runtime {
    let mut builder = tokio::runtime::Builder::new_multi_thread();

    builder.enable_time().enable_io();

    #[cfg(target_os = "android")]
    builder.on_thread_start(|| {
        let vm = VM.get().expect("init java vm");
        vm.attach_current_thread_permanently()
            .expect("thread to attach");
    });

    builder.build().expect("failed to build threaded runtime")
}
pub fn get_runtime() -> Arc<Runtime> {
    RUNTIME.get_or_init(|| Arc::new(new_runtime())).clone()
}

#[cfg(target_os = "android")]
static VM: OnceCell<Arc<jni::JavaVM>> = OnceCell::new();

#[cfg(target_os = "android")]
#[unsafe(export_name = "Java_com_joelpedraza_giphrs_GiphrsApplication_javaInit")]
pub extern "system" fn java_init(
    env: jni::JNIEnv,
    _class: jni::objects::JClass,
    _: jni::objects::JObject,
) {
    let vm = env.get_java_vm().expect("a located Java VM");
    VM.set(Arc::new(vm)).expect("uninitialized VM singleton");
}

#[uniffi::export]
pub fn initialize() {
    init_log();
}
