# react-native-foundations

A Claude Code plugin for React Native development. Nine skills that search official docs, drive the iOS Simulator, diagnose errors, inspect layouts, audit accessibility, and debug the JS runtime.

v0.4.0. MIT license.

## Install

```bash
claude plugin add /path/to/react-native-foundations
```

The plugin bundles 234 official React Native doc files. No npm install, no build step.

## Skills

### rn-docs

Grep-first search across bundled RN documentation. Ask about any API, component, hook, or platform behavior.

```
"How does FlatList handle windowing?"
"What props does Pressable accept?"
```

### ios-sim

Drive the iOS Simulator without leaving your editor. Screenshots, accessibility tree dumps, tap/swipe/type automation, video recording, app install and launch.

Uses [AXe](https://github.com/cameroncooke/AXe) for UI automation. Five targeted commands go beyond coordinate-based tapping:

- **tap-label / tap-id** — tap elements by accessibility label or identifier directly, no coordinate lookup
- **list** — compact table of on-screen elements, grouped by Controls and Content
- **back** — finds and taps the back button using label and position heuristics
- **scroll** — repeats swipes toward top or bottom with stabilization detection (stops when the screen stops changing)

```
"Take a screenshot of the simulator"
"Tap the login button"
"List what's on screen"
"Scroll to the bottom"
```

### rn-diagnose

Matches errors against 24 known patterns covering Metro, build, runtime, and dependency failures. Checks Metro health first, then cross-references docs and project config. Dispatches subagents for large build logs and simulator screenshots so they don't bloat your context.

```
"Why is my build failing?"
"What does this red screen mean?"
"pod install failed"
```

### rn-debug

Runtime debugging for the JS and React layers. Console logs, expression evaluation, React component tree inspection, network monitoring, and HMR event streaming. Falls back to OS-level log capture when Metro isn't running.

Requires Node 22+ for CDP features (native WebSocket).

```
"Show me console errors"
"Evaluate someStore.getState()"
"What's in the React component tree?"
"Monitor HMR updates"
```

### rn-layout-check

Captures the simulator screen and accessibility tree in a subagent, analyzes element positions and spacing, then checks results against Flexbox and style documentation. When Metro is running, it also pulls computed style values from the React fiber tree.

```
"Does this layout look right?"
"Why is this view overflowing?"
```

### rn-a11y-audit

Walks the native accessibility tree and checks every element against a severity-rated checklist (critical, warning, info). When Metro is available, compares React-declared a11y props against the native tree and reports discrepancies.

```
"Audit accessibility on this screen"
"Are my labels correct for VoiceOver?"
```

### rn-coding

Lightweight guidance that makes Claude consult the docs before writing code and suggest verification after. No scripts, no Bash. Read the relevant docs, follow the patterns, then verify with `rn-layout-check`, `rn-a11y-audit`, or `rn-debug`.

```
"Write a FlatList component for this data"
"Build a settings screen"
```

### rn-deeplink-test

Reads your navigation/linking config, constructs test URLs, fires them into the simulator via `xcrun simctl openurl`, and verifies the resulting screen.

```
"Test the deep link for /profile/123"
"Does my universal link config work?"
```

### rn-clean

Diagnoses stale caches before cleaning instead of blindly wiping everything. Checks Metro, Watchman, node_modules, Pods, Derived Data, and Gradle caches, then only clears what's actually broken.

```
"Metro won't start"
"Do a clean build"
"Nuclear clean everything"
```

## Shared Scripts

Four scripts in `skills/_shared/scripts/` power the debug and diagnosis workflows:

| Script | Purpose | Requires |
|--------|---------|----------|
| `metro.sh` | Metro health checks, bundle validation, stack symbolication | bash, curl |
| `logs.sh` | OS-level JS console log capture (iOS and Android) | bash, xcrun/adb |
| `cdp-bridge.js` | CDP WebSocket bridge: console, eval, tree, network | Node 22+ |
| `hmr.sh` | HMR WebSocket event monitor | bash, Node 22+ |

All four resolve the Metro port in the same order: `--port` flag, then `RCT_METRO_PORT` env var, then default 8081.

## Requirements

- Claude Code
- [AXe](https://github.com/cameroncooke/AXe) (`brew install cameroncooke/axe/axe`) for ios-sim UI automation
- iOS Simulator for ios-sim, rn-layout-check, rn-a11y-audit, rn-deeplink-test
- Node 22+ for CDP features in rn-debug
- A React Native project
