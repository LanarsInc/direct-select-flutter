## [1.2.0] - 2026.10.27

* Require Dart 3.0 and Flutter 3.10 or newer ([#33](https://github.com/LanarsInc/direct-select-flutter/pull/33))
* Remove `rect_getter` dependency ([#33](https://github.com/LanarsInc/direct-select-flutter/pull/33))
* Allow `DirectSelectList` inside a `Row` without `Expanded` or in a horizontal scroll view ([#30](https://github.com/LanarsInc/direct-select-flutter/issues/30))
* Add `DirectSelectList.openOnLongPress` to open the list only after a long press, so a drag on the field still scrolls the page or closes a bottom sheet ([#24](https://github.com/LanarsInc/direct-select-flutter/pull/24))
* Fix list lock up after a horizontal drag and overlay stuck after a cancelled drag ([#32](https://github.com/LanarsInc/direct-select-flutter/issues/32), [#34](https://github.com/LanarsInc/direct-select-flutter/pull/34))
* Keep options on screen when the field is near the top or bottom of a scrollable view ([#18](https://github.com/LanarsInc/direct-select-flutter/issues/18), [#34](https://github.com/LanarsInc/direct-select-flutter/pull/34))
* Fix list overlay position when `DirectSelectContainer` is under `Padding` or `SafeArea`, and keep the container size when it does not fill the screen, for example in a bottom sheet ([#24](https://github.com/LanarsInc/direct-select-flutter/pull/24))
* Deprecate `toggleListOverlayVisibility` in favor of `showListOverlay` and `hideListOverlay` ([#34](https://github.com/LanarsInc/direct-select-flutter/pull/34))
* Type `DirectSelectItem.isSelected` as `bool` and `DirectSelectItem.scaleFactor` as `num`
* Fix pub.dev static analysis issues
* Add widget tests
* Remove unused root Android and iOS scaffolding ([#33](https://github.com/LanarsInc/direct-select-flutter/pull/33))
* Update example app to the latest Flutter

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