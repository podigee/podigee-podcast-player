$ = require('jquery')
_ = require('lodash')

AudioFile = require('./audio_file.coffee')
Utils = require('./utils.coffee')

class Player
  constructor: (@app, elem) ->
    self = this
    self.media = elem
    self.media.preload = "metadata"
    @loadFile()
    @attachEvents()
    @app.init(self)

  jumpBackward: (seconds) =>
    seconds = seconds || @app.options.backwardSeconds
    @media.currentTime = @media.currentTime - seconds

  jumpForward: (seconds) =>
    seconds = seconds || @app.options.forwardSeconds
    @media.currentTime = @media.currentTime + seconds

  changePlaySpeed: () =>
    nextRateIndex = @app.options.playbackRates.indexOf(@app.options.currentPlaybackRate) + 1
    if nextRateIndex >= @app.options.playbackRates.length
      nextRateIndex = 0

    @setPlaySpeed(@app.options.playbackRates[nextRateIndex])

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
      return 1 if file.playable == ''
      return 1 if file.playable == 'maybe' && file.playable == 'probably'
      return -1 if file.playable == 'probably'
      return 0

  # prefer bandwidth saving formats before others
  sortByFormat: (files) ->
    _.sortBy files, (file) ->
      return -100 if file.playable == 'probably' && file.format == 'opus'
      return -90 if file.playable == 'probably' && file.format == 'm4a'
      return 0

  attachEvents: =>
    $(@media).on('timeupdate', @updateTime)
    $(@media).on('loadedmetadata', @app.mediaLoaded)
    $(@media).on('durationchange', @app.mediaLoaded)
    $(@media).on('canplay', @app.mediaLoaded)
    $(@media).on('error', @app.mediaLoadError)
    $(@media).on('ended', @app.mediaEnded)

  updateTime: =>
    @app.updateTime()
    @setCurrentTime()

  setInitialTime: =>
    $(@media).on 'loadedmetadata', =>
      @media.currentTime = @timeHash()

  setCurrentTime: =>
    @currentTimeInSeconds = @media.currentTime
    @currentTime = Utils.secondsToHHMMSS(@currentTimeInSeconds)

  setDuration: =>
    clear = -> window.clearInterval(interval)

    interval = window.setInterval ((t) =>
      return unless @media.readyState > 0
      @app.episode.duration = Utils.secondsToHHMMSS(@media.duration)
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
    if @media.readyState < 2
      @app.theme.addLoadingClass()
    @media.play()
    @playing = true
    @app.togglePlayState()

  pause: () ->
    return if @media.paused
    @media.pause()
    @playing = false
    @app.togglePlayState()

  playing: false

  # private

  timeHash: =>
    if hash = @app.options.parentLocationHash
      hash = hash[1..-1].split('&')
      timeHash = _(hash).find (h) -> _(h).startsWith('t')

      if timeHash
        timeHash.split('=')[1]
      else
        0
    else
      0

module.exports = Player
