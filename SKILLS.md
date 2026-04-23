# Skills Guide for giphRs

This document defines reusable skills and procedures for working with the giphRs project.

## Core Skills

### 1. Regenerating UniFFI Bindings

**When to use:** After any changes to Rust public API, especially `RustViewModel`

**Procedure:**
```bash
cd /Users/esteban/Developer/giphrs/core
./build-ios.sh
```

**What it does:**
- Compiles Rust library for all iOS targets
- Generates Swift bindings via `uniffi-bindgen-swift`
- Updates `ios/Sources/UniFFI/giphrs.swift`
- Creates fat simulator library and XCFramework

**Verification:**
```bash
# Check that generated file was updated
ls -l ios/Sources/UniFFI/giphrs.swift

# Search for newly added methods
grep -n "newMethodName" ios/Sources/UniFFI/giphrs.swift
```

### 2. Adding Reactive Properties to ViewModels

**When to use:** Adding new observable state to the application

**Rust (RustViewModel):**
```rust
use crate::broadcast_signal::BroadcastSignal;

#[derive(uniffi::Object)]
pub struct RustViewModel {
    // Add signal
    my_property: BroadcastSignal<MyType>,
}

#[uniffi::export]
impl RustViewModel {
    // Snapshot method
    pub fn get_my_property(&self) -> MyType {
        // Return current value
    }

    // Polling method
    pub async fn poll_my_property(&self) -> Option<MyType> {
        self.my_property.recv().await
    }
}
```

**Swift (SwiftViewModel):**
```swift
@MainActor class SwiftViewModel : ObservableObject {
    @Published var myProperty: MyType

    init() {
        // Initialize with snapshot
        self.myProperty = nativeViewModel.getMyProperty()

        // Poll for changes
        Task {
            while !Task.isCancelled {
                guard let myProperty = await nativeViewModel.pollMyProperty() else { break }
                self.myProperty = myProperty
            }
        }
    }
}
```

**Kotlin (KotlinViewModel):**
```kotlin
class KotlinViewModel(private val nativeViewModel: RustViewModel) : ViewModel(nativeViewModel) {
    val myPropertyFlow = signalAsStateFlow(
        nativeViewModel.getMyProperty()
    ) { nativeViewModel.pollMyProperty() }
}
```

### 3. Adding Action Methods to ViewModels

**When to use:** Adding user-triggered actions (refresh, navigate, etc.)

**Rust:**
```rust
#[uniffi::export]
impl RustViewModel {
    pub async fn my_action(&self, param: String) {
        // Perform action
        // Update signals/state as needed
    }
}
```

**Swift:**
```swift
func myAction(param: String) {
    Task {
        await nativeViewModel.myAction(param: param)
    }
}
```

**Kotlin:**
```kotlin
fun myAction(param: String) {
    viewModelScope.launch(Dispatchers.Default) {
        nativeViewModel.myAction(param)
    }
}
```

### 4. Maintaining ViewModel Parity

**When to use:** After making changes to any ViewModel

**Checklist:**
- [ ] RustViewModel has the new property/method with `#[uniffi::export]`
- [ ] UniFFI bindings regenerated (`./core/build-ios.sh`)
- [ ] Generated Swift bindings include new method
- [ ] SwiftViewModel exposes new property/method
- [ ] KotlinViewModel exposes new property/method
- [ ] Both iOS and Android projects build successfully

**Verification script:**
```bash
# Check RustViewModel methods
grep -A 5 "pub.*fn" core/giphrs/src/rust_view_model.rs

# Check Swift bindings
grep "func.*RustViewModel" ios/Sources/UniFFI/giphrs.swift

# Check SwiftViewModel
grep "func\|@Published" ios/App/App/SwiftViewModel.swift

# Check KotlinViewModel
grep "fun\|val.*Flow" android/core/src/main/java/com/joelpedraza/giphrs/core/KotlinViewModel.kt
```

### 5. Building and Verifying iOS Project

**When to use:** After making changes to verify compilation

**Using Xcode MCP tools:**
```
# Build the project
Use mcp__xcode-tools__BuildProject

# Check for issues
Use mcp__xcode-tools__XcodeListNavigatorIssues with severity: "error"

# Quick syntax check for specific file
Use mcp__xcode-tools__XcodeRefreshCodeIssuesInFile with filePath
```

**Using command line:**
```bash
cd ios
xcodebuild -scheme App -destination 'platform=iOS Simulator,name=iPhone 15' build
```

### 6. Debugging Missing UniFFI Exports

**When to use:** Swift/Kotlin can't find a Rust method

**Diagnosis:**
1. Check Rust has `#[uniffi::export]` on impl block:
```rust
#[uniffi::export]  // ← Must be present
impl RustViewModel {
    pub fn my_method(&self) -> Type { ... }
}
```

2. Check generated Swift protocol:
```bash
grep -A 20 "protocol RustViewModelProtocol" ios/Sources/UniFFI/giphrs.swift
```

3. If missing, regenerate bindings:
```bash
cd core && ./build-ios.sh
```

4. Verify method appears in generated code:
```bash
grep "my_method" ios/Sources/UniFFI/giphrs.swift
```

### 7. Renaming Methods Across Platforms

**When to use:** Improving API consistency

**Procedure:**
1. In RustViewModel, the method name stays in `snake_case` (Rust convention)
2. In Swift, use `camelCase` naming in SwiftViewModel wrapper
3. In Kotlin, use `camelCase` naming in KotlinViewModel wrapper
4. Update all call sites in UI code

**Example:**
```rust
// Rust: snake_case
pub async fn on_item_seen(&self, id: &str) { ... }
```

```swift
// Swift: camelCase wrapper method
func onSeen(id: String) {
    Task {
        await nativeViewModel.onItemSeen(id: id)  // UniFFI preserves Rust name
    }
}
```

```kotlin
// Kotlin: camelCase wrapper method
fun onSeen(id: String) {
    viewModelScope.launch(Dispatchers.Default) {
        nativeViewModel.onItemSeen(id)  // UniFFI preserves Rust name
    }
}
```

### 8. Working with Xcode Project Structure

**When to use:** Reading/writing files in the iOS project

**Important:** Use `Xcode*` MCP tools, not regular file tools:
- `XcodeRead` instead of `Read`
- `XcodeWrite` instead of `Write`
- `XcodeUpdate` instead of `Edit`
- `XcodeGrep` instead of `Grep`
- `XcodeGlob` instead of `Glob`

**Paths:** Use project-relative paths like `App/App/SwiftViewModel.swift`, not filesystem paths.

**Example:**
```
# Good
XcodeRead("App/App/SwiftViewModel.swift")

# Bad (filesystem path)
Read("/Users/esteban/Developer/giphrs/ios/App/App/SwiftViewModel.swift")
```

### 9. Understanding the Signal Broadcasting Pattern

**When to use:** Working with reactive state in RustViewModel

**Key concept:** `BroadcastSignal` bridges `futures_signals` to FFI-compatible async streams.

**Pattern:**
```rust
use crate::broadcast_signal::BroadcastSignal;
use futures_signals::signal::SignalExt;

pub struct RustViewModel {
    // Wrap any Signal in BroadcastSignal
    my_signal: BroadcastSignal<MyType>,
}

impl RustViewModel {
    pub fn new() -> Arc<Self> {
        let my_signal = BroadcastSignal::new(
            some_signal.map(transform_fn)
        );
        // ...
    }

    // Current value (synchronous)
    pub fn get_my_value(&self) -> MyType {
        // Get from underlying source
    }

    // Poll for changes (async)
    pub async fn poll_my_value(&self) -> Option<MyType> {
        self.my_signal.recv().await
    }
}
```

### 10. Implementing Pull-to-Refresh

**When to use:** Adding refresh capability to UI

**Already implemented** in this project:

**Swift (ContentView.swift):**
```swift
ScrollView {
    // ... content
}.refreshable {
    await viewModel.refresh()
}
```

**SwiftViewModel:**
```swift
func refresh() {
    Task {
        await nativeViewModel.refresh()
    }
}
```

**RustViewModel:**
```rust
pub async fn refresh(&self) {
    self.paginator
        .try_reset(|| async move {
            self.api_client.get_trending(0).await
        })
        .await
}
```

## Quick Reference

### File Locations
| Component | Path |
|-----------|------|
| Rust ViewModel | `core/giphrs/src/rust_view_model.rs` |
| Swift ViewModel | `ios/App/App/SwiftViewModel.swift` |
| Kotlin ViewModel | `android/core/src/main/java/com/joelpedraza/giphrs/core/KotlinViewModel.kt` |
| Generated Swift | `ios/Sources/UniFFI/giphrs.swift` |
| Build Script | `core/build-ios.sh` |

### Command Cheat Sheet
```bash
# Regenerate iOS bindings
cd core && ./build-ios.sh

# Build iOS from command line
cd ios && xcodebuild -scheme App build

# Install Android build tool
cargo install cargo-ndk

# Check Rust exports
grep -n "uniffi::export" core/giphrs/src/rust_view_model.rs

# Find Swift method
grep -n "func myMethod" ios/App/App/SwiftViewModel.swift
```

### Verification Checklist
After making changes, verify:
- [ ] Rust code compiles: `cd core && cargo build`
- [ ] iOS bindings regenerated: `./core/build-ios.sh`
- [ ] iOS project builds: `BuildProject` via Xcode tools
- [ ] ViewModels in sync: All three expose same capabilities
- [ ] Naming follows platform conventions
