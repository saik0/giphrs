use crate::api_model::GifListResponse;
use crate::get_runtime;
use log::{debug, trace};

#[cfg(target_os = "android")]
const API_KEY: &str = "Bo4OmDXRipLyLrhFKSJkQTz1seT80nrj";

#[cfg(target_os = "ios")]
const API_KEY: &str = "1MwfVAA3MLKDfIXB9PPhbE5kaOfPeirV";

#[cfg(all(not(target_os = "android"), not(target_os = "ios")))]
const API_KEY: &str = "NO_KEY";

pub struct ApiClient {}

impl ApiClient {
    pub fn new() -> Self {
        ApiClient {}
    }

    pub async fn get_trending(&self, offset: u32) -> reqwest::Result<GifListResponse> {
        let client = reqwest::Client::new();
        let url = "https://api.giphy.com/v1/gifs/trending?rating=g&bundle=low_bandwidth";
        let future = client
            .get(url)
            .query(&[("api_key", API_KEY), ("offset", &offset.to_string())])
            .send();

        get_runtime()
            .spawn(async {
                trace!("begin get in rust");
                let response = future.await?;
                debug!("headers: {:?}", &response);
                let parsed = response.json::<GifListResponse>().await;
                debug!("body: {:?}", &parsed);
                parsed
            })
            .await
            .expect("task panicked")
    }
}
