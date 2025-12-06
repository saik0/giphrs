use crate::api_model::{Gif, GifListResponse};
use futures_signals::signal::{Mutable, MutableSignal, MutableSignalCloned};
use log::error;
use std::future::Future;
use std::marker::PhantomData;

pub type Offset = u32;
pub trait Page<T> {
    fn next_offset(&self) -> Offset;
    fn into_items(self) -> Vec<T>;
}

impl Page<Gif> for GifListResponse {
    fn next_offset(&self) -> u32 {
        self.pagination.count + self.pagination.offset
    }

    fn into_items(self) -> Vec<Gif> {
        self.data
    }
}

pub struct OffsetPager<T, P>
where
    P: Page<T>,
{
    is_loading: Mutable<bool>,
    items: Mutable<Vec<T>>,
    offset: Mutable<u32>,
    phantom_data: PhantomData<P>,
}

impl<T, P> OffsetPager<T, P>
where
    P: Page<T>,
    T: Clone + Sized,
{
    pub fn new() -> Self {
        OffsetPager {
            is_loading: Mutable::new(false),
            items: Mutable::new(Vec::new()),
            offset: Mutable::new(0),
            phantom_data: PhantomData,
        }
    }

    pub async fn try_reset<F, G>(&self, f: F)
    where
        F: Fn() -> G,
        G: Future<Output = reqwest::Result<P>>,
    {
        {
            let mut guard = self.is_loading.lock_mut();
            if *guard {
                return;
            } else {
                *guard = true;
            }
        };

        let response = f().await;

        match response {
            Ok(value) => {
                let next_offset = value.next_offset();
                *self.items.lock_mut() = value.into_items();
                self.offset.set(next_offset);
            }
            Err(error) => {
                error!("unhandled pagination error: {:?}", error);
            }
        }

        self.is_loading.set(false)
    }

    pub async fn try_load_more<F, G>(&self, f: F)
    where
        F: Fn(Offset) -> G,
        G: Future<Output = reqwest::Result<P>>,
    {
        {
            let mut guard = self.is_loading.lock_mut();
            if *guard {
                return;
            } else {
                *guard = true;
            }
        };

        let offset = self.offset.get();
        let response = f(offset).await;

        match response {
            Ok(value) => {
                let next_offset = value.next_offset();
                self.items.lock_mut().extend(value.into_items());
                self.offset.set(next_offset);
            }
            Err(error) => {
                error!("unhandled pagination error: {:?}", error);
            }
        }

        self.is_loading.set(false)
    }

    pub fn items_cloned(&self) -> Vec<T> {
        self.items.get_cloned()
    }
    pub fn items_signal_cloned(&self) -> MutableSignalCloned<Vec<T>> {
        self.items.signal_cloned()
    }

    pub fn is_loading(&self) -> bool {
        self.is_loading.get()
    }
    pub fn is_loading_signal(&self) -> MutableSignal<bool> {
        self.is_loading.signal()
    }


}
