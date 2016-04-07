$ = require('jquery')
_ = require('lodash')

Configuration = require('./configuration.coffee')
Theme = require('./theme.coffee')
Player = require('./player.coffee')
ProgressBar = require('./progress_bar.coffee')
Embed = require('./embed.coffee')
Feed = require('./feed.coffee')
ExternalData = require('./external_data.coffee')

ChapterMarks = require('./extensions/chaptermarks.coffee')
Download = require('./extensions/download.coffee')
EpisodeInfo = require('./extensions/episode_info.coffee')
Playlist = require('./extensions/playlist.coffee')
Share = require('./extensions/share.coffee')
Transcript = require('./extensions/transcript.coffee')

class PodigeePodcastPlayer
  @defaultExtensions: [
    ProgressBar,
    ChapterMarks,
    Download,
    EpisodeInfo,
    Playlist,
    Share,
    Transcript,
  ]

  constructor: (@elemClass) ->
    @getConfiguration().loaded.done =>
      @externalData = new ExternalData(this)
      @renderTheme().done =>
        @initPlayer()

  extensions: {}

  getFeed: () ->
    return unless @podcast.feed

    @podcast.feed = new Feed(this)

  getProductionData: () ->
    return unless @episode.productionDataUrl

    self = @
    $.getJSON(@episode.productionDataUrl).done (data) =>
      self.episode.productionData = data.data

  getConfiguration: () ->
    new Configuration(this)

  renderTheme: =>
    rendered = $.Deferred()
    @theme = new Theme(this)
    @theme.loaded.done =>
      @elem = @theme.render()
      rendered.resolve()

    rendered.promise()

  initPlayer: =>
    mediaElem = @elem.find('audio')[0]
    new Player(this, mediaElem, @options, @init)

  init: (player) =>
    @player = player
    @bindButtons()
    @bindPlayerEvents()
    @initializeExtensions()
    window.setTimeout @sendSizeChange, 0
    @bindWindowResizing()

  # initialize elements

  togglePlayState: () =>
    return unless @player?
    if @player.playing
      @elem.addClass('playing')
      @theme.playPauseElement.addClass('fa-pause').removeClass('fa-play')
    else
      @elem.removeClass('playing')
      @theme.playPauseElement.addClass('fa-play').removeClass('fa-pause')

  # event handlers

  bindPlayerEvents: () ->
    $(@player.media).on('timeupdate', @updateTime)
      .on('ended', @triggerEnded)
      .on('error', @triggerError)

  updateTime: () =>
    timeString = @extensions.ProgressBar.updateTime()
    @adjustPlaySpeed(timeString)

  triggerEnded: =>
    @player.media.currentTime = 0
    @extensions.ProgressBar.updateTime()
    @togglePlayState()

  triggerError: =>
    @extensions.ProgressBar.hideBuffering()

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
      if @extensions.ChromeCast && @extensions.ChromeCast.active
        @extensions.ChromeCast.togglePlayState()
      else
        @player.playPause()

    @theme.backwardElement.click =>
      @player.jumpBackward()

    @theme.forwardElement.click =>
      @player.jumpForward()

    @theme.speedElement.click (event) =>
      @player.changePlaySpeed()
      @updateSpeedDisplay()

  updateSpeedDisplay: () ->
    @theme.speedElement.text("#{@options.currentPlaybackRate}x")

  initializeExtensions: () =>
    self = this
    @extensions = {}
    @theme.removeButtons()
    @theme.removePanels()
    PodigeePodcastPlayer.defaultExtensions.forEach (extension) =>
      self.extensions[extension.extension.name] = new extension(self)

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

  isInIframeMode: ->
    @options.iframeMode == 'iframe'

unless window.inEmbed
  new Embed()
else
  window.PodigeePodcastPlayer = PodigeePodcastPlayer
