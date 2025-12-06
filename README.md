# giphRs

[Screen_recording_20251205_203748.webm](https://github.com/user-attachments/assets/3ea93f1b-3cd7-4cd9-95ed-5081b411d94c)

giphRs is an application to demonstrate a native cross platform reactive app architecture in rust.
It is currently only proof of concept for the UI architecture. It happens to also be a GIPHY client.

The project of consists of the following

- Core Library
  - libgiphrs: Where all the application's behavior lives
  - swift and kotlin core libs: Thin wrappers to bridge the gap
- Android App: A Compose interface
- iOS Application: A SwiftUI interface

The app is currently capable of displaying an infinitely scrolling of trending GIfs from the GIPHY
API. Aspirationally it's a full featured sample app.

## Motivation

This is a developer sandbox app to explore mobile app development in rust.

I chose rust because I love rust. I love it's expressive type system, safety guarantees, and
performance characteristics. I've worked on many mobile apps over the years, every time wishing I
could do it in rust

I chose a gif browser because the GIPHY API surface is small, but full featured client still has
enough interesting problems to solve to keep the project interesting. Specifically

- Networking
- Auth
- Persistent storage
- Pagination
- Search Autocomplete

## Design goals

Implement as much of the app logic in the Rust core as possible.
The UIs only observe streams of presentation data, and report events.
AKA unidirectional data flow or MVI pattern

## Architecture
This is an example of an MVI style architecture

- A view model publishes view state and receives input
- A view observes view state and renders it, and channels events from the user to the view model
- View states are immutable records (no behavior, only data) events are signaled with function
  calls
- The data observed by the UI is immutable and should map 1:1 to the arguments of stateless
  composable functions / SwiftUI views

## Libraries

- UniFFI
- futures_signals
- tokio
- reqwest
- serde

# Interesting stuff

- `rust_view_model.rs`: The main entry point for the UI
- `offset_pager.rs`: A signal and future powered pager that is generic over page and item type
- `broadcast_signal.rs`: Enables multiple concurrent UI observers (e.g., different screens or
  components) to independently watch the same reactive signal across the FFI boundary by bridging
  futures_signals to tokio broadcast channels.

The rest of the project is mostly interesting by way of how uninteresting it is. The UIs are _dumb_

## Further exploration / TODO

- [ ] Gracefully handle the unhappy path
  - [ ] Network errors
  - [ ] Timeouts
  - [ ] Image load errors
- [ ] Persistent local storage (preferences + auth token)
- [ ] Auth
  - [ ] Persisted auth token
  - [ ] React to auth state
  - [ ] Login Screen
    - [ ] Form validation
- [ ] Report analytics
- [ ] Localize with `fluent`
- [ ] Navigation
  - [ ] Will need some way to signal effects from the view models to the UI
- [ ] Detail View
- [ ] Browse by search term
- [ ] Other image types
  - [ ] Stickers
  - [ ] Clips
- [ ] Search
  - [ ] Autocomplete
- [ ] Favorites
  - [ ] Favorites List
  - [ ] Handle Favorite button click
- [ ] Dependency injection
- [ ] Tests

## Development

### Rust

Open up the project in your favorite editor and poke around the Cargo workspace
under `core/`!

### iOS

Before opening up the App package in Xcode, you need to build the Rust core.

```shell
cd rust/
./build-ios.sh
```

This generates an XCFramework and generates Swift bindings to the Rust core.

**You need to do this every time you make Rust changes that you want reflected in the Swift Package!
**

### Android

Gradle will build everything for you after you get a few things set up.
Most importantly, you need to install [`cargo-ndk`](https://github.com/bbqsrc/cargo-ndk).

```shell
cargo install cargo-ndk
```

If you've tried building the Rust library already and you have rustup,
the requisite targets will probably be installed automatically.
If not, follow the steps in the [`cargo-ndk` README](https://github.com/bbqsrc/cargo-ndk)
to install the required Android targets.

Just open up the `android` project in Android Studio and you're good to go.
It took forever to get the tooling right, but now that it's there, it just works.
