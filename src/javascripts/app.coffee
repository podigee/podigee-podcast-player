$ = require('../../vendor/javascripts/jquery.1.11.0.min.js')
Theme = require('./theme.coffee')
Player = require('./player.coffee')
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
    @initPlayer()

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
      self.data.productionData = data.data

  getFeed: () ->
    return unless @data.feedUrl

    @feed = new Feed(@data.feedUrl, @playlistElement).fetch()

  setOptions: (options, frameOptions) ->
    @options = $.extend(true, @defaultOptions, options)
    @options = $.extend(true, @options, frameOptions)

  renderTheme: =>
    @theme = new Theme(@elemClass, @data)
    @elem = @theme.render()

  initPlayer: =>
    mediaElem = @elem.find('audio')[0]
    new Player(mediaElem, @options, @init)

  init: (player) =>
    @player = player
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
      @player.media,
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
    return unless @data.productionData

    currentTime = @player.media.currentTime
    item = $.grep @data.productionData.statistics.music_speech, (item, index) ->
      item.start.indexOf(timeString) != -1

    if item.length
      if item[0].label == 'music'
        unless @options.currentPlaybackRate == 1.0
          @tempPlayBackSpeed = @options.currentPlaybackRate
          @player.setPlaySpeed(1.0)
      else
        if @tempPlayBackSpeed
          @player.setPlaySpeed(@tempPlayBackSpeed)
          @tempPlayBackSpeed = null

    @updateSpeedDisplay()

  bindButtons: () =>
    @playPauseElement.click =>
      if @chromecast
        @chromecast.togglePlayState()
      else
        if @player.media.paused
          @player.media.play()
        else
          @player.media.pause()
      @togglePlayState(this)

    @backwardElement.click =>
      @player.jumpBackward()

    @forwardElement.click =>
      @player.jumpForward()

    @speedElement.click (event) =>
      @player.changePlaySpeed()
      @updateSpeedDisplay()

  updateSpeedDisplay: () ->
    @speedElement.text("#{@options.currentPlaybackRate}x")

  bindPlayerEvents: () ->
    $(@player.media).on('timeupdate', @updateTime)
      .on('play', @triggerPlaying)
      .on('playing', @triggerPlaying)
      .on('seeking', @triggerLoading)
      .on('seeked', @triggerLoaded)
      .on('waiting', @triggerLoading)
      .on('loadeddata', @triggerLoaded)
      .on('canplay', @triggerLoaded)
      .on('error', @triggerError)
      #.on('progress', @triggerLoading)

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
    @player.media.currentTime = Utils.hhmmssToSeconds(time)

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
