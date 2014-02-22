class PodiPlay
  constructor: (@elemClass, options) ->
    @elem = $(@elemClass)
    audioElem = @elem.find('audio')[0]
    @setOptions(options)
    new MediaElement(audioElem, {success: (media, elem) => @init(media, elem) })

  # options

  defaultOptions: {
    currentPlaybackRate: 1
    playbackRates: [1.0, 1.5, 2.0]
    timeMode: 'countup'
    backwardSeconds: 10
    forwardSeconds: 30
  }

  setOptions: (options) ->
    @options = $.extend(true, @defaultOptions, options)

  init: (@player, elem) ->
    that = @
    @findElements()
    @initScrubber()
    @bindButtons()
    @bindPlayerEvents()

  findElements: ->
    @scrubberElement = @elem.find('.time-scrubber')
    @timeElement = @elem.find('.time-played')
    @scrubberRailElement = @scrubberElement.find('.rail')
    @scrubberPlayedElement = @scrubberElement.find('.time-scrubber-played')
    @scrubberLoadedElement = @scrubberElement.find('.time-scrubber-loaded')
    @scrubberBufferingElement = @scrubberElement.find('.time-scrubber-buffering')
    @playPauseElement = @elem.find('.play-button')
    @backwardElement = @elem.find('.backward-button')
    @forwardElement = @elem.find('.forward-button')
    @speedElement = @elem.find('.speed-toggle')

  scrubberWidth: => @scrubberRailElement.width()

  # initialize elements

  initScrubber: ->
    newWidth = @scrubberElement.width() - @timeElement.width()
    @scrubberRailElement.width(newWidth)
    @initLoadingAnimation()

  initLoadingAnimation: ->
    elem = @scrubberElement.find('.time-scrubber-buffering')
    bar = $('<div>').addClass('time-scrubber-buffering-bar')
    line = $('<div>').addClass('time-scrubber-buffering-line')

    # render 3 lines per 100px of bar length
    numberOfLines = elem.width() / 100 * 3
    for i in [0..numberOfLines]
      bar.append(line.clone())

    elem.append(bar)

  togglePlayState: (elem) =>
    @playPauseElement.toggleClass('fa-play')
    @playPauseElement.toggleClass('fa-pause')

  switchTimeDisplay: =>
    @options.timeMode = if @options.timeMode == 'countup'
      'countdown'
    else
      'countup'

    @updateTime()

  # used to determine the width of bars for
  # current playtime and loaded data indicator
  timeRailFactor: =>
    duration = @player.duration
    @scrubberWidth()/duration

  secondsToHHMMSS: (seconds) ->
    hours   = Math.floor(seconds / 3600)
    minutes = Math.floor((seconds - (hours * 3600)) / 60)
    seconds = seconds - (hours * 3600) - (minutes * 60)

    seconds = seconds.toFixed(0)

    hours = @padNumber(hours)
    minutes = @padNumber(minutes)
    seconds = @padNumber(seconds)

    "#{hours}:#{minutes}:#{seconds}"

  padNumber: (number) ->
    if number < 10
      "0#{number}"
    else
      number

  # event handlers

  updateTime: =>
    time = if @options.timeMode == 'countup'
      prefix = ''
      @player.currentTime
    else
      prefix = '-'
      @player.duration - @player.currentTime

    timeString = @secondsToHHMMSS(time)
    @timeElement.text(prefix + timeString)

    @updateScrubber()

  updateScrubber: () =>
    newWidth = @player.currentTime * @timeRailFactor()
    @scrubberPlayedElement.width(newWidth)

  updateLoaded: (event) =>
    if @player.buffered.length
      newStart = @player.buffered.start(0) * @timeRailFactor()
      newWidth = @player.buffered.end(0) * @timeRailFactor()
      @scrubberLoadedElement.css('margin-left', newStart)
      @scrubberLoadedElement.width(newWidth)

  triggerLoading: =>
    @updateLoaded()
    @scrubberBufferingElement.show()

  triggerPlaying: =>
    @updateLoaded()
    @scrubberBufferingElement.hide()

  triggerLoaded: =>
    @updateLoaded()
    @scrubberBufferingElement.hide()

  triggerError: =>
    @scrubberBufferingElement.hide()

  jumpToPosition: (position) =>
    if @player.duration
      pixelPerSecond = @player.duration/@scrubberWidth()
      newTime = pixelPerSecond * position
      unless newTime == @player.currentTime
        @player.currentTime = newTime

  handleMouseMove: (event) =>
    position = event.pageX - $(event.target).offset().left
    @jumpToPosition(position)

  changePlaySpeed: () =>
    nextRate = @options.playbackRates.indexOf(@options.currentPlaybackRate) + 1
    if nextRate >= @options.playbackRates.length
      nextRate = 0
    @player.playbackRate = @options.currentPlaybackRate = @options.playbackRates[nextRate]
    $(event.target).text("#{@options.currentPlaybackRate}x")

  jumpBackward: (seconds) =>
    seconds = seconds || @options.backwardSeconds
    @player.currentTime = @player.currentTime - seconds

  jumpForward: (seconds) =>
    seconds = seconds || @options.forwardSeconds
    @player.currentTime = @player.currentTime + seconds

  bindButtons: () ->
    @playPauseElement.click =>
      if @player.paused
        @player.play()
      else
        @player.pause()
      @togglePlayState(this)

    @backwardElement.click =>
      @jumpBackward()

    @forwardElement.click =>
      @jumpForward()

    @speedElement.click (event) =>
      @changePlaySpeed()

    @timeElement.click =>
      @switchTimeDisplay()

    # drag&drop on time rail
    $('.rail').on 'mousedown', (event) =>
      @handleMouseMove(event)
      $(this).on 'mousemove', (event) =>
        @handleMouseMove(event)
      $(this).on 'mouseup', (event) =>
        $(this).off('mousemove')
        $(this).off('mouseup')

  bindPlayerEvents: () ->
    $(@player).on('timeupdate', @updateTime)
    #$(@player).on('progress', @triggerLoading)
    $(@player).on('play', @triggerPlaying)
    $(@player).on('playing', @triggerPlaying)
    $(@player).on('seeking', @triggerLoading)
    $(@player).on('seeked', @triggerLoaded)
    $(@player).on('waiting', @triggerLoading)
    $(@player).on('loadeddata', @triggerLoaded)
    $(@player).on('canplay', @triggerLoaded)
    $(@player).on('error', @triggerError)
