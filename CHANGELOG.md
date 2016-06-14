# Changelog

## 2016-06-14

### Fixed

- Passing JSON configuration directly through the data-configuration attribute
- Loading bar was always showing on Safari
- clammr integration was not using https URLs

## 2016-05-16

### Fixed

- only show clammr button if there is something to share
- Improve responsive behaviour

## 2016-04-07

### Added

- Episode titles are now linked in the 'out-of-the-box' themes
- Clammr support (https://www.clammr.com)

### Changed

- Embed URL is only shown when player is configured with a JSON URL

### Fixed

- Playlist behavior is now less error prone and can handle more than just mp3 feeds

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
