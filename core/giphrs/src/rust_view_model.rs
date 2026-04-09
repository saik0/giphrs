use crate::api_client::ApiClient;
use crate::api_model::{Gif, GifListResponse, Image, Images};
use crate::broadcast_signal::BroadcastSignal;
use crate::domain_model::PreviewWebP;
use crate::error::GiphRsError;
use crate::offset_paginator::OffsetPager;
use futures_signals::signal::SignalExt;
use itertools::Itertools;
use log::{debug, error};
use std::sync::Arc;

type Previews = Vec<PreviewWebP>;

#[derive(uniffi::Object)]
pub struct RustViewModel {
    api_client: ApiClient,
    paginator: OffsetPager<Gif, GifListResponse>,
    previews: BroadcastSignal<Previews>,
    loading: BroadcastSignal<bool>,
    error: BroadcastSignal<Option<GiphRsError>>,
}

#[uniffi::export]
impl RustViewModel {
    #[uniffi::constructor]
    pub fn new() -> Arc<Self> {
        let api_client: ApiClient = ApiClient::new();

        let paginator = OffsetPager::new();

        let previews = BroadcastSignal::new(paginator.items_signal_cloned().map(into_previews));

        let loading = BroadcastSignal::new(paginator.is_loading_signal());

        let error = BroadcastSignal::new(paginator.error_signal().map(|opt_err| opt_err.clone()));

        let vm = RustViewModel {
            api_client,
            paginator,
            previews,
            loading,
            error,
        };

        Arc::new(vm)
    }

    pub fn get_items(&self) -> Vec<PreviewWebP> {
        into_previews(self.paginator.items_cloned())
    }

    pub fn is_loading(&self) -> bool {
        self.paginator.is_loading()
    }

    pub fn has_error(&self) -> bool {
        self.paginator.error().is_some()
    }

    pub async fn poll_items(&self) -> Option<Vec<PreviewWebP>> {
        self.previews.recv().await
    }

    pub async fn poll_loading(&self) -> Option<bool> {
        self.loading.recv().await
    }

    pub async fn poll_error(&self) -> Option<GiphRsError> {
        self.error.recv().await.flatten()
    }

    pub async fn refresh(&self) {
        self.paginator
            .try_reset(|| async move { self.api_client.get_trending(0).await })
            .await
    }

    pub async fn on_item_seen(&self, id: &str) {
        let gifs = self.paginator.items_cloned();
        if let Some((i, gif)) = gifs.iter().enumerate().find(|(_, gif)| gif.id == id) {
            debug!("user saw gif: {}", gif.id);
            if i >= gifs.len() - 4 {
                debug!("loading next page");
                self.paginator
                    .try_load_more(false, |offset| async move {
                        self.api_client.get_trending(offset).await
                    })
                    .await
            }
        } else {
            error!("no gif for id {:?}", id);
        }
    }

    pub async fn request_next_page(&self) {
        self.paginator
            .try_load_more(true, |offset| async move {
                self.api_client.get_trending(offset).await
            })
            .await
    }
}

fn into_preview(gif: &Gif) -> Option<PreviewWebP> {
    gif.images.select_preview_image().and_then(|image| {
        image.webp.as_ref().map(|webp_url| PreviewWebP {
            id: gif.id.clone(),
            alt_text: gif.alt_text.clone(),
            url: webp_url.clone(),
            aspect_ratio: image.aspect_ratio(),
        })
    })
}

fn into_previews(gifs: Vec<Gif>) -> Vec<PreviewWebP> {
    gifs.iter()
        .unique_by(|gif| gif.id.clone())
        .filter_map(into_preview)
        .collect()
}

impl Images {
    fn select_preview_image(&self) -> Option<&Image> {
        self.fixed_width
            .as_ref()
            .or(self.fixed_width_downsampled.as_ref())
            .or(self.fixed_width_small.as_ref())
    }
}

impl Image {
    fn aspect_ratio(&self) -> Option<f32> {
        let w = self.width.parse::<f32>().ok();
        let h = self.height.parse::<f32>().ok();
        match (w, h) {
            (Some(w), Some(h)) => Some(w / h),
            _ => None,
        }
    }
}
