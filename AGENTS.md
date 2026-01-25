ObjectiveHUD is a small macOS menu-bar app with an always-on-top overlay, backed by SwiftData.

## Data model

ObjectiveHUD uses SwiftData with two `@Model` classes: `ObjectiveSection` and `Objective`.

`ObjectiveSection` (Sources/ObjectiveHUD/Models/ObjectiveSection.swift) stores `id`, `name`, `order`, `isVisible`, `updatedAt`, plus the relationship array `objectives: [Objective]`. It also provides convenience views of that relationship via `sortedObjectives` and `visibleObjectives`.

`Objective` (Sources/ObjectiveHUD/Models/Objective.swift) stores `id`, `title`, `order`, `isCompleted`, `isVisible`, optional `progressCurrent`/`progressTotal`, optional `countdownTarget`/`countdownLabel`, and `updatedAt`, plus an optional back-reference `section: ObjectiveSection?`. The `progressSummary`, `countdownSummary`, and `overlaySuffix` helpers are used by the overlay to render extra context, and `touch()` centralizes updating `updatedAt`.

## Persistence

Persistence is handled by a SwiftData `ModelContainer` created in Sources/ObjectiveHUD/Persistence/DataController.swift. It builds a `Schema` containing `Objective` and `ObjectiveSection` and creates a `ModelConfiguration(isStoredInMemoryOnly: inMemory)`. By default (`inMemory: false`) the store is persisted on disk in the app's sandboxed container; passing `inMemory: true` makes it ephemeral for previews/tests.

The primary read/write facade is `ObjectivesStore` (Sources/ObjectiveHUD/Store/ObjectivesStore.swift). It fetches sections with a `FetchDescriptor` sorted by section order, prefetches `objectives`, keeps each section's objectives sorted, and saves changes via `context.save()`. On startup it also ensures the default sections ("Main Objectives" and "Bonus Objectives") exist. In addition to basic CRUD, it supports reordering objectives within a section (`moveObjectives`) and moving a single objective across sections (`moveObjective`), keeping per-section `order` values contiguous.

## App wiring and UI

Sources/ObjectiveHUD/App/AppEnvironment.swift is the composition root: it creates the `DataController`, `ObjectivesStore`, and `OverlayWindowManager`.

Sources/ObjectiveHUD/App/ObjectiveHUDApp.swift declares two scenes: a `MenuBarExtra` for quick actions and a dedicated editor `Window` ("Edit Objectives"). Both scenes inject the same SwiftData container via `.modelContainer(environment.dataController.container)`, and the store is shared via `.environmentObject(environment.store)`.

The editor UI lives under Sources/ObjectiveHUD/Editor. `EditorView` renders a multi-section `List` with per-row editing (`ObjectiveRowView`) and a details sheet (`ObjectiveDetailView`) for progress/countdown/section assignment. Drag-and-drop between sections is implemented by encoding the objective UUID as `UTType.text` on drag and handling `.onInsert(of:)` on the destination section. Because SwiftUI's `.draggable` API expects `Transferable` on newer toolchains, Sources/ObjectiveHUD/Overlay/View+DragCompatibility.swift adds a small shim that forwards an `NSItemProvider`-based drag to `.onDrag`.

The overlay UI lives under Sources/ObjectiveHUD/Overlay. `OverlayWindowManager` hosts `OverlayView` inside a borderless, non-activating `NSPanel` at `.statusBar` level, positions it near the top-left of the main display, and auto-shows/auto-hides based on whether there are any visible objectives (and whether the user has manually hidden it via the menu bar toggle). The overlay is intentionally non-interactive (`ignoresMouseEvents` and `allowsHitTesting(false)`).

Overlay styling is driven by packaged resources. Package.swift processes Sources/ObjectiveHUD/Resources, which includes the "Michroma-Regular.ttf" font and "mission-triangle.png" pointer asset. Fonts are registered at launch in Sources/ObjectiveHUD/App/FontRegistry.swift, and the overlay loads the pointer image via Sources/ObjectiveHUD/Overlay/OverlayAssets.swift.
