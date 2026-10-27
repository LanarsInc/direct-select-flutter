## Unreleased

### Breaking changes

* Require Dart 3.0 and Flutter 3.10 or newer ([#33](https://github.com/LanarsInc/direct-select-flutter/pull/33)).

### Added

* `DirectSelectList.openOnLongPress` opens the list only after a long press, so a drag that starts on the field still scrolls the page or closes a bottom sheet. Off by default ([#24](https://github.com/LanarsInc/direct-select-flutter/pull/24)).

### Changed

* The selected item no longer requires a bounded width, so `DirectSelectList` can be placed inside a `Row` without `Expanded` or in a horizontal scroll view ([#30](https://github.com/LanarsInc/direct-select-flutter/issues/30)). Layouts with a bounded width are unchanged. When the item shrinks to its content, only the item itself reacts to the hold-and-drag gesture.
* `DirectSelectItem.isSelected` is now typed as `bool` and `DirectSelectItem.scaleFactor` as `num`, instead of `dynamic`.

### Fixed

* The list no longer locks up after a drag that starts horizontally, and the overlay is released when the drag gesture is cancelled instead of staying on screen ([#32](https://github.com/LanarsInc/direct-select-flutter/issues/32), [#34](https://github.com/LanarsInc/direct-select-flutter/pull/34)).
* The list overlay lines up with the field when `DirectSelectContainer` is not at the top left of its parent, for example under `Padding` or `SafeArea`, and keeps the container's size when it does not fill the screen, for example in a bottom sheet ([#24](https://github.com/LanarsInc/direct-select-flutter/pull/24)).
* Options are no longer rendered off screen when the field is near the bottom or top of a scrollable view: the overlay keeps the neighboring options visible ([#18](https://github.com/LanarsInc/direct-select-flutter/issues/18), [#34](https://github.com/LanarsInc/direct-select-flutter/pull/34)).

### Deprecated

* `toggleListOverlayVisibility`: use `showListOverlay` and `hideListOverlay` instead ([#34](https://github.com/LanarsInc/direct-select-flutter/pull/34)).

### Removed

* The `rect_getter` dependency ([#33](https://github.com/LanarsInc/direct-select-flutter/pull/33)).

### Other

* The package passes pub.dev static analysis with `package:lints/core.yaml`.
* Widget tests for the selected and list item layouts, the overlay position and the long press mode.
* The unused root Android and iOS app scaffolding and other unused files are removed from the repository ([#33](https://github.com/LanarsInc/direct-select-flutter/pull/33)).
* The example app targets the latest Flutter (Gradle 9, Android Gradle Plugin 9, Kotlin 2.4), is split into reusable widgets, and shows compact selectors inside a `Row` and a horizontal scroll view and a selector in a bottom sheet that opens on long press.

## [1.1.1] - 2021.05.14

* Fix [#25](https://github.com/LanarsInc/direct-select-flutter/issues/25)

## [1.1.0] - 2021.03.10

* Migrate to null safety

## [1.0.7] - 2020.12.02

* Remove redundant dependencies
* Update dart docs

## [1.0.6] - 2020.05.05

* Fix update of selected item

## [1.0.5+1] - 2020.04.27

* Update dependencies to latest version
* Fix spelling
* Get rid of deprecated method call 'inheritFromWidgetOfExactType'

## [1.0.5] - 2019.10.18

* Throw exception if dsl not extends dsl listener
* Add listener to notify that user must hold instead of just tap
* Add optional decoration param to DSL Container

## [1.0.4] - 2019.07.08

* Choice screen color can be set up using theme

## [1.0.3] - 2019.05.31

* Improve code formatting, fixed immutable issues.
* Improve documentation

## [1.0.2] - 2019.03.20

* Horizontal scroll problem fix
* Scale down small overlay problem resolved

## [1.0.0] - 2019.03.13

* Initial Open Source release.