init = (me) ->

  timeElement = $('.time-played')
  scrubberElement = $('.time-scrubber')
  scrubberPlayedElement = scrubberElement.find('.time-scrubber-played')
  scrubberLoadedElement = scrubberElement.find('.time-scrubber-loaded')
  scrubberBufferingElement = scrubberElement.find('.time-scrubber-buffering')
  scrubberRailElement = scrubberElement.find('.rail')
  scrubberWidth = -> scrubberRailElement.width()
  timeMode = 'countup'
  currentPlaybackRate = 1
  playbackRates = [1.0, 1.5, 2.0]

  initLoadingAnimation = ->
    elem = scrubberElement.find('.time-scrubber-buffering')
    bar = $('<div>').addClass('time-scrubber-buffering-bar')
    line = $('<div>').addClass('time-scrubber-buffering-line')

    # render 3 lines per 100px of bar length
    numberOfLines = elem.width() / 100 * 3
    for i in [0..numberOfLines]
      bar.append(line.clone())

    elem.append(bar)

  initScrubber = ->
    newWidth = scrubberElement.width() - timeElement.width()
    scrubberRailElement.width(newWidth)
    initLoadingAnimation()

  initScrubber()

  updateTime = ->
    time = if timeMode == 'countup'
      prefix = ''
      me.currentTime
    else
      prefix = '-'
      me.duration - me.currentTime

    timeString = secondsToHHMMSS(time)
    timeElement.text(prefix + timeString)

    updateScrubber()

  switchTimeDisplay = ->
    if timeMode == 'countup'
      timeMode = 'countdown'
    else
      timeMode = 'countup'

  secondsToHHMMSS = (seconds) ->
      hours   = Math.floor(seconds / 3600)
      minutes = Math.floor((seconds - (hours * 3600)) / 60)
      seconds = seconds - (hours * 3600) - (minutes * 60)

      seconds = seconds.toFixed(0)

      if hours < 10
        hours = "0#{hours}"
      if minutes < 10
        minutes = "0#{minutes}"
      if seconds < 10
        seconds = "0#{seconds}"

      "#{hours}:#{minutes}:#{seconds}"

  timeRailFactor = ->
    duration = me.duration
    scrubberWidth()/duration

  updateScrubber = () ->
    newWidth = me.currentTime * timeRailFactor()
    scrubberPlayedElement.width(newWidth)

  updateLoaded = (event) ->
    if me.buffered.length
      newStart = me.buffered.start(0) * timeRailFactor()
      newWidth = me.buffered.end(0) * timeRailFactor()
      scrubberLoadedElement.css('margin-left', newStart)
      scrubberLoadedElement.width(newWidth)

  triggerLoading = ->
    updateLoaded()
    scrubberBufferingElement.show()

  triggerPlaying = ->
    updateLoaded()
    scrubberBufferingElement.hide()

  triggerLoaded = ->
    updateLoaded()
    scrubberBufferingElement.hide()

  triggerError = ->
    scrubberBufferingElement.hide()

  $(me).on('timeupdate', updateTime)
  #$(me).on('progress', triggerLoading)
  $(me).on('play', triggerPlaying)
  $(me).on('playing', triggerPlaying)
  $(me).on('seeking', triggerLoading)
  $(me).on('seeked', triggerLoaded)
  $(me).on('waiting', triggerLoading)
  $(me).on('loadeddata', triggerLoaded)
  $(me).on('canplay', triggerLoaded)
  $(me).on('error', triggerError)

  togglePlayState = (elem)->
    $(elem).toggleClass('fa-play')
    $(elem).toggleClass('fa-pause')

  $('.play').click ->
    unless me.paused
      me.pause()
    else
      me.play()

    togglePlayState(this)

  $('.backward').click ->
    me.currentTime = me.currentTime - 10

  $('.forward').click ->
    me.currentTime = me.currentTime + 30

  $('.speed').click ->
    nextRate = playbackRates.indexOf(currentPlaybackRate) + 1
    if nextRate >= playbackRates.length
      nextRate = 0
    me.playbackRate = currentPlaybackRate = playbackRates[nextRate]
    $(this).text("#{currentPlaybackRate}x")

  $('.time-played').click ->
    switchTimeDisplay()

  jumpToPosition = (position) ->
    if me.duration
      pixelPerSecond = me.duration/scrubberWidth()
      newTime = pixelPerSecond * position
      unless newTime == me.currentTime
        me.currentTime = newTime

  handleMouseMove = (event) ->
    position = event.pageX - $(event.target).offset().left
    jumpToPosition(position)

  $('.rail').on 'mousedown', (event) ->
    handleMouseMove(event)

    $(this).on 'mousemove', (event) ->
      handleMouseMove(event)

    $(this).on 'mouseup', (event) ->
      $(this).off('mousemove')

me = new MediaElement('player', {success: (media, elem) ->
  window.init(media)
})

