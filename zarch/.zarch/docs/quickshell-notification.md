# Understanding the Quickshell Notification System
### A guide for programmers with no QML or Qt background

---

## Table of Contents

1. [What is Qt, QML, and Quickshell?](#1-what-is-qt-qml-and-quickshell)
2. [The QML Mental Model](#2-the-qml-mental-model)
3. [QML Syntax Fundamentals](#3-qml-syntax-fundamentals)
4. [Properties and Reactive Bindings](#4-properties-and-reactive-bindings)
5. [The Visual Tree: Items, Parents, and Children](#5-the-visual-tree-items-parents-and-children)
6. [Layouts: RowLayout, ColumnLayout, and Column](#6-layouts-rowlayout-columnlayout-and-column)
7. [Sizing: implicitHeight vs height vs anchors](#7-sizing-implicitheight-vs-height-vs-anchors)
8. [Repeaters and Models](#8-repeaters-and-models)
9. [Signals and Signal Handlers](#9-signals-and-signal-handlers)
10. [Timers](#10-timers)
11. [Flickable and ScrollBar](#11-flickable-and-scrollbar)
12. [Quickshell-Specific Concepts](#12-quickshell-specific-concepts)
13. [Walking Through the Notification Code](#13-walking-through-the-notification-code)
    - [Top-level structure](#131-top-level-structure)
    - [NotificationServer](#132-notificationserver)
    - [IpcHandler](#133-ipchandler)
    - [Live toast window](#134-live-toast-panelwindow)
    - [Notification center window](#135-notification-center-panelwindow)

---

## 1. What is Qt, QML, and Quickshell?

### Qt

Qt (pronounced "cute") is a C++ application framework that has been around since 1995. It provides a massive cross-platform library for building GUIs, handling networking, multimedia, databases, and much more. When you write a Qt application in C++, you get a native-looking, GPU-accelerated UI that runs on Linux, Windows, macOS, Android, and more.

### QML

QML (Qt Modeling Language) is a declarative UI language that sits on top of Qt. Instead of writing C++ to describe your interface, you describe *what* the UI looks like and *how* elements relate to each other. The Qt runtime then figures out how to render it.

If you know HTML + CSS + a bit of JavaScript, QML will feel familiar. Think of it like this:

| Web                  | QML equivalent            |
|----------------------|---------------------------|
| HTML elements        | QML types (`Rectangle`, `Text`, `Image`) |
| CSS properties       | QML properties (`color`, `width`, `font.pixelSize`) |
| DOM nesting          | QML parent-child tree     |
| JavaScript           | JavaScript (literally the same language) |
| CSS Flexbox          | `RowLayout` / `ColumnLayout` |
| `addEventListener`   | Signal handlers (`onClicked`, `onTriggered`) |

QML files end in `.qml`. Every QML file defines a **component** — a reusable piece of UI.

### Quickshell

Quickshell is a shell framework for Linux desktops built on top of QML. It gives you special QML types for things that a regular app can't do: sticking windows to screen edges (panels/bars), receiving desktop notifications via D-Bus, reading system tray icons, talking to Hyprland via IPC, and so on.

You can think of Quickshell as the "bridge" between your QML code and the Linux Wayland compositor. It provides types like `PanelWindow`, `NotificationServer`, `IpcHandler` etc. that don't exist in standard Qt — they're Quickshell additions.

---

## 2. The QML Mental Model

Before touching syntax, internalize this: **QML is declarative, not imperative.**

In C or Python you write a sequence of instructions:
```python
# Imperative: "do this, then do that"
x = 10
y = x * 2
x = 20
# y is still 20! You have to manually update it.
```

In QML, you declare *relationships*:
```qml
// Declarative: "y is always twice x"
property int x: 10
property int y: x * 2
// If x changes to 20, y automatically becomes 40. Always.
```

This is called **reactive binding**. It's the single most important concept in QML. Properties don't hold values — they hold *expressions* that are kept live. When anything in an expression changes, every property bound to it updates automatically.

This is how the notification center window resizes itself when you add a notification — you never write "recalculate height". You just say `implicitHeight: centerCol.implicitHeight + 24` and Qt keeps that true forever.

---

## 3. QML Syntax Fundamentals

### Basic structure

A QML file is a tree of **objects**. Each object starts with its **type name**, then has a block `{ }` containing its properties and children:

```qml
Rectangle {
    width: 200
    height: 100
    color: "blue"

    Text {
        anchors.centerIn: parent
        text: "Hello"
        color: "white"
    }
}
```

This is equivalent to: "Create a blue 200×100 rectangle, and inside it center a white 'Hello' text."

### Object IDs

You can give any object an `id` to reference it elsewhere:

```qml
Rectangle {
    id: myBox
    width: 100
}

Text {
    // Reference myBox by id from anywhere in the same file
    text: "Box width is: " + myBox.width
}
```

`id` is not a property — it's a special identifier that exists at the QML engine level. IDs are scoped to the file (like a module-level variable in Python).

### Property assignment

```qml
Item {
    // Simple value
    width: 300

    // Expression (reactive binding)
    height: width / 2

    // String
    color: "red"

    // Boolean
    visible: true

    // Grouped property (dot notation)
    font.pixelSize: 14
    font.bold: true
}
```

### Inline JavaScript

Any property value can be a JavaScript expression:

```qml
Text {
    text: count > 0 ? "Items: " + count : "Empty"
    color: isError ? "#ff0000" : "#ffffff"
    width: Math.max(100, label.implicitWidth + 20)
}
```

### Functions

```qml
Item {
    function greet(name) {
        return "Hello, " + name + "!"
    }

    Text {
        text: greet("World")
    }
}
```

### Imports

Just like Python's `import` or C's `#include`, QML files start with imports:

```qml
import QtQuick           // Core QML types: Rectangle, Text, Image, Item...
import QtQuick.Layouts   // RowLayout, ColumnLayout, GridLayout
import QtQuick.Controls  // ScrollView, ScrollBar, Button...
import Quickshell        // Scope, PanelWindow, Variants...
import Quickshell.Wayland
import Quickshell.Services.Notifications
import "config.js" as Config  // Import a local JS file as a module
```

---

## 4. Properties and Reactive Bindings

### Declaring custom properties

You can add new properties to any object using the `property` keyword:

```qml
Rectangle {
    property int clickCount: 0
    property bool isOpen: false
    property string userName: "Alice"
    property color highlightColor: "cyan"
    property var anyValue: { key: "value" }  // var = any type
}
```

This is like adding instance variables in a class. Every instance of this component gets its own `clickCount`, `isOpen`, etc.

### Reactive bindings in action

```qml
Rectangle {
    id: box
    property bool highlighted: false

    width: 200
    height: 50

    // These update automatically whenever `highlighted` changes
    color: highlighted ? "#7aa2f7" : "#1a1b26"
    border.width: highlighted ? 2 : 0
    border.color: "#0db9d7"

    scale: highlighted ? 1.05 : 1.0
}
```

You never call `updateColors()`. The moment `box.highlighted = true` is set anywhere (say from a mouse click), all three properties update simultaneously.

### Breaking a binding

If you *assign* to a bound property imperatively, you break the binding:

```qml
property int x: 10
property int y: x * 2  // binding: y = x * 2

// Later in a signal handler:
onSomeSignal: {
    y = 99  // BREAKS the binding! y is now a fixed 99, no longer tracks x
}
```

This is a common gotcha. To re-establish the binding you'd use `Qt.binding()`:
```qml
y = Qt.binding(() => x * 2)  // restores the reactive binding
```

---

## 5. The Visual Tree: Items, Parents, and Children

Every visual QML element is an **Item** (or a subclass of it). Items form a tree — just like the DOM in HTML.

```qml
Item {                    // root
    Rectangle {           // child of root
        Text { }          // child of Rectangle
        Image { }         // another child of Rectangle
    }
    Rectangle {           // second child of root
    }
}
```

### `parent`

Every item has a `parent` property pointing to its containing item. Inside any item, `parent` refers to the direct parent:

```qml
Rectangle {
    width: 400
    height: 300

    Text {
        // parent here is the Rectangle
        width: parent.width  // = 400
        anchors.centerIn: parent
    }
}
```

### Key built-in types

| Type | What it is | C++ analogy |
|------|-----------|-------------|
| `Item` | Invisible container, base for everything | Abstract base class |
| `Rectangle` | Colored box, can have rounded corners and borders | A `<div>` with background |
| `Text` | Renders text | `<span>` or `<p>` |
| `Image` | Renders an image from a URL or path | `<img>` |
| `MouseArea` | Invisible click/hover detector | `addEventListener('click', ...)` |

---

## 6. Layouts: RowLayout, ColumnLayout, and Column

Layouts are containers that automatically position and size their children.

### RowLayout

Arranges children **horizontally**:

```qml
import QtQuick.Layouts

RowLayout {
    spacing: 10

    Text { text: "Left" }
    Item { Layout.fillWidth: true }  // stretches to fill remaining space
    Text { text: "Right" }
}
```

`Layout.fillWidth: true` is an **attached property** — it's set on a child but read by the parent layout. Think of it as a hint to the layout: "make this child take all the remaining width."

### ColumnLayout

Arranges children **vertically** — same idea, just top to bottom:

```qml
ColumnLayout {
    spacing: 8

    Text { text: "First" }
    Text { text: "Second"; Layout.fillWidth: true }
    Text { text: "Third" }
}
```

### Layout attached properties

When an item is inside a `RowLayout` or `ColumnLayout`, you use `Layout.*` properties (attached properties) to control its behavior:

| Property | Meaning |
|----------|---------|
| `Layout.fillWidth: true` | Stretch horizontally to fill available space |
| `Layout.fillHeight: true` | Stretch vertically to fill available space |
| `Layout.preferredWidth: 100` | Desired width (before stretching logic) |
| `Layout.preferredHeight: 50` | Desired height |
| `Layout.alignment: Qt.AlignTop` | Align item within its cell |
| `Layout.bottomMargin: 8` | Space below this item |

### Column vs ColumnLayout

There are two "stack children vertically" types:

- **`Column`** — simple, dumb stacking. Just places children one below the other. Each child controls its own size. Always correctly reports its `implicitHeight` as the sum of children heights + spacing.
- **`ColumnLayout`** — smart, flexible. Children use `Layout.*` attached properties for resizing hints. More powerful but has a quirk: **inside a `Flickable`, `ColumnLayout` doesn't correctly report its `implicitHeight`**. This is a known Qt behavior. For scrollable content you must use `Column`.

---

## 7. Sizing: implicitHeight vs height vs anchors

This is one of the trickiest parts of QML. There are three ways an item gets its size:

### `width` / `height` — explicit size

You set it directly. The item is exactly that size regardless of content:

```qml
Rectangle {
    width: 200   // always 200px wide
    height: 100  // always 100px tall
}
```

### `implicitWidth` / `implicitHeight` — natural/content size

This is the size the item *wants* to be based on its content. It's a **hint**, not a hard size. Text, Images, and Layouts all compute their own implicit size:

```qml
Text {
    text: "Hello World"
    // implicitWidth and implicitHeight are automatically calculated
    // based on font size and content. You don't set them for Text.
}

Rectangle {
    // For a Rectangle, implicit size is 0 by default.
    // You control it:
    implicitHeight: innerContent.implicitHeight + 20
}
```

The key rule: **if you don't set `width`/`height` explicitly, the item uses its `implicitWidth`/`implicitHeight`.**

The `PanelWindow` uses `implicitHeight` to tell the compositor how tall the window should be — and because it's a reactive binding, the window resizes automatically as content grows or shrinks.

### Anchors — position and size relative to another item

Anchors are the primary way to position items relative to their parent or siblings:

```qml
Rectangle {
    id: container
    width: 400; height: 300

    Rectangle {
        // Stick all four sides to the parent → fills completely
        anchors.fill: parent
    }

    Rectangle {
        // Stick to top-left corner
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 10   // 10px from each anchored edge
        width: 100
        height: 50
    }

    Text {
        // Center inside parent
        anchors.centerIn: parent
    }
}
```

**Critical rule from Qt docs**: if an item is a child of a `Layout`, **do NOT set anchors on it** — the layout controls its position. Anchors and Layouts conflict.

**Another critical rule**: if you use `anchors.fill: parent` on a `ColumnLayout`, the layout gets its size *from* the parent — it can no longer grow the parent. This causes the height-not-adapting bug we fixed. The correct pattern for adaptive height is:

```qml
Rectangle {
    // Height flows UP from the layout
    implicitHeight: myLayout.implicitHeight + 24

    ColumnLayout {
        id: myLayout
        width: parent.width      // only constrain width
        anchors.top: parent.top  // anchor top only, NOT fill
        // height stays free → layout computes its own implicitHeight
        // → Rectangle's implicitHeight updates → window resizes
    }
}
```

---

## 8. Repeaters and Models

A `Repeater` instantiates a component multiple times, once per item in a **model**. This is QML's equivalent of a `for` loop over a list to produce UI elements.

```qml
// Simple numeric model
Repeater {
    model: 5   // creates 5 instances
    delegate: Text {
        text: "Item " + index   // index is 0..4
    }
}
```

### ListModel

`ListModel` is a dynamic list you can insert/remove from at runtime:

```qml
ListModel {
    id: myList
    // Optionally pre-populate:
    ListElement { name: "Alice"; age: 30 }
    ListElement { name: "Bob";   age: 25 }
}

// Manipulate at runtime:
myList.append({ name: "Carol", age: 28 })
myList.insert(0, { name: "Dave", age: 35 })  // insert at index 0
myList.remove(1)   // remove item at index 1
myList.clear()     // remove all items
myList.count       // number of items
```

When a `Repeater` uses a `ListModel`, it watches for changes. Add an item → a new delegate appears. Remove an item → its delegate disappears. This happens automatically.

### Accessing model data

Inside a `Repeater`'s delegate, you access row data with `model.<rolename>`:

```qml
Repeater {
    model: myList
    delegate: Text {
        text: model.name + " is " + model.age + " years old"
        // `index` is the row number (0-based)
        // `model` is the current row's data object
    }
}
```

### `trackedNotifications` model

Quickshell's `NotificationServer` exposes `trackedNotifications` — a live model of currently active (not yet dismissed) notifications. Each item in this model is a notification object with properties like `.summary`, `.body`, `.urgency`, `.image`, `.appIcon`. It's used the same way as `ListModel` in a `Repeater`.

### `required property var modelData`

When a `Repeater` iterates over `trackedNotifications` (a C++-backed model rather than a plain `ListModel`), the delegate uses `required property var modelData` to receive the current item:

```qml
Repeater {
    model: server.trackedNotifications
    delegate: Rectangle {
        required property var modelData  // this item = one notification object
        Text { text: modelData.summary }
    }
}
```

The `required` keyword means: "this property must be provided by whoever instantiates me" — here the Repeater provides it. Without `required`, QML would warn that `modelData` is unset.

---

## 9. Signals and Signal Handlers

Signals are QML's event system. Any object can emit signals, and you handle them with `on<SignalName>` handlers.

### Built-in signals

```qml
MouseArea {
    anchors.fill: parent
    onClicked: {
        console.log("clicked!")
        // multi-line JS is fine in { }
    }
    onPressed: doSomething()
    onEntered: parent.color = "red"
    onExited: parent.color = "blue"
}

Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: console.log("tick")
}
```

### Property change signals

Every property automatically has an `on<PropName>Changed` signal:

```qml
Rectangle {
    property int count: 0

    onCountChanged: console.log("count is now", count)
}
```

### Custom signals

```qml
Item {
    signal userLoggedIn(string username)

    // Emit it:
    onSomeEvent: userLoggedIn("alice")
}

// Parent or sibling can connect:
Connections {
    target: myItem
    function onUserLoggedIn(username) {
        console.log("Welcome,", username)
    }
}
```

### Arrow function handlers

When a signal passes arguments, you can use arrow function syntax:

```qml
NotificationServer {
    onNotification: n => {
        // n is the notification object passed by the signal
        console.log(n.summary)
        n.tracked = true   // tell Quickshell to keep tracking it
    }
}
```

---

## 10. Timers

`Timer` fires a signal after a delay (like `setTimeout`/`setInterval` in JavaScript):

```qml
Timer {
    id: myTimer
    interval: 5000      // milliseconds (5 seconds)
    running: true       // starts immediately
    repeat: false       // fire once then stop (default)
    onTriggered: doSomething()
}

// Like setInterval:
Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: updateClock()
}
```

Since `running` is a reactive property, you can conditionally start/stop a timer:

```qml
Timer {
    // Only run when the notification is NOT critical
    running: card.modelData.urgency !== NotificationUrgency.Critical
    interval: 5000
    onTriggered: card.modelData.dismiss()
}
```

When `urgency` changes to `Critical`, `running` instantly becomes `false` and the timer stops. When it changes back, the timer starts again. You never write `timer.stop()` or `timer.start()` explicitly.

---

## 11. Flickable and ScrollBar

`Flickable` is QML's scrollable container. It has a **viewport** (the visible area) and **content** (the full scrollable area). When content is taller than the viewport, the user can scroll.

```qml
Flickable {
    width: 380
    height: 400          // this is the visible viewport height
    contentHeight: 1200  // total content height (taller → scrollable)
    contentWidth: width  // no horizontal scroll

    clip: true           // don't draw content outside the viewport bounds

    // Put your content here. It can be as tall as contentHeight.
    Column {
        id: content
        width: parent.width
        // ... items ...
    }
}
```

**Critical**: `contentHeight` must be set explicitly. The Flickable doesn't auto-detect it. Typically you bind it to your content's `implicitHeight`:

```qml
Flickable {
    contentHeight: myColumn.implicitHeight

    Column {
        id: myColumn
        width: parent.width
        // children...
    }
}
```

### Attaching a ScrollBar

```qml
import QtQuick.Controls

Flickable {
    id: flick
    // ...

    ScrollBar.vertical: ScrollBar {
        // Show scrollbar only when content overflows
        policy: flick.contentHeight > flick.height
            ? ScrollBar.AlwaysOn
            : ScrollBar.AlwaysOff
    }
}
```

The `ScrollBar.vertical:` syntax is an **attached property** that wires the scrollbar to the flickable automatically — no manual positioning needed.

---

## 12. Quickshell-Specific Concepts

### Scope

`Scope` is Quickshell's root container. Every Quickshell config file starts with one. It's like a namespace — it holds your global state, servers, and windows:

```qml
import Quickshell

Scope {
    id: root
    // Global properties, ListModels, servers, IpcHandlers, windows...
}
```

### PanelWindow

A `PanelWindow` is a Wayland layer-shell window — a window that can be anchored to screen edges and optionally reserves space so other apps don't overlap it.

```qml
PanelWindow {
    anchors { top: true; right: true }   // anchor to top-right
    margins { top: 50; right: 12 }       // gap from the edges

    implicitWidth: 380
    implicitHeight: 200

    color: "transparent"                 // transparent background
    exclusionMode: ExclusionMode.Ignore  // don't push other windows away
}
```

Key properties:
- `anchors.*` — which screen edge(s) to attach to
- `margins.*` — gap from the edge in pixels
- `exclusionMode` — whether to reserve space (push other windows away) or not
- `screen` — which monitor to appear on (defaults to focused monitor)

### NotificationServer

Implements the D-Bus `org.freedesktop.Notifications` protocol. When any app sends a desktop notification (via `notify-send`, Slack, etc.), this server receives it.

```qml
NotificationServer {
    id: server
    actionsSupported: true   // tell apps we support action buttons
    bodySupported: true      // tell apps we support body text
    imageSupported: true     // tell apps we support images/icons

    onNotification: n => {
        // n is a Notification object
        // n.summary, n.body, n.appName, n.urgency, n.image, n.appIcon
        // n.tracked = true  → keep it in server.trackedNotifications
        // n.dismiss()       → remove it from tracked list
    }

    // Live list of currently tracked (not dismissed) notifications:
    // server.trackedNotifications
}
```

`NotificationUrgency` is an enum with values: `Low`, `Normal`, `Critical`.

### IpcHandler

Lets you control your Quickshell config from the command line or other scripts using `qs ipc`:

```qml
IpcHandler {
    target: "notifications"   // name of this handler

    function toggle(): void { root.centerOpen = !root.centerOpen }
    function show(): void { root.centerOpen = true }
    function hide(): void { root.centerOpen = false }
}
```

You can then call these from a terminal or keybind:
```bash
qs ipc call notifications toggle
qs ipc call notifications show
```

This is how a bar widget (or a Hyprland keybind) opens/closes the notification center.

### `Quickshell.screens`

A list of all connected monitors. Each screen object has properties like `.width`, `.height`, `.name`. A `PanelWindow` has a `.screen` property that tells you which monitor it's on, so you can read `centerWindow.screen?.height` to get the current monitor's height and cap the panel accordingly.

The `?.` is JavaScript optional chaining — `screen` might be null briefly during startup, so this safely returns `undefined` instead of crashing.

### `Qt.formatDateTime`

A Qt global function that formats a `Date` object:

```qml
Qt.formatDateTime(new Date(), "HH:mm")  // → "14:35"
```

`new Date()` is standard JavaScript. Qt provides `Qt.formatDateTime` as a convenience over JavaScript's own date formatting.

---

## 13. Walking Through the Notification Code

Now that you have all the concepts, let's read the actual file from top to bottom.

### 13.1 Top-level structure

```qml
Scope {
    id: root

    property bool centerOpen: false

    ListModel {
        id: history
    }
    // ...
}
```

`Scope` is the root. Two pieces of global state live here:

- **`centerOpen`** — a boolean that controls whether the notification center panel is visible. The `IpcHandler` and any future toggle buttons flip this.
- **`history`** — a `ListModel` that stores every notification that has come in (even after it's been dismissed from the live toast). This is our persistent history list for the notification center. It starts empty and gets items inserted at the front (`index 0`) whenever a notification arrives.

---

### 13.2 NotificationServer

```qml
NotificationServer {
    id: server
    actionsSupported: true
    bodySupported: true
    imageSupported: true

    onNotification: n => {
        history.insert(0, {
            summary: n.summary,
            body: n.body,
            appName: n.appName,
            urgency: n.urgency,
            time: Qt.formatDateTime(new Date(), "HH:mm")
        })
        n.tracked = true
    }
}
```

When a notification arrives:

1. A plain JS object `{ summary, body, appName, urgency, time }` is inserted at position 0 of `history` — newest first.
2. `n.tracked = true` tells Quickshell to add `n` to `server.trackedNotifications` — the live toast list. Without this, the notification is acknowledged and forgotten immediately.

Note that `history` stores a *copy* of the data as a plain object (not the live notification object). This is intentional — even after the toast is dismissed, the history entry stays. The live notification object `n` is separate and lives in `server.trackedNotifications`.

---

### 13.3 IpcHandler

```qml
IpcHandler {
    target: "notifications"
    function toggle(): void { root.centerOpen = !root.centerOpen }
    function show(): void { root.centerOpen = true }
    function hide(): void { root.centerOpen = false }
}
```

Three functions exposed over IPC. All they do is flip `root.centerOpen`. Because the notification center `PanelWindow` has `visible: root.centerOpen`, changing this property instantly shows or hides the window — no imperative show/hide calls, just reactive binding.

---

### 13.4 Live toast PanelWindow

```qml
PanelWindow {
    anchors { top: true; right: true }
    margins { top: 50; right: 12 }
    implicitWidth: 380
    implicitHeight: Math.max(1, toastCol.implicitHeight)
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    ColumnLayout {
        id: toastCol
        width: parent.width
        spacing: 10

        Repeater {
            model: server.trackedNotifications
            delegate: Rectangle { ... }
        }
    }
}
```

This window is always present (not toggled), but when there are no tracked notifications, `toastCol.implicitHeight` is 0, so `Math.max(1, 0)` = 1 — the window is essentially invisible (1px tall). When notifications arrive, the `Repeater` creates new delegate `Rectangle`s, `toastCol.implicitHeight` grows, and the window expands.

`exclusionMode: ExclusionMode.Ignore` means this window does NOT push other windows away — it floats over them.

#### The toast card delegate

```qml
delegate: Rectangle {
    id: card
    required property var modelData

    Timer {
        running: card.modelData.urgency !== NotificationUrgency.Critical
        interval: 5000
        onTriggered: card.modelData.dismiss()
    }

    Layout.fillWidth: true
    implicitHeight: toastInner.implicitHeight + 20

    radius: 8
    color: Config.colors.bg
    border.width: 2
    border.color: modelData.urgency === NotificationUrgency.Critical
        ? Config.colors.red : Config.colors.purple
    ...
```

Each tracked notification becomes one `Rectangle` card.

- **`required property var modelData`** — receives the notification object from the `Repeater`. It has `.summary`, `.body`, `.urgency`, `.image`, `.appIcon`, `.dismiss()`.
- **Timer** — auto-dismisses the toast after 5 seconds, *unless* urgency is `Critical`. The `running` property is a reactive binding — if urgency changes to Critical mid-display, the timer stops automatically.
- **`implicitHeight: toastInner.implicitHeight + 20`** — the card is as tall as its inner `RowLayout` plus 20px padding. This lets multi-line notification bodies expand the card.
- **Border color** — ternary expression: red for critical, purple otherwise. Updates reactively if urgency changes.

```qml
    RowLayout {
        id: toastInner
        anchors {
            left: parent.left; right: parent.right; top: parent.top
            margins: 10
        }
        spacing: 10

        Image {
            Layout.preferredHeight: 36
            Layout.preferredWidth: 36
            Layout.alignment: Qt.AlignTop
            fillMode: Image.PreserveAspectFit
            visible: source.toString() !== ""
            source: card.modelData.image || card.modelData.appIcon || ""
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text { text: card.modelData.summary ... }
            Text { text: card.modelData.body ... }
        }
    }
```

The card interior is a `RowLayout`: icon on the left, text column on the right.

- The `Image` tries `modelData.image` first (an inline image the app sent), then `modelData.appIcon` (the app's icon name), then empty string. `visible: source.toString() !== ""` hides the image slot entirely if no icon is available, so the text takes the full width.
- `Image.PreserveAspectFit` — scale the image down to fit the 36×36 box while keeping its aspect ratio, like CSS `object-fit: contain`.
- `Layout.alignment: Qt.AlignTop` — pin the icon to the top of the row so it doesn't stretch vertically when body text is long.

```qml
    MouseArea {
        anchors.fill: parent
        onClicked: card.modelData.dismiss()
    }
```

Clicking anywhere on the card dismisses it immediately. `dismiss()` removes the notification from `server.trackedNotifications`, which makes the `Repeater` destroy this delegate — the toast disappears.

---

### 13.5 Notification center PanelWindow

```qml
PanelWindow {
    id: centerWindow
    visible: root.centerOpen
    anchors { top: true; right: true }
    margins { top: 50; right: 12 }
    implicitWidth: 380

    property int screenHeight: centerWindow.screen?.height ?? 1080
    property int maxPanelHeight: Math.floor(screenHeight * 0.9) - 50
    property int naturalHeight: headerBar.implicitHeight + 24 + 24 + notifFlickable.contentHeight
    implicitHeight: Math.min(naturalHeight, maxPanelHeight)

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    ...
```

**`visible: root.centerOpen`** — the entire window appears/disappears as `centerOpen` is toggled.

**Height calculation** — three custom properties work together:

| Property | Value | Purpose |
|----------|-------|---------|
| `screenHeight` | `centerWindow.screen?.height ?? 1080` | Actual monitor height, fallback 1080 |
| `maxPanelHeight` | `screenHeight * 0.9 - 50` | 90% of screen minus the top margin |
| `naturalHeight` | header + padding + content | What the panel would be with unlimited space |
| `implicitHeight` | `Math.min(natural, max)` | Smaller of the two: fits content or caps at 90% screen |

When there are few notifications, `naturalHeight < maxPanelHeight` so the panel shrinks to fit. When there are many, it caps at 90% of screen height and the `Flickable` takes over for scrolling.

#### The outer Rectangle

```qml
Rectangle {
    width: parent.width
    height: parent.height
    radius: 10
    color: Config.colors.bg
    border.width: 2
    border.color: Config.colors.purple
    ...
```

The `PanelWindow` itself is transparent — the visible panel shape is this `Rectangle`. It uses `width/height: parent.width/height` (not `anchors.fill`) so it always matches the window size. The `radius: 10` gives rounded corners.

#### The sticky header

```qml
RowLayout {
    id: headerBar
    anchors {
        top: parent.top
        left: parent.left
        right: parent.right
        margins: 12
    }

    Text { text: "Notifications" ... }

    Text {
        text: "Clear All"
        visible: history.count > 0
        ...
        MouseArea {
            anchors.fill: parent
            onClicked: history.clear()
        }
    }
}
```

The header is anchored to the top of the `Rectangle` and sits *outside* the `Flickable`. This means it never scrolls away — it always stays visible at the top of the panel. `visible: history.count > 0` hides "Clear All" when there's nothing to clear (reactive — updates the moment the last item is removed).

#### The Flickable

```qml
Flickable {
    id: notifFlickable
    anchors {
        top: headerBar.bottom
        topMargin: 10
        left: parent.left; right: parent.right; bottom: parent.bottom
        leftMargin: 12; rightMargin: 12; bottomMargin: 12
    }

    clip: true
    contentHeight: cardCol.implicitHeight
    contentWidth: width

    ScrollBar.vertical: ScrollBar {
        policy: notifFlickable.contentHeight > notifFlickable.height
            ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
    }
    ...
```

- Anchored below the header (`top: headerBar.bottom`) and fills the rest of the panel.
- `clip: true` — content that scrolls out of the viewport is not rendered outside the flickable's bounds.
- `contentHeight: cardCol.implicitHeight` — the scrollable content is as tall as the card column.
- `contentWidth: width` — no horizontal scrolling.
- The `ScrollBar` uses a policy binding: it's always-on when content overflows, and hidden when everything fits. This avoids a permanent scrollbar taking space when you only have 1–2 notifications.

#### Empty state

```qml
Text {
    visible: history.count === 0
    width: parent.width
    text: "No notifications"
    ...
    horizontalAlignment: Text.AlignHCenter
}
```

A centered "No notifications" label that only shows when `history` is empty. Mutually exclusive with the card column — when `history.count > 0`, this is hidden and the `Column` below is visible.

#### The card Column

```qml
Column {
    id: cardCol
    width: history.count > 0
        ? notifFlickable.width - (notifFlickable.contentHeight > notifFlickable.height ? 14 : 0)
        : notifFlickable.width
    spacing: 8
    visible: history.count > 0

    Repeater {
        model: history
        delegate: Rectangle { ... }
    }
}
```

**Why `Column` not `ColumnLayout`?** As explained in section 6, `ColumnLayout` does not correctly report `implicitHeight` inside a `Flickable`. `Column` does, so `cardCol.implicitHeight` correctly equals the sum of all card heights plus spacing — which `contentHeight` binds to.

**Width adjustment**: when the scrollbar is visible (`contentHeight > height`), the column width shrinks by 14px to avoid content hiding behind the scrollbar.

#### The history card delegate

```qml
delegate: Rectangle {
    width: cardCol.width
    implicitHeight: cardContent.implicitHeight + 16
    radius: 6
    color: "transparent"
    border.width: 1
    border.color: Config.colors.purple

    Column {
        id: cardContent
        width: parent.width - 16
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 8
        spacing: 3

        Row {
            width: parent.width
            spacing: 6

            Text { ... /* summary */ }
            Text { id: timeText; text: model.time ... }
            Text {
                id: dismissText; text: "✕" ...
                MouseArea {
                    anchors.fill: parent
                    onClicked: history.remove(index)
                }
            }
        }

        Text { /* body */ }
        Text { /* appName */ }
    }
}
```

Each history entry is a `Rectangle` with a visible border. Inside is a `Column` (not `ColumnLayout`, for the same reason as above) with:

- A `Row` for the title line: summary text (fills remaining width), timestamp, dismiss button.
- Optional body text (hidden when empty via `visible: model.body !== ""`).
- Optional app name in muted color at the bottom.

`model.summary`, `model.time`, `model.body`, `model.appName` access the `ListModel` row data that was stored when the notification arrived (see `NotificationServer`).

`history.remove(index)` — `index` is automatically available inside a `Repeater` delegate and gives the row number of this item. Removing it from the `ListModel` destroys this delegate and causes `cardCol.implicitHeight` to shrink, which causes `notifFlickable.contentHeight` to shrink, which may cause the `PanelWindow.implicitHeight` to shrink — all automatically through reactive bindings.

---

## Putting it all together: data flow diagram

```
notify-send or any app
        │
        ▼
NotificationServer.onNotification
        │
        ├─── history.insert(0, {...})  ──► history ListModel
        │                                        │
        │                                        ▼
        │                               Repeater (history center)
        │                                        │
        │                                        ▼
        │                               Card delegates rendered
        │                                        │
        │                                        ▼
        │                               cardCol.implicitHeight updates
        │                                        │
        │                                        ▼
        │                               notifFlickable.contentHeight updates
        │                                        │
        │                                        ▼
        │                               centerWindow.naturalHeight updates
        │                                        │
        │                                        ▼
        │                               centerWindow.implicitHeight updates
        │                                        │
        │                                        ▼
        │                               Window resizes on screen
        │
        └─── n.tracked = true  ──────► server.trackedNotifications
                                                 │
                                                 ▼
                                       Repeater (live toasts)
                                                 │
                                                 ▼
                                       Toast card + Timer(5s)
                                                 │
                                        Timer fires or click
                                                 │
                                                 ▼
                                       n.dismiss() → removed from
                                       trackedNotifications → toast disappears
```

Every arrow in that diagram is a reactive binding or a signal/slot — no imperative "update the UI" code anywhere. You declare relationships, Qt keeps them true.

---

## Quick Reference: Concepts at a Glance

| Concept | One-liner |
|---------|-----------|
| Reactive binding | `y: x * 2` means y always equals 2x, forever |
| `implicitHeight` | Natural content-driven height, used for adaptive sizing |
| `anchors.fill` on a Layout | **Breaks** adaptive height — layout gets size from parent instead of driving it |
| `Column` vs `ColumnLayout` | Use `Column` inside `Flickable`; `ColumnLayout` breaks contentHeight |
| `Repeater` | For-loop that creates UI elements from a model |
| `ListModel` | Dynamic list; add/remove items, delegates update automatically |
| `required property var modelData` | How Repeater passes each item to its delegate (for C++-backed models) |
| `model.field` | Access ListModel row data inside a Repeater delegate |
| `PanelWindow` | Wayland layer-shell window anchored to screen edges |
| `NotificationServer` | D-Bus notification daemon built into Quickshell |
| `IpcHandler` | Exposes functions callable via `qs ipc call <target> <fn>` |
| `Flickable` | Scrollable container; you set `contentHeight` manually |
| `ScrollBar.vertical:` | Attached property that wires a scrollbar to a Flickable |
| `ExclusionMode.Ignore` | Window floats over other windows, doesn't reserve space |
