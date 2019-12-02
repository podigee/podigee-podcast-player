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
    @setInitialTime()
    @app.init(self)
    @app.updateTime(@currentTimeInSeconds)

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

    @src = files[0].uri

    # If src was already set for the audio element we can immediately set src
    # If we are dealing with Safari 10 or below we also need to do this
    if @media.src.length || Utils.isLteSafari10()
      @media.src = @src
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
    else
      @currentTimeInSeconds = 0
    @currentTime = Utils.secondsToHHMMSS(@currentTimeInSeconds)
    @stopTime = deeplink.endTime if deeplink.endTime?

  setCurrentTime: (time) =>
    if time
      @currentTimeInSeconds = time
      @media.currentTime = time
    else
      @currentTimeInSeconds = @media.currentTime
    # Safari sometimes plays "over the file's end", this prevents
    # the player from displaying a weird time in this case
    if @currentTimeInSeconds > @duration
      @currentTimeInSeconds = @duration
    @currentTime = Utils.secondsToHHMMSS(@currentTimeInSeconds)
    @app.updateTime(@currentTimeInSeconds)
    @emitEvent('timeupdate')

  checkStopTime: () =>
    return unless @stopTime?
    if @currentTimeInSeconds >= @stopTime
      @stopTime = null
      @pause()

  setDuration: =>
    if @app.episode.duration
      humanDuration = Utils.secondsToHHMMSS(_.clone(@app.episode.duration))
      if @app.episode.duration < 3600
        humanDuration = humanDuration.replace(/^00:/, '')
      @app.episode.humanDuration = humanDuration
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

    # set src on first playback to prevent IE from preloading the audio file
    unless @media.src
      @media.src = @src

    if @media.readyState < 2 # can not play current position
      @app.theme.addLoadingClass()
    if @media.readyState < 1 # metadata not yet available
      if @currentTimeInSeconds && @currentTimeInSeconds != @media.currentTime
        # temporarily save time because Safari will reset it once metadata was loaded
        time = @currentTimeInSeconds
        setTime = () =>
          @media.currentTime = time
          $(@media).off('loadedmetadata', setTime)

        $(@media).on('loadedmetadata', setTime)

    unless Utils.isLteIE11()
      @media.play().then(() => @setMediaSessionInfo()).catch((e) => console.debug(e))
    else
      @media.play()
    @playing = true
    @app.togglePlayState()

  setMediaSessionInfo: () =>
    return unless navigator.mediaSession

    artwork = [96, 128, 192, 256, 384, 512].map (size) =>
      {
        src: Utils.scaleImage(@app.episode.coverUrl, size),
        sizes: "#{size}x#{size}",
        type: 'image/png'
      }

    navigator.mediaSession.metadata = new MediaMetadata({
      title: @app.episode.title,
      album: @app.podcast.title,
      artwork: artwork
    })

  pause: () ->
    return if @media.paused
    @media.pause()
    @playing = false
    @app.togglePlayState()

  playing: false

  eventListeners: {}
  addEventListener: (type, listener) ->
    @eventListeners[type] = listener

  emitEvent: (type, options) ->
    return unless @eventListeners[type]
    @eventListeners[type](options)

module.exports = Player
