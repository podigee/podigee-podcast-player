# Changelog

## 2018-03-13

### Fixes

- fix umlauts in episode title being cut off in Firefox

## 2018-03-09

### Added

- It is now possible to configure the colors of the default theme (not stable yet!)
- Added subscribe bar (including subscribe button) to default theme
- Added accessibility labels to buttons

## 2018-03-08

### Fixes

- fix regression when checking for empty configurations

## 2018-03-01

### Fixes

- fix error when receiving empty configuration

## 2018-02-06

### Fixes

- fix displaying links in chaptermarks and playlist

## 2018-02-01

### Added

- playlist skip buttons can be disabled now

### Fixes

- pass language to subscribe button when opening popup
- fix progress bar not updating when episode changes from playlist

## 2018-02-01

### Fixes

- fix skipping between playlist entries

## 2018-01-30

### Fixes

- catch error when parsing URL for deeplinks

## 2018-01-26

### Fixes

- fix subscribe button popup opening multiple times

## 2018-01-19

### Added

- support for loading playlist information only when it is needed

## 2018-01-18

### Added

- support for podlove subscribe button

## 2018-01-17

### Fixes

- fix touch detection on progress bar
- fix updating progress bar time

### Changes

- add more podcast information for use in themes

## 2018-01-12

### Fixes

- better handling of current time when the episode is not yet fully loaded

### Changes

- improved touch support for progress bar scrubbing

### Removed

- non-working waveform extension was removed

## 2018-01-04

### Added

- support for easy translation of the interface
- podcast subtitle can be used in themes now

### Changes

- use a larger click target for scrubbing (works better on mobile)

## 2017-10-06

### Fixes

- fix loading the player when using the browser back button

## 2017-09-17

### Fixes

- use playlist order as it is in the configuration and re-sort it

## 2017-09-08

### Changes

- switch to `preload=none` on the audio tag for all browsers except IE<10
- split embed script and actual player script for faster loading times
- update dependencies

### Fixes

- we are IE 9 compatible now
- problem with loading playlist from the podcast feed

## 2017-09-07

### Fixes

- catch JSON parsing errors when injecting configuration into the iframe

## 2017-08-31

### Fixes

- better calculcation of cursor position when scrubbing

## 2017-07-11

### Fixes

- regression in iframe resizer
- prevent configuration loading twice

## 2017-07-10

### Removed

- clammr is going out of business soon, so no sharing any more

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
