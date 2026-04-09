# Agents Guide for giphRs

This document provides guidance for AI agents (like Claude Code) working on the giphRs project.

## Project Overview

giphRs is a cross-platform mobile application demonstrating a reactive architecture using Rust as the core business logic layer, with native iOS (SwiftUI) and Android (Compose) UIs. The project uses UniFFI to bridge Rust to Swift and Kotlin.

**Architecture Pattern:** MVI (Model-View-Intent) / Unidirectional Data Flow
- Rust core publishes immutable view state via reactive signals
- Platform UIs observe state and render, sending events back to core
- All business logic lives in Rust; UIs are intentionally "dumb"

## Project Structure

```
giphrs/
├── core/                    # Rust workspace
│   ├── giphrs/             # Main Rust library
│   │   └── src/
│   │       ├── rust_view_model.rs    # Main UI entry point
│   │       ├── offset_paginator.rs   # Generic pagination
│   │       ├── broadcast_signal.rs   # Cross-FFI reactive signals
│   │       ├── api_client.rs         # Network layer
│   │       ├── api_model.rs          # API types
│   │       └── domain_model.rs       # Domain types
│   ├── uniffi-bindgen/     # UniFFI code generation
│   └── build-ios.sh        # iOS binding generation script
├── ios/
│   ├── App/App/
│   │   ├── SwiftViewModel.swift     # Swift wrapper around RustViewModel
│   │   ├── ContentView.swift        # Main SwiftUI view
│   │   ├── PreviewWebPView.swift    # GIF preview component
│   │   └── WebImageView.swift       # Image loading view
│   └── Sources/UniFFI/
│       └── giphrs.swift    # Generated Swift bindings
└── android/
    └── core/src/main/java/com/joelpedraza/giphrs/core/
        └── KotlinViewModel.kt         # Kotlin wrapper around RustViewModel

```

## Key Patterns and Conventions

### 1. Reactive Signal Pattern

The core uses `BroadcastSignal` to enable multiple UI observers across FFI:
- `poll_*()` methods return the next value change
- `get_*()` methods return current snapshot
- Swift/Kotlin wrappers poll in background tasks/coroutines

Example (RustViewModel):
```rust
pub fn is_loading(&self) -> bool { ... }         // Current snapshot
pub async fn poll_loading(&self) -> Option<bool> { ... }  // Wait for changes
```

Example (SwiftViewModel wrapper):
```swift
@Published var is_loading: Bool;

init() {
    self.is_loading = nativeViewModel.isLoading()  // Initial value

    Task {
        while !Task.isCancelled {
            guard let is_loading = await nativeViewModel.pollLoading() else { break }
            self.is_loading = is_loading  // Update on changes
        }
    }
}
```

### 2. UniFFI Binding Generation

**CRITICAL:** Any changes to Rust public API require regenerating bindings.

For iOS:
```bash
cd core
./build-ios.sh
```

This script:
1. Builds Rust for all iOS targets (device + simulator)
2. Runs `uniffi-bindgen-swift` to generate Swift bindings
3. Updates `ios/Sources/UniFFI/giphrs.swift`
4. Creates XCFramework

For Android:
- Gradle handles this automatically via `cargo-ndk`

### 3. ViewModel Pattern Consistency

All three ViewModels (Rust/Swift/Kotlin) should expose the same capabilities:

**RustViewModel** (Rust core):
- Properties: `get_items()`, `is_loading()`, `has_error()`
- Polling: `poll_items()`, `poll_loading()`, `poll_error()`
- Actions: `refresh()`, `on_item_seen(id)`, `request_next_page()`

**SwiftViewModel** (iOS wrapper):
- Published properties: `gifs`, `is_loading`, `has_error`
- Methods: `refresh()`, `onSeen(id:)`, `requestNextPage()`
- Background polling tasks for each property

**KotlinViewModel** (Android wrapper):
- StateFlows: `previewsFlow`, `isLoadingFlow`, `hasErrorFlow`
- Methods: `refresh()`, `onSeen(id)`, `requestNextPage()`
- Uses `signalAsStateFlow` helper for conversion

### 4. Naming Conventions

**Rust:**
- `snake_case` for everything
- `#[uniffi::Object]` for exported types
- `#[uniffi::export]` for exported implementations

**Swift:**
- `PascalCase` for types
- `camelCase` for properties/methods
- `@Published` for observable properties
- `@MainActor` for ViewModels

**Kotlin:**
- `PascalCase` for types
- `camelCase` for properties/methods
- Flow types for reactive streams

## Common Tasks

### Adding a New Property to RustViewModel

1. Add property and polling method to `rust_view_model.rs`:
```rust
#[uniffi::export]
impl RustViewModel {
    pub fn new_property(&self) -> PropertyType { ... }
    pub async fn poll_new_property(&self) -> Option<PropertyType> { ... }
}
```

2. Regenerate iOS bindings:
```bash
cd core && ./build-ios.sh
```

3. Update SwiftViewModel:
```swift
@Published var newProperty: PropertyType

init() {
    self.newProperty = nativeViewModel.newProperty()

    Task {
        while !Task.isCancelled {
            guard let newProperty = await nativeViewModel.pollNewProperty() else { break }
            self.newProperty = newProperty
        }
    }
}
```

4. Update KotlinViewModel:
```kotlin
val newPropertyFlow = signalAsStateFlow(
    nativeViewModel.newProperty()
) { nativeViewModel.pollNewProperty() }
```

### Debugging UniFFI Issues

If Swift/Kotlin bindings don't match Rust:
1. Check `core/giphrs/src/rust_view_model.rs` for `#[uniffi::export]` annotations
2. Run binding generation script
3. Verify generated files updated:
   - iOS: `ios/Sources/UniFFI/giphrs.swift`
   - Android: Check `android/core/build/` for generated Kotlin

### Working with Xcode

The iOS project uses Xcode with custom MCP tools:
- Use `XcodeRead`, `XcodeWrite`, `XcodeUpdate` for file operations
- Use `XcodeGrep`, `XcodeGlob` for searching
- Use `BuildProject` to verify compilation
- Use `XcodeRefreshCodeIssuesInFile` for quick syntax checks

## Important Files

### Core Entry Points
- `core/giphrs/src/rust_view_model.rs` - Main ViewModel, start here
- `core/giphrs/src/lib.rs` - UniFFI setup and initialization

### UI Wrappers
- `ios/App/App/SwiftViewModel.swift` - iOS ViewModel wrapper
- `android/core/src/main/java/com/joelpedraza/giphrs/core/KotlinViewModel.kt` - Android ViewModel wrapper

### Generated Code
- `ios/Sources/UniFFI/giphrs.swift` - Auto-generated, DO NOT EDIT
- Android UniFFI outputs in `android/core/build/` - Auto-generated

## Development Workflow

1. Make changes to Rust core
2. Regenerate bindings (`./core/build-ios.sh` for iOS)
3. Update platform-specific wrappers (SwiftViewModel, KotlinViewModel)
4. Update UI code as needed
5. Test on both platforms

## Testing

Currently minimal test coverage (see README TODO list).

For manual testing:
- iOS: Open `ios/` in Xcode, build and run
- Android: Open `android/` in Android Studio, build and run

## Common Pitfalls

1. **Forgetting to regenerate bindings** - Always run `build-ios.sh` after Rust changes
2. **Breaking parity** - Keep Rust/Swift/Kotlin ViewModels in sync
3. **Naming inconsistencies** - Follow platform conventions but keep semantics aligned
4. **Direct file edits in UniFFI output** - Never edit generated `giphrs.swift`

## Future Considerations

Per README TODO:
- Error handling improvements
- Authentication and persistence
- Navigation and routing
- Search and filtering
- Dependency injection
- Comprehensive testing

When implementing these, maintain the core principle: **business logic in Rust, UI observation only in platform code**.
