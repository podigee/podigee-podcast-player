$ = require('jquery')
_ = require('lodash')

Utils = require('./utils.coffee')

class Player
  constructor: (@app, elem) ->
    self = this
    self.media = elem
    self.media.preload = "metadata"
    @options = @app.options
    @attachEvents()
    @setInitialTime()
    @setCurrentTime()
    @app.init(self)

  jumpBackward: (seconds) =>
    seconds = seconds || @options.backwardSeconds
    @media.currentTime = @media.currentTime - seconds

  jumpForward: (seconds) =>
    seconds = seconds || @options.forwardSeconds
    @media.currentTime = @media.currentTime + seconds

  changePlaySpeed: () =>
    nextRateIndex = @options.playbackRates.indexOf(@options.currentPlaybackRate) + 1
    if nextRateIndex >= @options.playbackRates.length
      nextRateIndex = 0

    @setPlaySpeed(@options.playbackRates[nextRateIndex])

  attachEvents: =>
    $(@media).on('timeupdate', @setCurrentTime)

  setInitialTime: =>
    @media.currentTime = @timeHash()

  setCurrentTime: =>
    @currentTimeInSeconds = @media.currentTime
    @currentTime = Utils.secondsToHHMMSS(@currentTimeInSeconds)

  setPlaySpeed: (speed) =>
    @media.playbackRate = @options.currentPlaybackRate = speed

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
