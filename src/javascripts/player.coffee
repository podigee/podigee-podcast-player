class Player
  constructor: (@app, elem) ->
    self = this
    self.media = elem
    self.media.preload = "metadata"
    @options = @app.options
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

  setPlaySpeed: (speed) =>
    @media.playbackRate = @options.currentPlaybackRate = speed

module.exports = Player
