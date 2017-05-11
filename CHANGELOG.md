# Changelog

## 2017-05-09

### Added

- ability to skip between playlist entries
- extract more information from feed playlist entries
- add possibility to add a playlist via initial configuration to allow more advanced uses
- add podcast title to configuration parser

## 2017-04-20

### Changes

- iframe is loaded from the same protocol as the surrounding site (before always used https)

## 2017-04-03

### Fixes

- regression in chapter mark update while playing

## 2017-03-07

### Fixes

- various problems with extracting playlists from feeds

## 2017-02-28

### Fixes

- ensure correct order of chapter marks

## 2017-02-16

### Fixes

- issues when clicking playlist items

## 2017-01-05

### Fixes

- title link opening in iframe

## 2017-01-04

### Fixes

- regression in deep linking code

## 2016-12-27

### Fixes

- problem with injecting configuration into iframe

### Changes

- improve deep link capabilities

## 2016-12-07

### Fixes

- HTML entity encoding in themes

## 2016-12-02

### Fixed

- problems with transcripts in Safari
- update vtt.js to work around bug in Firefox
- some smaller Internet Explorer related issues

### Added

- improvements for loading indicator

### Changed

- clean up internal player events

## 2016-11-29

### Added

- support for player.js protocol

## 2016-11-24

### Added

- WebVTT transcript support

## 2016-10-30

### Fixed

- iframe resizing too late
- play button not reacting on mobile safari
- resize iframe again if media is loaded to late

### Added

- some new icons

### Changed

- loading animation if play button is clicked before audio is ready to play

## 2016-10-17

### Fixed

- UI problems with transcript speakers
- fix off-by-one error in transcript search

## 2016-10-06

### Added

- transcript extension supports JSON

### Fixed

- UI problems in transcript search
- fix off-by-one error in transcript search

## 2016-09-18

### Added

- search in transcripts

## 2016-08-16

### Added

- transcript extension supports SRT

## 2016-07-07

### Added

- duration is now available in templates

### Changed

- switched from fontawesome to a custom icon set

### Fixed

- horizontal resizing should work better now

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
