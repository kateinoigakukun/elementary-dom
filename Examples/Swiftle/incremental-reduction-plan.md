# Comprehensive Incremental Reduction Plan

## Generic Advice

- Use Serena MCP

## Strategy Overview

1. **Work top-down**: Start with highest-level modules and work down to core dependencies
2. **Incremental commits**: Each successful reduction gets its own git commit
3. **Adjust dependencies**: When removing files, fix compilation errors in dependent files
4. **Test crash**: Verify crash still reproduces after each reduction
5. **Safe rollback**: Use git to rollback if crash stops reproducing

## Module Hierarchy (Top to Bottom)

```
Swiftle (main app)
├── ElementaryDOM (DOM integration + reactivity)
│   ├── Elementary (HTML generation)
│   └── JavaScriptKit (JS interop)
│       └── _CJavaScriptKit (C bridge)
```

## Phase 1: Swiftle Module Reductions

### 1.1 Simplify main.swift further
- **Target**: Remove `KeyboardLetterView` struct, inline into `GameView`
- **Files**: `Sources/Swiftle/main.swift`
- **Action**:
  - Remove `KeyboardLetterView` struct and extensions
  - Move button directly into `GameView.content`
  - Remove `onKeyPressed` function, inline the call
- **Test**: Build + crash test
- **Commit**: "Inline KeyboardLetterView into GameView"

### 1.2 Simplify Game class
- **Target**: Remove `Guess` struct, use simple counter
- **Files**: `Sources/Swiftle/main.swift`
- **Action**:
  - Replace `[Guess]` with `Int` counter
  - Remove `Guess` struct entirely
  - Update `handleKey()` to increment counter
  - Update UI loop to use counter value
- **Test**: Build + crash test
- **Commit**: "Replace Guess array with simple counter"

### 1.3 Minimize App structure
- **Target**: Remove `App` struct, mount `GameView` directly
- **Files**: `Sources/Swiftle/main.swift`
- **Action**:
  - Remove `App` struct and extensions
  - Call `GameView().mount()` directly
- **Test**: Build + crash test
- **Commit**: "Remove App wrapper, mount GameView directly"

## Phase 2: ElementaryDOM Module Reductions

### 2.1 Remove unused reconciler nodes
- **Target**: Remove reconciler node types not used in crash path
- **Files**:
  - `Sources/ElementaryDOM/Reconciler/Nodes/_ConditionalNode.swift`
  - `Sources/ElementaryDOM/Reconciler/Nodes/_TupleNode.swift`
  - `Sources/ElementaryDOM/Reconciler/Nodes/_LifecycleNode.swift`
- **Action**:
  - Remove files one by one
  - Fix any compilation errors in referencing files
  - Remove imports and references
- **Test**: Build + crash test after each file
- **Commit**: "Remove unused reconciler nodes: [NodeName]"

### 2.2 Simplify view system
- **Target**: Remove view modifier and binding systems
- **Files**:
  - `Sources/ElementaryDOM/ElementModifiers/BindingModifiers.swift`
  - `Sources/ElementaryDOM/ElementModifiers/DOMElementModifier.swift`
  - `Sources/ElementaryDOM/Data/State/Binding.swift`
- **Action**:
  - Remove binding modifier files
  - Remove references to binding system in other files
  - Keep only essential modifiers needed for onClick
- **Test**: Build + crash test
- **Commit**: "Remove view binding and modifier systems"

### 2.3 Reduce reactivity system
- **Target**: Keep only essential reactivity components
- **Files**: `Sources/ElementaryDOM/Reactivity/`
- **Action**:
  - Keep: `PropertyID.swift`, `ReactivityRegistrar.swift`, `ReactivityTracker.swift`
  - Remove: `Internals.swift`, `WithTracking.swift` (if possible)
  - Inline simple functionality where possible
- **Test**: Build + crash test
- **Commit**: "Streamline reactivity system"

### 2.4 Remove interop features
- **Target**: Remove unused DOM interop features
- **Files**:
  - `Sources/ElementaryDOM/Interop/EmbeddedSupport.swift`
  - `Sources/ElementaryDOM/Interop/View+Binding.swift`
- **Action**:
  - Remove files
  - Fix compilation errors
- **Test**: Build + crash test
- **Commit**: "Remove unused DOM interop features"

## Phase 3: Elementary Module Reductions

### 3.1 Remove server-side features
- **Target**: Remove all server-side rendering code
- **Files**:
  - `Sources/Elementary/Rendering/HtmlTextRenderer.swift`
  - `Sources/Elementary/Rendering/RenderingUtils.swift`
  - `Sources/Elementary/Html+Rendering.swift`
- **Action**:
  - Remove server rendering files
  - Remove server-related methods from core types
  - Keep only client-side rendering path
- **Test**: Build + crash test
- **Commit**: "Remove server-side rendering code"

### 3.2 Reduce HTML attribute system
- **Target**: Keep only attributes needed for button + onClick
- **Files**: `Sources/Elementary/HtmlAttributes+common.swift`
- **Action**:
  - Keep only button-related attributes
  - Remove all other HTML attributes (form, input, etc.)
  - This file is 591 lines - can probably reduce to ~50 lines
- **Test**: Build + crash test
- **Commit**: "Reduce HTML attributes to essential button attributes"

### 3.3 Reduce HTML elements
- **Target**: Keep only essential HTML elements
- **Files**:
  - `Sources/Elementary/HtmlElements.swift`
  - `Sources/Elementary/HtmlTags.swift`
- **Action**:
  - Keep only: `button`, `span`, basic container elements
  - Remove all other HTML elements
- **Test**: Build + crash test
- **Commit**: "Reduce HTML elements to essential set"

### 3.4 Simplify core model
- **Target**: Remove unused core abstractions
- **Files**:
  - `Sources/Elementary/Core/StoredAttribute.swift`
  - `Sources/Elementary/Core/AttributeStorage.swift`
- **Action**:
  - Inline simple attribute storage
  - Remove complex attribute management
- **Test**: Build + crash test
- **Commit**: "Simplify core attribute model"

## Phase 4: JavaScriptKit Module Reductions

### 4.1 Remove unused fundamental objects (safe ones)
- **Target**: Remove JS objects not in crash path
- **Files**:
  - `Sources/JavaScriptKit/FundamentalObjects/JSThrowingFunction.swift`
  - `Sources/JavaScriptKit/BasicObjects/JSArray.swift` (if not used)
- **Action**:
  - Analyze usage with grep
  - Remove files not referenced in crash path
  - Fix compilation errors
- **Test**: Build + crash test
- **Commit**: "Remove unused JavaScript fundamental objects"

### 4.2 Simplify value conversion system
- **Target**: Reduce complex type conversion code
- **Files**:
  - `Sources/JavaScriptKit/ConstructibleFromJSValue.swift`
  - `Sources/JavaScriptKit/ConvertibleToJSValue.swift`
- **Action**:
  - Keep only conversions used in crash path
  - Remove complex number/BigInt conversions
  - Keep basic string/object/function conversions
- **Test**: Build + crash test
- **Commit**: "Simplify JavaScript value conversion system"

### 4.3 Reduce JSValue complexity
- **Target**: Simplify core JSValue implementation
- **Files**: `Sources/JavaScriptKit/JSValue.swift`
- **Action**:
  - Remove unused JSValue cases (bigInt, symbol if safe)
  - Keep essential: object, function, string, number, boolean
  - Remove complex conversion methods
- **Test**: Build + crash test
- **Commit**: "Simplify core JSValue implementation"

## Phase 5: Final Cleanup

### 5.1 Remove dead code
- **Target**: Find and remove any remaining dead code
- **Action**:
  - Use compiler warnings to find unused functions
  - Remove unreferenced private methods
  - Remove unused imports
- **Test**: Build + crash test
- **Commit**: "Remove remaining dead code"

### 5.2 Inline small utilities
- **Target**: Inline very small utility functions/types
- **Action**:
  - Inline single-use utility functions
  - Merge small related types
  - Reduce file count where possible
- **Test**: Build + crash test
- **Commit**: "Inline small utilities"

## Implementation Guidelines

### Before Each Reduction:
1. `git add -A && git commit -m "Checkpoint before [reduction name]"`
2. Analyze dependencies with grep/serena tools
3. Identify files that import the target

### During Each Reduction:
1. Remove/modify target files
2. Fix compilation errors:
   - Remove imports of deleted types
   - Remove/modify code that references deleted symbols
   - Add stubs if needed temporarily
3. Build until compilation succeeds

### After Each Reduction:
1. Run `./build-node.sh && node run.mjs`
2. Verify crash still occurs with same stack trace
3. If crash preserved: `git add -A && git commit -m "[reduction description]"`
4. If crash lost: `git reset --hard HEAD` and try smaller reduction

### Rollback Strategy:
- If reduction breaks crash: `git reset --hard HEAD~1`
- Try alternative approach or smaller change
- Document what broke the crash in plan

## Success Metrics

- **File count reduction**: Target <50 Swift files (from ~87)
- **Line count reduction**: Target <5,000 lines (from ~11,000)
- **Crash preservation**: Must maintain exact same memory corruption
- **Build time**: Should improve with less code to compile

## Risk Assessment

**High Risk** (likely to break crash):
- Modifying reactivity system core
- Changing JSValue/JS interop fundamentals
- Altering DOM event handling

**Medium Risk**:
- Simplifying view hierarchy
- Reducing HTML attribute sets
- Removing reconciler nodes

**Low Risk**:
- Removing server-side code
- Inlining small utilities
- Removing unused JS objects

This plan provides a systematic, safe approach to aggressive reduction while maintaining the critical memory corruption conditions.
