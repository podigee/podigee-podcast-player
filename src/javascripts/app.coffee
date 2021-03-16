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

ChapterMarksV2 = require('./extensionsV2/chaptermarks.coffee')
EpisodeInfoV2 = require('./extensionsV2/episode_info.coffee')
PlaylistV2 = require('./extensionsV2/playlist.coffee')
TranscriptV2 = require('./extensionsV2/transcript.coffee')
ExtraOptionsV2 = require('./extensionsV2/extra_options.coffee')
ShareV2 = require('./extensionsV2/share.coffee')
SubscribeV2 = require('./extensionsV2/subscribe.coffee')

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

  @defaultExtensionsV2: [
    ProgressBar,
    Playerjs,
    SubscribeV2,
    ShareV2,
    ExtraOptionsV2,
    ChapterMarksV2,
    EpisodeInfoV2,
    PlaylistV2,
    TranscriptV2,
  ]

  constructor: (@elemClass, configuration, origin) ->
    @version = window.VERSION
    @origin = origin
    @initConfiguration(undefined, configuration).loaded.done =>
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

  initConfiguration: (configurationUrl, configuration) ->
    @configuration = new Configuration(this, configurationUrl, configuration)

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

  ## Redesigned theme extras start -->
  switchEpisodeNoUpdate: (episode, activeExtension) =>
    @episode = episode

    @player.loadFile()
    @player.setCurrentTime(0)
    @player.play()
  ## Redesigned theme extras end <--

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

    @theme.speedSelectElement.change (event) =>
      newSpeed = parseFloat(event.target.value)
      @player.changePlaySpeed(newSpeed)
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

    defaultExtensions = PodigeePodcastPlayer.defaultExtensions
    if @options.themeVersion == 2
      defaultExtensions = PodigeePodcastPlayer.defaultExtensionsV2
    defaultExtensions.forEach (extension) =>
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

module.exports = PodigeePodcastPlayer
