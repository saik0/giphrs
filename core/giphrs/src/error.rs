use thiserror::Error;

#[derive(Debug, Clone, Error, uniffi::Error)]
#[uniffi(flat_error)]
pub enum GiphRsError {
    #[error("Network error")]
    NetworkError,

    #[error("Failed to parse response")]
    ParseError,

    #[error("API error {code}")]
    ApiError { code: u32 },

    #[error("Unknown error")]
    Unknown,
}

impl From<reqwest::Error> for GiphRsError {
    fn from(err: reqwest::Error) -> Self {
        if err.is_connect() || err.is_timeout() {
            GiphRsError::NetworkError
        } else if err.is_decode() {
            GiphRsError::ParseError
        } else if let Some(status) = err.status() {
            GiphRsError::ApiError {
                code: status.as_u16() as u32,
            }
        } else {
            GiphRsError::Unknown
        }
    }
}
