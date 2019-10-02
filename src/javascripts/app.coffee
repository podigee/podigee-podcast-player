$ = require('jquery')
_ = require('lodash')

Configuration = require('./configuration.coffee')
Theme = require('./theme.coffee')
Player = require('./player.coffee')
ProgressBar = require('./progress_bar.coffee')
Feed = require('./feed.coffee')
ExternalData = require('./external_data.coffee')

ChapterMarks = require('./extensions/chaptermarks.coffee')
Download = require('./extensions/download.coffee')
EpisodeInfo = require('./extensions/episode_info.coffee')
Playlist = require('./extensions/playlist.coffee')
Playerjs = require('./extensions/playerjs.coffee')
Share = require('./extensions/share.coffee')
Transcript = require('./extensions/transcript.coffee')

class PodigeePodcastPlayer
  @defaultExtensions: [
    ProgressBar,
    ChapterMarks,
    Download,
    EpisodeInfo,
    Share,
    Playlist,
    Playerjs,
    Transcript,
  ]

  constructor: (@elemClass) ->
    @version = window.VERSION
    @initConfiguration().loaded.done =>
      @renderTheme().done =>
        @initPlayer()

  extensions: {}

  # at the moment only 'subscribeIntent'
  listener: {}

  addEventListener: (kind, callback) ->
    existingListeners = @listener[kind]
    if (!existingListeners)
      @listener[kind] = []

    @listener[kind].push(callback)

  emit: (kind, payload) =>
    callbacks = @listener[kind]
    return false unless callbacks or callbacks.length == 0

    callbacks.forEach (cb) => cb?(payload)

  getProductionData: () ->
    return unless @episode.productionDataUrl

    self = @
    $.getJSON(@episode.productionDataUrl).done (data) =>
      self.episode.productionData = data.data

  initConfiguration: (configurationUrl) ->
    @configuration = new Configuration(this, configurationUrl)

  renderTheme: =>
    rendered = $.Deferred()
    @theme = new Theme(this)
    @theme.loaded.done =>
      @elem = @theme.render()
      window.setTimeout @sendSizeChange, 0
      $('.loading-animation').remove()
      rendered.resolve()

    rendered.promise()

  initPlayer: =>
    mediaElem = @elem.find('audio')[0]
    new Player(this, mediaElem, @options, @init)

  init: (player) =>
    @player = player
    @bindButtons()
    @initializeExtensions()
    @bindWindowResizing()

  switchEpisode: (episode, activeExtension) =>
    @episode = episode
    @theme.updateView()

    @player.loadFile()
    @player.setCurrentTime(0)
    @player.play()
    @initializeExtensions(activeExtension)
    @extensions.ProgressBar.updateView()

  mediaLoaded: =>
    window.setTimeout @sendSizeChange, 0
    @theme.removeLoadingClass()

  mediaLoadError: =>
    window.setTimeout @sendSizeChange, 0
    @theme.removeLoadingClass()
    @theme.removePlayingClass()
    @theme.addFailedLoadingClass()
    @extensions.ProgressBar.hideBuffering()

  # initialize elements

  togglePlayState: () =>
    return unless @player?
    if @player.playing
      @theme.addPlayingClass()
    else
      @theme.removePlayingClass()

  updateTime: (timeInSeconds) =>
    timeString = @extensions.ProgressBar.updateTime(timeInSeconds)
    @adjustPlaySpeed(timeString)

  mediaEnded: =>
    @player.media.currentTime = 0
    @extensions.ProgressBar.updateTime()
    @theme.removePlayingClass()

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
    triggerPlayPause = (event) =>
      event.preventDefault()
      if @extensions.ChromeCast && @extensions.ChromeCast.active
        @extensions.ChromeCast.togglePlayState()
      else
        @player.playPause()
    @theme.playPauseElement.on 'click', triggerPlayPause

    @theme.backwardElement.click =>
      @player.jumpBackward()

    @theme.forwardElement.click =>
      @player.jumpForward()

    @theme.skipBackwardElement.click =>
      @player.skipBackward()

    @theme.skipForwardElement.click =>
      @player.skipForward()

    @theme.speedElement.click (event) =>
      @player.changePlaySpeed()
      @updateSpeedDisplay()

  updateSpeedDisplay: () ->
    @theme.speedElement.text("#{@options.currentPlaybackRate}x")

  initializeExtensions: (currentlyActiveExtension) =>
    self = this
    Object.keys(@extensions).forEach (name) =>
      @extensions[name].destroy()

    @extensions = {}
    @theme.removeButtons()
    @theme.removePanels()
    PodigeePodcastPlayer.defaultExtensions.forEach (extension) =>
      name = extension.extension.name
      self.extensions[name] = new extension(self)
      return if self.options.startPanels && self.options.startPanels.length
      if currentlyActiveExtension instanceof extension
        self.theme.togglePanel(self.extensions[name].panel)

  bindWindowResizing: =>
    $(window).on('resize', _.debounce(@sendSizeChange, 250))

  sendSizeChange: =>
    paddingTop = parseInt(@elem.css('padding-top'), 10)
    paddingBottom = parseInt(@elem.css('padding-bottom'), 10)
    newHeight = @elem.height() + paddingTop + paddingBottom
    resizeData = JSON.stringify({
      id: @options.id,
      listenTo: 'resizePlayer',
      height: newHeight
    })
    window.parent.postMessage(resizeData, '*')

    @extensions.ProgressBar?.updateBarWidths()

  isInMultiPanelMode: ->
    @options.startPanels && @options.startPanels.length

  isInIframeMode: ->
    @options.iframeMode == 'iframe'

  isInAMPMode: ->
    @options.amp == true

if window.inEmbed
  window.PodigeePodcastPlayer = PodigeePodcastPlayer
