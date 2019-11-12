$ = require('jquery')
sightglass = require('sightglass')
rivets = require('rivets')

Utils = require('./utils.coffee')

Extension = require('./extension.coffee')

class ProgressBar extends Extension
  @extension:
    name: 'ProgressBar'
    type: 'progress'

  constructor: (@app) ->
    return unless @app.theme.progressBarElement.length

    @elem = @app.theme.progressBarElement
    @player = @app.player
    @media = @app.player.media
    @timeMode = 'countup'

    @init()

  init: () =>
    @render()
    @findElements()
    @bindEvents()
    @hideBuffering()
    @updateTime(0)

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

  updateBarWidths: () =>
    @updatePlayed()
    @updateLoaded()

  buildTimeString: (time) =>
    timeString = Utils.secondsToHHMMSS(time)
    if @player.duration < 3600
      timeString = timeString.replace(/^00:/, '')
    timeString

  updateTime: (time) =>
    return unless typeof time == 'number'
    currentTime = time || @media.currentTime
    @timeLeft = @buildTimeString(@player.duration - currentTime)
    @timePlayed = @buildTimeString(currentTime)

    @view.update(@context())

    @updatePlayed()

    return currentTime

  updateView: () =>
    newElem = $('<progress-bar>')
    @elem.replaceWith(newElem)
    @elem = $('progress-bar')
    @init()
    @view.update(@context())

  updateLoaded: (buffered) =>
    return unless @media.seekable.length

    newWidth = @media.seekable.end(@media.seekable.length - 1) * @timeRailFactor()
    @loadedElement.css('margin-left', 0).width(newWidth)

  #private

  context: () ->
    {
      timeLeft: @timeLeft,
      timePlayed: @timePlayed,
      timeCountdown: @timeMode == 'countdown',
      timeCountup: @timeMode == 'countup'
    }

  render: () ->
    html = $(@template())
    @view = rivets.bind(html, @context())
    @elem.replaceWith(html)
    @elem = $('.progress-bar')

  template: ->
    """
    <div class="progress-bar">
      <button class="progress-bar-time-played time-remaining" pp-show="timeCountdown" title="#{@t('progress_bar.switch_time_mode')}" aria-label="#{@t('progress_bar.switch_time_mode')}">-{ timeLeft }</button>
      <button class="progress-bar-time-played time-played" pp-show="timeCountup" title="#{@t('progress_bar.switch_time_mode')}" aria-label="#{@t('progress_bar.switch_time_mode')}">{ timePlayed }</button>
      <div class="progress-bar-rail">
        <span class="progress-bar-loaded"></span>
        <span class="progress-bar-buffering"></span>
        <span class="progress-bar-played"></span>
      </div>
    </div>
    """

  findElements: () ->
    @timeElements = @elem.find('.progress-bar-time-played')
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

  handleLetgo: (event) =>
    $(@app.elem).off('mousemove')
    $(@app.elem).off('mouseup')
    $(@app.elem).off('mouseleave')
    $(@app.elem).off('touchmove')
    $(@app.elem).off('touchend')
    @handleDrop(event)

  handlePickup: (event) =>
    return if (event.target.className.indexOf('progress-bar-time-played') != -1)
    $(@app.elem).on 'mousemove', @handleDrag
    $(@app.elem).on 'mouseup', @handleLetgo
    $(@app.elem).on 'mouseleave', @handleLetgo
    $(@app.elem).on 'touchmove', @handleDrag
    $(@app.elem).on 'touchend', @handleLetgo

  bindEvents: () ->
    @timeElements.on 'click', @switchTimeDisplay

    $(@media).on('timeupdate', @updateTime)
      .on('play', @triggerPlaying)
      .on('playing', @triggerPlaying)
      .on('waiting', @triggerLoading)
      .on('loadeddata', @triggerLoaded)
      .on('progress', @updateLoaded)

    # drag&drop on time rail
    @elem.on 'mousedown', @handlePickup
    @elem.on 'touchstart', @handlePickup

  jumpToPosition: (position) =>
    if @player.duration
      pixelPerSecond = @player.duration/@barWidth()
      newTime = pixelPerSecond * position
      unless newTime == @media.currentTime
        @player.setCurrentTime(newTime)

  handleDrag: (event) =>
    position = Utils.calculateCursorPosition(event, @elem[0])
    if position <= @barWidth()
      @playedElement.width(position + 'px')

  handleDrop: (event) =>
    position = Utils.calculateCursorPosition(event, @elem[0])

    # catch drop positions outside of progress bar
    position = 0.001 if position < 0
    if position <= @barWidth()
      @jumpToPosition(position)

  barWidth: => @railElement.width()

  timeRailFactor: =>
    @barWidth()/@player.duration

  updatePlayed: () =>
    newWidth = (@media.currentTime || @player.currentTimeInSeconds) * @timeRailFactor()
    @playedElement.width(newWidth)

module.exports = ProgressBar
