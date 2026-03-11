---
name: coding
description: React Native coding guidance with design-first workflow. Consults official docs before writing code, then dispatches code-foundations for pseudocode-driven design. Use when writing components, implementing features, building screens, fixing queries, or adding views. Triggers on "write a component", "implement this feature", "build this screen", "add a view", "React Native code", "fix this query", "use best practices".
allowed-tools: Read, Grep, Glob, Skill
---

# Skill: coding

**On load:** Read `../../.claude-plugin/plugin.json` from this skill's base directory. Display `coding v{version}` before proceeding.

React Native coding guidance that combines official docs with design-first development. This skill loads two lenses into your context — use them together.

---

## Step 1: Load Lenses

Load both skills immediately:

```
Skill(react-native-foundations:docs)
Skill(code-foundations:code)
```

The docs skill gives you the RN API reference. The code skill gives you pseudocode-first design workflow.

---

## Step 2: Search Docs First

Before writing any code:

1. Identify which RN APIs and components the task involves
2. Grep `${CLAUDE_SKILL_DIR}/../../refs/react-native-docs/` for those APIs
3. Read relevant doc files (max 3 most relevant)
4. Note platform differences, deprecation warnings, or required props

---

## Step 3: Design with code-foundations

Follow the code-foundations:code workflow:

1. Write pseudocode with contracts
2. Validate design with the user
3. Implement from the validated pseudocode

The RN docs you searched in Step 2 inform the design — use correct APIs, props, and patterns.

---

## Step 4: Verify

After implementation, suggest verification:

- "`/react-native-foundations:layout-check` to verify visual layout"
- "`/react-native-foundations:a11y-audit` to check accessibility"
- "`/react-native-foundations:debug` to check for console errors"
- If errors: "`/react-native-foundations:diagnose` to diagnose"

---

## Common Gotchas

- FlatList requires `keyExtractor` or `key` prop on items
- ScrollView inside FlatList causes performance issues
- Absolute positioning works differently than web CSS
- StatusBar behavior differs iOS vs Android
- SafeAreaView only works on iOS (use `react-native-safe-area-context` for cross-platform)
- Dimensions API returns points not pixels on iOS (3x on Retina)
- TextInput `onChangeText` gives string, `onChange` gives event object
- Prefer Pressable over TouchableOpacity (newer, more flexible)
- `flex: 1` in RN is `flexGrow: 1, flexShrink: 1, flexBasis: 0` — not the same as CSS
- `overflow` defaults to `hidden` on Android, `visible` on iOS
