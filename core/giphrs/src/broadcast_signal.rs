use futures_signals::signal::{Signal, SignalExt};
use std::pin::Pin;
use std::sync::{Mutex, Once};
use tokio::sync::broadcast;

type DynSignal<T> = Pin<Box<dyn Signal<Item = T> + Send>>;

/// A signal that can be observed by multiple concurrent subscribers
pub struct BroadcastSignal<T: Clone> {
    tx: broadcast::Sender<T>,
    // Store signal until it's consumed by spawning
    signal: Mutex<Option<DynSignal<T>>>,
    // Ensure we only spawn once
    spawn_once: Once,
}

impl<T: Clone + Send + 'static> BroadcastSignal<T> {
    /// Create a new BroadcastSignal that will lazily spawn its background task on first use
    pub fn new<S>(signal: S) -> Self
    where
        S: Signal<Item = T> + Send + 'static,
    {
        let (tx, _) = broadcast::channel(1);

        Self {
            tx,
            signal: Mutex::new(Some(Box::pin(signal))),
            spawn_once: Once::new(),
        }
    }

    /// Ensure the background task is spawned (called automatically by recv/subscribe)
    fn ensure_spawned(&self) {
        let tx = self.tx.clone();
        let signal_mutex = &self.signal;

        self.spawn_once.call_once(|| {
            let signal = signal_mutex.lock().unwrap().take()
                .expect("Signal should be available on first spawn");

            // Spawn on the global runtime instead of current context
            crate::get_runtime().spawn(async move {
                signal
                    .for_each(|value| {
                        let _ = tx.send(value);
                        async {}
                    })
                    .await;
            });
        });
    }

    pub fn subscribe(&self) -> broadcast::Receiver<T> {
        self.ensure_spawned();
        self.tx.subscribe()
    }

    pub async fn recv(&self) -> Option<T> {
        self.subscribe().recv().await.ok()
    }
}