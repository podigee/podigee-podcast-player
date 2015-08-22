$ = require('../../vendor/javascripts/jquery.1.11.0.min.js')
_ = require('../../vendor/javascripts/lodash-3.10.1.js')
MediaElement = require('../../vendor/javascripts/mediaelement.js')
Theme = require('./theme.coffee')
ProgressBar = require('./progress_bar.coffee')
ChromeCast = require('./chromecast.coffee')
ChapterMark = require('./chaptermark.coffee')
Embed = require('./embed.coffee')
Playlist = require('./playlist.coffee')
Feed = require('./feed.coffee')
Utils = require('./utils.coffee')

class PodigeePodcastPlayer
  constructor: (@elemClass) ->
    frameOptions = @getFrameOptions()
    @data = window.parent[frameOptions.configuration]
    @setOptions(@data.playerOptions, frameOptions)
    @getProductionData()
    @getFeed()

    @renderTheme()
    @initAudioPlayer()

  # options

  defaultOptions: {
    currentPlaybackRate: 1
    playbackRates: [1.0, 1.5, 2.0]
    timeMode: 'countup'
    backwardSeconds: 10
    forwardSeconds: 30
    showChaptermarks: false
    showMoreInfo: false
  }

  getFrameOptions: () ->
    Utils.locationToOptions(window.location.search)

  getProductionData: () ->
    self = @
    $.getJSON(@data.productionDataUrl).done (data) =>
      self.productionData = data.data

  getFeed: () ->
    return unless @data.feedUrl

    @feed = new Feed(@data.feedUrl, @playlistElement).fetch()

  setOptions: (options, frameOptions) ->
    @options = $.extend(true, @defaultOptions, options)
    @options = $.extend(true, @options, frameOptions)

  renderTheme: =>
    @theme = new Theme(@elemClass, @data)
    @elem = @theme.render()

  initAudioPlayer: =>
    audioElem = @elem.find('audio')[0]
    new MediaElement(audioElem, {success: (media, elem) =>
      @init(media, elem)
    })

  init: (@player, elem) ->
    @findElements()
    @initProgressBar()
    @bindButtons()
    @bindPlayerEvents()
    @initPlaylist()
    @initChaptermarks()
    @initMoreInfo()
    @initChromeCastSupport()

  initChromeCastSupport: () =>
    window.__onGCastApiAvailable = (loaded, errorInfo) =>
      if loaded
        @chromecast = new ChromeCast(@)
      else
        console.log(errorInfo)

  findElements: ->
    @progressBarElement = @elem.find('.progress-bar')
    @playPauseElement = @elem.find('.play-button')
    @backwardElement = @elem.find('.backward-button')
    @forwardElement = @elem.find('.forward-button')
    @speedElement = @elem.find('.speed-toggle')
    @chaptermarkButtonElement = @elem.find('.chaptermarks-button')
    @chaptermarkElement = @elem.find('.chaptermarks')
    @moreInfoButtonElement = @elem.find('.more-info-button')
    @moreInfoElement = @elem.find('.more-info')
    @playlistButtonElement = @elem.find('.playlist-button')
    @playlistElement = @elem.find('.playlist')

  # initialize elements

  initProgressBar: ->
    @progressBar = new ProgressBar(
      @progressBarElement,
      @player,
      @options.timeMode,
    )

  togglePlayState: (elem) =>
    @playPauseElement.toggleClass('fa-play')
    @playPauseElement.toggleClass('fa-pause')

  # event handlers

  updateTime: () =>
    timeString = @progressBar.updateTime()
    @adjustPlaySpeed(timeString)

  updateLoaded: () =>
    @progressBar.updateLoaded()

  triggerLoading: =>
    @updateLoaded()
    @progressBar.showBuffering()

  triggerPlaying: =>
    @updateLoaded()
    @progressBar.hideBuffering()

  triggerLoaded: =>
    @updateLoaded()
    @progressBar.hideBuffering()

  triggerError: =>
    @progressBar.hideBuffering()

  tempPlayBackSpeed: null
  adjustPlaySpeed: (timeString) =>
    return unless @productionData

    currentTime = @player.currentTime
    item = $.grep @productionData.statistics.music_speech, (item, index) ->
      item.start.indexOf(timeString) != -1

    if item.length
      if item[0].label == 'music'
        unless @options.currentPlaybackRate == 1.0
          @tempPlayBackSpeed = @options.currentPlaybackRate
          @setPlaySpeed(1.0)
      else
        if @tempPlayBackSpeed
          @setPlaySpeed(@tempPlayBackSpeed)
          @tempPlayBackSpeed = null

  changePlaySpeed: () =>
    nextRateIndex = @options.playbackRates.indexOf(@options.currentPlaybackRate) + 1
    if nextRateIndex >= @options.playbackRates.length
      nextRateIndex = 0

    @setPlaySpeed(@options.playbackRates[nextRateIndex])

  setPlaySpeed: (speed) =>
    @player.playbackRate = @options.currentPlaybackRate = speed
    @speedElement.text("#{@options.currentPlaybackRate}x")

  jumpBackward: (seconds) =>
    seconds = seconds || @options.backwardSeconds
    @player.currentTime = @player.currentTime - seconds

  jumpForward: (seconds) =>
    seconds = seconds || @options.forwardSeconds
    @player.currentTime = @player.currentTime + seconds

  bindButtons: () ->
    @playPauseElement.click =>
      if @chromecast
        if @chromecast.paused()
          @chromecast.play()
        else
          @chromecast.pause()
      else
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

  playlistClickCallback: (event) =>
    item = event.data
    @data.title = item.title
    @data.subtitle = item.subtitle
    @data.description = item.description
    @data.playlist.mp3 = item.enclosure

  initPlaylist: =>
    return unless @feed
    self = this

    @feed.promise.done ->
      self.playlist = new Playlist(self.feed.items,
        self.playlistElement, self.playlistClickCallback)

  chapterClickCallback: (event) =>
    time = event.data.start
    @player.currentTime = Utils.hhmmssToSeconds(time)

  initChaptermarks: =>
    return unless @data.chaptermarks.length

    html = $('<ul>')
    @data.chaptermarks.forEach((item, index, array) =>
      chaptermark = new ChapterMark(item, @chapterClickCallback).render()
      html.append(chaptermark)
    )
    @chaptermarkElement.append(html)

    if @options.showChaptermarks
      @showElement(@chaptermarkElement)
    else
      @hideElement(@chaptermarkElement)

    @chaptermarkButtonElement.on 'click', =>
      @toggleElement(@chaptermarkElement)

  initMoreInfo: =>
    if @options.showMoreInfo
      @showElement(@moreInfoElement)
    else
      @hideElement(@moreInfoElement)

    @moreInfoButtonElement.on 'click', =>
      @toggleElement(@moreInfoElement)

  animationOptions: ->
    duration: 300
    step: @sendHeightChange

  showElement: (elem) =>
    elem.show(@animationOptions())

  hideElement: (elem) =>
    elem.hide(@animationOptions())

  toggleElement: (elem) =>
    elem.slideToggle(@animationOptions())

  sendHeightChange: =>
    resizeData = JSON.stringify({
      id: @options.id,
      listenTo: 'resizePlayer',
      height: @elem.height() + 2 * parseInt(@elem.css('padding-top'), 10)
    })
    window.parent.postMessage(resizeData, '*')


unless window.inEmbed
  new Embed()
else
  window.PodigeePodcastPlayer = PodigeePodcastPlayer
