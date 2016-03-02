# Changelog

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
