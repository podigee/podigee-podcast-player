$ = require('jquery')

Utils = require('./utils.coffee')

class ProgressBar
  constructor: (@elem, @player, @timeMode) ->
    @findElements()
    @bindEvents()
    @initLoadingAnimation()

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
    return unless @player.buffered.length

    newStart = @player.buffered.start(0) * @timeRailFactor()
    newWidth = @player.buffered.end(0) * @timeRailFactor()
    @loadedElement.css('margin-left', newStart).width(newWidth)

  #private

  findElements: () ->
    @timeElement = @elem.find('.progress-bar-time-played')
    @railElement = @elem.find('.progress-bar-rail')
    @playedElement = @elem.find('.progress-bar-played')
    @loadedElement = @elem.find('.progress-bar-loaded')
    @bufferingElement = @elem.find('.progress-bar-buffering')

  bindEvents: () ->
    @timeElement.click => @switchTimeDisplay()

    # drag&drop on time rail
    @railElement.on 'mousedown', (event) =>
      @handleMouseMove(event)
      $(this).on 'mousemove', (event) =>
        @handleMouseMove(event)
      $(this).on 'mouseup', (event) =>
        $(this).off('mousemove')
        $(this).off('mouseup')

  jumpToPosition: (position) =>
    if @player.duration
      pixelPerSecond = @player.duration/@barWidth()
      newTime = pixelPerSecond * position
      unless newTime == @player.currentTime
        @player.setCurrentTime(newTime)

  handleMouseMove: (event) =>
    position = event.pageX - $(event.target).offset().left
    @jumpToPosition(position)

  initLoadingAnimation: ->
    elem = @elem.find('.progress-bar-buffering')
    bar = $('<div>').addClass('progress-bar-buffering-bar')
    line = $('<div>').addClass('progress-bar-buffering-line')

    # render 3 lines per 100px of bar length
    numberOfLines = elem.width() / 100 * 3
    for i in [0..numberOfLines]
      bar.append(line.clone())

    elem.append(bar)

  barWidth: => @railElement.width()

  timeRailFactor: =>
    @barWidth()/@player.duration

  updatePlayed: () =>
    newWidth = @player.currentTime * @timeRailFactor()
    @playedElement.width(newWidth)

module.exports = ProgressBar
