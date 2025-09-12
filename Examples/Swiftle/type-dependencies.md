# Type Dependency Analysis

## Module Overview

The codebase consists of 5 main Swift modules:

1. **Swiftle** - Main application (1 file)
2. **ElementaryDOM** - DOM interaction and reactivity (68 files)
3. **Elementary** - HTML generation and core types (21 files)
4. **JavaScriptKit** - JavaScript interop (22 files)
5. **_CJavaScriptKit** - C bridge for JavaScript

## Critical Dependencies for Crash Reproducer

### Core Crash Path
Based on the analysis, the crash occurs in this dependency chain:

```
Swiftle/main.swift
├─ Game class with reactive properties
│  ├─ PropertyID (ElementaryDOM/Reactivity/PropertyID.swift)
│  ├─ ReactivityRegistrar (ElementaryDOM/Reactivity/ReactivityRegistrar.swift)
│  └─ Guess struct (mutating operations)
│
├─ @State wrapper
│  └─ State (ElementaryDOM/Data/State/State.swift)
│
├─ UI Components (GameView, KeyboardLetterView, App)
│  ├─ @HTMLBuilder (Elementary/Core/HtmlBuilder.swift)
│  ├─ button (Elementary/HtmlElements.swift)
│  ├─ onClick handler (ElementaryDOM/Interop/EventHandlers.swift)
│  └─ View mounting (ElementaryDOM/Interop/View+Mount.swift)
```

### Essential Types for Memory Corruption

**Reactivity System (CRITICAL)**:
- `PropertyID` - Property identification
- `ReactivityRegistrar` - Tracks property changes
- `ReactivityTracker` - Internal tracking mechanisms
- `_ViewStateStorage` - State management for views

**UI System (CRITICAL)**:
- `HTMLBuilder` - Result builder for HTML
- `button` typealias and HTMLTag.button
- `onClick` event handler
- `View` protocol and extensions
- DOM mounting infrastructure

**JavaScript Interop (CRITICAL)**:
- Core JSValue types
- Event listener bridge
- WASM function calling

## Potentially Removable Components

### JavaScriptKit - Safe to Remove:
- `JSBigInt.swift` - Not used in crash path
- `JSDate.swift` - Date operations not needed
- `JSTimer.swift` - Timer functionality unused
- `JSTypedArray.swift` - Array operations not in crash path
- `JSException.swift` - Exception handling not critical
- `JSSymbol.swift` - Symbol operations unused
- `JSPromise.swift` - Async promises not used
- `BasicObjects/*` - Most basic objects unused

### JavaScriptKit - Must Keep:
- `JSValue.swift` - Core value type
- `JSObject.swift` - Object operations
- `JSFunction.swift` - Function calls
- `JSClosure.swift` - Closure bridging
- `JSString.swift` - String operations
- `ConvertibleToJSValue.swift` - Type conversions
- `BridgeJSInstrincics.swift` - Core bridging
- `_CJavaScriptKit` bridge

### Elementary - Safe to Remove:
- `HtmlAttributes+common.swift` - Lots of unused attributes
- `AsyncContent.swift` - Async content not used
- `AsyncForEach.swift` - Async iteration not used
- `ForEach.swift` - Collection iteration not used
- `Environment.swift` - Environment system not used
- Server support files
- Rendering utilities for text/async

### Elementary - Must Keep:
- `HtmlBuilder.swift` - @HTMLBuilder result builder
- `HtmlElements.swift` - button typealias
- `HtmlTags.swift` - HTMLTag.button definition
- `Html+Elements.swift` - Element construction
- Core HTML types

### ElementaryDOM - Safe to Remove:
- `GlobalEvents.swift` - Global event handling not used
- `View+LifecycleEvents.swift` - Lifecycle not critical for crash
- `ModifiedView.swift` - View modifications not used
- `KeyedView.swift` - Keyed views not used
- `ViewKey.swift` - View keys not used
- Many reconciler node types not used
- Binding modifiers not used

### ElementaryDOM - Must Keep:
- All reactivity files (PropertyID, ReactivityRegistrar, etc.)
- State management (State.swift, ViewStateStorage.swift)
- Core view types and mounting
- Event handling (EventHandlers.swift)
- DOM reconciler core
- JavaScript interop bridge

## Dependency Graph

```mermaid
graph TD
    A[Swiftle/main.swift] --> B[ElementaryDOM]
    B --> C[Elementary]
    B --> D[JavaScriptKit]
    D --> E[_CJavaScriptKit]

    A --> F[Game class]
    F --> G[PropertyID]
    F --> H[ReactivityRegistrar]
    F --> I[@State wrapper]

    A --> J[UI Components]
    J --> K[@HTMLBuilder]
    J --> L[button element]
    J --> M[onClick handler]

    M --> N[Event bridging]
    N --> D
```

## Removal Strategy

1. **Phase 1**: Remove obviously unused JavaScriptKit objects (JSDate, JSTimer, JSBigInt, etc.)
2. **Phase 2**: Remove unused Elementary components (AsyncContent, ForEach, Environment)
3. **Phase 3**: Remove unused ElementaryDOM features (GlobalEvents, LifecycleEvents)
4. **Phase 4**: Trim attribute definitions to minimal set
5. **Phase 5**: Remove unused reconciler node types

**Critical**: After each phase, test that the crash still reproduces to ensure we don't break the memory corruption conditions.

## Files by Priority

### Phase 1 - Safe to Remove (JavaScriptKit):
- BasicObjects/JSDate.swift
- BasicObjects/JSTimer.swift
- BasicObjects/JSTypedArray.swift
- FundamentalObjects/JSBigInt.swift
- FundamentalObjects/JSSymbol.swift
- JSException.swift

### Phase 2 - Safe to Remove (Elementary):
- Core/AsyncContent.swift
- Core/AsyncForEach.swift
- Core/ForEach.swift
- Core/Environment.swift
- ServerSupport/*
- Rendering/HtmlAsyncRenderer.swift

### Phase 3 - Safe to Remove (ElementaryDOM):
- Interop/GlobalEvents.swift
- Elementary/View+LifecycleEvents.swift
- Elementary/ModifiedView.swift
- Elementary/KeyedView.swift
- Elementary/ViewKey.swift

This analysis provides a systematic approach to reducing the codebase while preserving the exact conditions needed for the memory corruption crash.