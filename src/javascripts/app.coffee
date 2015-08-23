$ = require('../../vendor/javascripts/jquery.1.11.0.min.js')
_ = require('../../vendor/javascripts/lodash-3.10.1.js')
Theme = require('./theme.coffee')
Player = require('./player.coffee')
ProgressBar = require('./progress_bar.coffee')
ChromeCast = require('./chromecast.coffee')
ChapterMarks = require('./chaptermarks.coffee')
Embed = require('./embed.coffee')
Playlist = require('./playlist.coffee')
Feed = require('./feed.coffee')
Utils = require('./utils.coffee')

class PodigeePodcastPlayer
  constructor: (@elemClass) ->
    @getConfiguration()

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

  getFeed: () ->
    return unless @podcast.feedUrl

    @feed = new Feed(@podcast.feedUrl)

  getProductionData: () ->
    return unless @episode.productionDataUrl

    self = @
    $.getJSON(@episode.productionDataUrl).done (data) =>
      self.episode.productionData = data.data

  getConfiguration: () ->
    frameOptions = Utils.locationToOptions(window.location.search)
    configuration = window.parent[frameOptions.configuration]

    @podcast = configuration.podcast
    @getFeed()

    @episode = configuration.episode
    @getProductionData()

    @options = _.extend(@defaultOptions, configuration.options, frameOptions)

  renderTheme: =>
    @theme = new Theme(@elemClass, @episode)
    @elem = @theme.render()

  initPlayer: =>
    mediaElem = @elem.find('audio')[0]
    new Player(mediaElem, @options, @init)

  init: (player) =>
    @player = player
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

  # initialize elements

  initProgressBar: ->
    @progressBar = new ProgressBar(
      @theme.progressBarElement,
      @player.media,
      @options.timeMode,
    )

  togglePlayState: (elem) =>
    @theme.playPauseElement.toggleClass('fa-play')
    @theme.playPauseElement.toggleClass('fa-pause')

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
    return unless @episode.productionData

    currentTime = @player.media.currentTime
    item = $.grep @episode.productionData.statistics.music_speech, (item, index) ->
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
    @theme.playPauseElement.click =>
      if @chromecast
        @chromecast.togglePlayState()
      else
        if @player.media.paused
          @player.media.play()
        else
          @player.media.pause()
      @togglePlayState(this)

    @theme.backwardElement.click =>
      @player.jumpBackward()

    @theme.forwardElement.click =>
      @player.jumpForward()

    @theme.speedElement.click (event) =>
      @player.changePlaySpeed()
      @updateSpeedDisplay()

  updateSpeedDisplay: () ->
    @theme.speedElement.text("#{@options.currentPlaybackRate}x")

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
        self.theme.playlistElement, self.playlistClickCallback)

  chapterClickCallback: (event) =>
    time = event.data.start
    @player.media.currentTime = Utils.hhmmssToSeconds(time)

  initChaptermarks: =>
    chaptermarks = new ChapterMarks(
      @episode.chaptermarks,
      @theme.chaptermarksElement,
      @chapterClickCallback)

    @theme.chaptermarksButtonElement.on 'click', =>
      @toggleElement(chaptermarks.elem)

  initMoreInfo: =>
    @theme.moreInfoButtonElement.on 'click', =>
      @toggleElement(@theme.moreInfoElement)

  animationOptions: ->
    duration: 300
    step: @sendHeightChange

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
