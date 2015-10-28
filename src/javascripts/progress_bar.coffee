$ = require('jquery')

Utils = require('./utils.coffee')

class ProgressBar
  @extension:
    name: 'ProgressBar'
    type: 'progress'

  constructor: (@app) ->
    return unless @app.theme.progressBarElement.length

    @elem = @app.theme.progressBarElement
    @player = @app.player.media

    @findElements()
    @bindEvents()

  showBuffering: () ->
    @bufferingElement.show()

  hideBuffering: () ->
    @bufferingElement.hide()

  switchTimeDisplay: =>
    @timeMode = if @timeMode == 'countup'
      'countdown'
    else
      'countup'

    @updateTime()

  updateTime: () =>
    time = if @timeMode == 'countup'
      prefix = ''
      @player.currentTime
    else
      prefix = '-'
      @player.duration - @player.currentTime

    timeString = Utils.secondsToHHMMSS(time)
    @timeElement.text(prefix + timeString)

    @updatePlayed()

    return timeString

  updateLoaded: (buffered) =>
    return unless @player.seekable.length

    newWidth = @player.seekable.end(@player.seekable.length - 1) * @timeRailFactor()
    @loadedElement.css('margin-left', 0).width(newWidth)

  #private

  findElements: () ->
    @timeElement = @elem.find('.progress-bar-time-played')
    @railElement = @elem.find('.progress-bar-rail')
    @playedElement = @elem.find('.progress-bar-played')
    @loadedElement = @elem.find('.progress-bar-loaded')
    @bufferingElement = @elem.find('.progress-bar-buffering')

  triggerLoading: =>
    @updateLoaded()
    @showBuffering()

  triggerPlaying: =>
    @updateLoaded()
    @hideBuffering()

  triggerLoaded: =>
    @updateLoaded()
    @hideBuffering()

  bindEvents: () ->
    @timeElement.click => @switchTimeDisplay()

    $(@player).on('timeupdate', @updateTime)
      .on('play', @triggerPlaying)
      .on('playing', @triggerPlaying)
      .on('waiting', @triggerLoading)
      .on('loadeddata', @triggerLoaded)
      .on('progress', @updateLoaded)

    # drag&drop on time rail
    @railElement.on 'mousedown', (event) =>
      currentTarget = event.currentTarget
      target = event.target
      $(currentTarget).on 'mousemove', (event) =>
        @handleDrag(event)
      $(target).on 'mouseup', (event) =>
        $(currentTarget).off('mousemove')
        $(target).off('mouseup')
        @handleDrop(event)

  jumpToPosition: (position) =>
    if @player.duration
      pixelPerSecond = @player.duration/@barWidth()
      newTime = pixelPerSecond * position
      unless newTime == @player.currentTime
        @player.currentTime = newTime

  handleDrag: (event) =>
    position = Utils.calculateCursorPosition(event)
    @playedElement.width(position + 'px')

  handleDrop: (event) =>
    position = Utils.calculateCursorPosition(event)
    @jumpToPosition(position)

  barWidth: => @railElement.width()

  timeRailFactor: =>
    @barWidth()/@player.duration

  updatePlayed: () =>
    newWidth = @player.currentTime * @timeRailFactor()
    @playedElement.width(newWidth)

module.exports = ProgressBar
