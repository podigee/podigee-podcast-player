# Changelog

## 2016-04-05

### Added

- Player now chooses a suitable format for playing ([47077](https://github.com/podigee/podigee-podcast-player/commit/470771230adf31a175f877b0420e6b9bf16cd158))
- iframe only mode ([2776f](https://github.com/podigee/podigee-podcast-player/commit/2776f6066752cf28be73d02e4316270ec3895e8b))
- introduced `startPanel` configuration to choose panel shown by default more easily

### Changed

- removed `showOnStart` configuration option for each extension
- refactored extension rendering

### Fixed

- Race condition when panel was opened on start

## 2016-03-02

### Added

- Resize player interface when window size changes
- Add embed code to share extension

### Changed

- Disabled waveform extension because of [serious issues](https://github.com/podigee/podigee-podcast-player/issues/11)

### Fixed

- JS loading errors from Chromecast extension

### Deprecated

- Changed `episode.cover_url` configuration option to `episode.coverUrl` for consistency, still works but will be removed in the future

## 2016-02-23

### Added

- Share with timestamp aka. deeplinking

### Changed

- Mobile breakpoints are now more appropriate
- [internal] the way to instantiate player component
- [internal] the way configuration was passed in through the embed iframe
