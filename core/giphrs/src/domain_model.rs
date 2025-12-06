use uniffi::Record;

#[derive(Debug, Clone, Record)]
pub struct PreviewWebP {
    pub id: String,
    pub alt_text: String,
    pub url: String,
    pub aspect_ratio: Option<f32>,
}
