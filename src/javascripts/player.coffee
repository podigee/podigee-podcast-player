$ = require('jquery')
_ = require('lodash')

AudioFile = require('./audio_file.coffee')
DeeplinkParser = require('./deeplink_parser.coffee')
Utils = require('./utils.coffee')

class Player
  constructor: (@app, elem) ->
    self = this
    self.media = elem
    if Utils.isIE9()
      self.media.preload = "metadata"
    else
      self.media.preload = "none"
    @loadFile()
    @attachEvents()
    @app.init(self)
    @setInitialTime()

  jumpBackward: (seconds) =>
    seconds = seconds || @app.options.backwardSeconds
    @media.currentTime = @media.currentTime - seconds

  jumpForward: (seconds) =>
    seconds = seconds || @app.options.forwardSeconds
    @media.currentTime = @media.currentTime + seconds

  skipBackward: () =>
    @pause()
    @app.extensions.Playlist.playPrevious()

  skipForward: () =>
    @pause()
    @app.extensions.Playlist.playNext()

  changePlaySpeed: () =>
    nextRateIndex = @app.options.playbackRates.indexOf(@app.options.currentPlaybackRate) + 1
    if nextRateIndex >= @app.options.playbackRates.length
      nextRateIndex = 0

    @setPlaySpeed(@app.options.playbackRates[nextRateIndex])

  currentFile: =>
    @media.src

  loadFile: =>
    @pause()
    files = _.map @app.episode.media, (uri, format) =>
      new AudioFile(format, uri, @media)

    files = @filterUnplayable(files)
    files = @sortByPlayability(files)
    files = @sortByFormat(files)

    @media.src = files[0].uri
    @setDuration()

  # filter out unplayable files
  filterUnplayable: (files) ->
    _.filter files, (file) -> file.playable != ''

  # Sort files by probability of the browser to be able to play them
  sortByPlayability: (files) ->
    _.sortBy files, (file) ->
      return 1 if file.playable == 'maybe'
      return -1 if file.playable == 'probably'
      return 0

  # prefer bandwidth saving formats before others
  sortByFormat: (files) ->
    _.sortBy files, (file) ->
      return -100 if file.playable == 'probably' && file.format == 'opus'
      return -90 if file.playable == 'probably' && file.format == 'm4a'
      return -90 if file.playable == 'maybe' && file.format == 'mp3'
      return 0

  attachEvents: =>
    $(@media).on('timeupdate', @updateTime)
    $(@media).on('loadedmetadata', @app.mediaLoaded)
    $(@media).on('loadedmetadata', @setInitialTime)
    $(@media).on('durationchange', @app.mediaLoaded)
    $(@media).on('canplay', @app.mediaLoaded)
    $(@media).on('error', @app.mediaLoadError)
    $(@media).on('ended', @app.mediaEnded)

  updateTime: =>
    @setCurrentTime()
    @checkStopTime()

  setInitialTime: =>
    deeplink = new DeeplinkParser(@app.options.parentLocationHash)
    if deeplink.startTime > 0
      @currentTimeInSeconds = deeplink.startTime
      @media.currentTime = deeplink.startTime
      @app.updateTime(@currentTimeInSeconds)
    @stopTime = deeplink.endTime if deeplink.endTime?

  setCurrentTime: (time) =>
    if time
      @currentTimeInSeconds = time
      @media.currentTime = time
    else
      @currentTimeInSeconds = @media.currentTime
    @currentTime = Utils.secondsToHHMMSS(@currentTimeInSeconds)
    @app.updateTime(@currentTimeInSeconds)

  checkStopTime: () =>
    return unless @stopTime?
    if @currentTimeInSeconds >= @stopTime
      @stopTime = null
      @pause()

  setDuration: =>
    if @app.episode.duration
      @app.episode.humanDuration = Utils.secondsToHHMMSS(_.clone(@app.episode.duration))
      @duration = @app.episode.duration
      return

    clear = -> window.clearInterval(interval)

    interval = window.setInterval ((t) =>
      return unless @media.readyState > 0
      @app.episode.duration = @media.duration
      @duration = @media.duration
      @app.episode.humanDuration = Utils.secondsToHHMMSS(_.clone(@app.episode.duration))
      clear()
    ), 500

  setPlaySpeed: (speed) =>
    @media.playbackRate = @app.options.currentPlaybackRate = speed

  playPause: =>
    if @media.paused
      @play()
    else
      @pause()

  play: () ->
    return unless @media.paused
    if @media.readyState < 2 # can play current position
      @app.theme.addLoadingClass()
    if @media.readyState < 1 # has metadata available
      if @currentTimeInSeconds && @currentTimeInSeconds != @media.currentTime
        setTime = () =>
          @media.currentTime = @currentTimeInSeconds
          $(@media).off('loadedmetadata', setTime)

        $(@media).on('loadedmetadata', setTime)
    @media.play()
    @playing = true
    @app.togglePlayState()

  pause: () ->
    return if @media.paused
    @media.pause()
    @playing = false
    @app.togglePlayState()

  playing: false

module.exports = Player
