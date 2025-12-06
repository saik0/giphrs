#![allow(dead_code)] // TODO Move this to another crate
use serde::Deserialize;

#[derive(Deserialize, Debug, Clone)]
pub struct Meta {
    pub msg: String,
    pub status: u32,
    pub response_id: Option<String>,
}

#[derive(Deserialize, Debug, Clone)]
pub struct Pagination {
    pub offset: u32,
    pub total_count: Option<u32>,
    pub count: u32,
}

#[derive(Deserialize, Debug, Clone)]
pub struct Image {
    pub url: Option<String>,
    pub width: String,
    pub height: String,
    pub size: Option<String>,
    pub mp4: Option<String>,
    pub mp4_size: Option<String>,
    pub webp: Option<String>,
    pub webp_size: Option<String>,
}

#[derive(Deserialize, Debug, Clone)]
pub struct Images {
    pub fixed_height: Option<Image>,
    pub fixed_height_still: Option<Image>,
    pub fixed_height_downsampled: Option<Image>,
    pub fixed_width: Option<Image>,
    pub fixed_width_still: Option<Image>,
    pub fixed_width_downsampled: Option<Image>,
    pub fixed_height_small: Option<Image>,
    pub fixed_height_small_still: Option<Image>,
    pub fixed_width_small: Option<Image>,
    pub fixed_width_small_still: Option<Image>,
    pub downsized: Option<Image>,
    pub downsized_still: Option<Image>,
    pub downsized_large: Option<Image>,
    pub downsized_medium: Option<Image>,
    pub downsized_small: Option<Image>,
    pub original: Option<Image>,
    pub original_still: Option<Image>,
}

#[derive(Deserialize, Debug, Clone)]
pub struct Gif {
    pub id: String,
    pub slug: String,
    pub url: String,
    pub title: String,
    pub alt_text: String,
    pub images: Images,
}

#[derive(Deserialize, Debug, Clone)]
pub struct GifListResponse {
    pub meta: Meta,
    pub pagination: Pagination,
    pub data: Vec<Gif>,
}
