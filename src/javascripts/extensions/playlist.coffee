$ = require('jquery')
_ = require('lodash')
sightglass = require('sightglass')
rivets = require('rivets')

Extension = require('../extension.coffee')

class PlaylistItem
  constructor: (feedItem, callback) ->
    @feedItem = feedItem
    @media = @context().media
    @callback = callback

  active: false
  context: () ->
    _.merge(@feedItem, {
      active: @active,
    })

  activate: ->
    return if @active
    @active = true
    @view.update(@context())

  deactivate: ->
    return unless @active
    @active = false
    @view.update(@context())

  render: =>
    @elem = $(@defaultHtml)
    @view = rivets.bind(@elem, @context())

    @elem.data('item', @context())
    @elem.on('click', @context(), @callback)

    return @elem

  defaultHtml:
    """
    <li pp-class-active="active">
      <a pp-if="href" pp-href="href" target="_blank"><i class="fa fa-link"></i></a>
      <span>{ title }</span>
    </li>
    """

class Playlist extends Extension
  @extension:
    name: 'Playlist'
    type: 'panel'

  constructor: (@app) ->
    @options = _.extend(@defaultOptions, @app.extensionOptions.Playlist)
    return if @options.disabled

    @feed = @app.getFeed()
    return unless @feed

    @feed.promise.done =>
      @renderPanel()
      @renderButton()

      @app.theme.addExtension(this)
      @setCurrentEpisode()

  defaultOptions:
    showOnStart: false
    disabled: false

  playlist: []

  currentEpisode: null
  currentIndex: => @playlist.indexOf(@currentEpisode)
  setCurrentEpisode: () =>
    current = @app.player.currentFile()
    cleanedCurrent = @cleanFile(current)
    @currentEpisode = _.find @playlist, (item) =>
      item.deactivate()
      filteredMedia = _.filter item.media, (file) =>
        cleanedFile = @cleanFile(file)
        cleanedCurrent == cleanedFile
      filteredMedia.length
    @currentEpisode.activate()

  cleanFile: (file) ->
    file = file.split('?')[0]
    file = file.split('.')
    file.pop()
    file.join('.')

  click: (event) =>
    if event.data == @currentEpisode.feedItem
      @app.player.playPause()
    else
      @playItem(event.data)

  playItem: (item) =>
    @updateEpisodeData(item)
    @app.player.loadFile()
    @app.player.play()
    @app.initializeExtensions()

  playPrevious: () =>
    prevItem = @playlist[@currentIndex() + 1]
    @playItem(prevItem.feedItem)

  playNext: () =>
    nextItem = @playlist[@currentIndex() - 1]
    @playItem(nextItem.feedItem)

  updateEpisodeData: (feedItem) ->
    @app.episode.title = feedItem.title
    @app.episode.subtitle = feedItem.subtitle
    @app.episode.description = feedItem.description
    @app.episode.media =
      mp3: feedItem.enclosure.mp3
      m4a: feedItem.enclosure.m4a
      ogg: feedItem.enclosure.ogg
      opus: feedItem.enclosure.opus
    @app.episode.url = feedItem.href
    @app.episode.transcript = null
    @app.episode.chaptermarks = null

    @app.theme.updateView()

  renderPanel: =>
    @panel = $(@panelHtml)

    list = @panel.find('ul')
    _.each @feed.items, (feedItem, index) =>
      playlistItem = new PlaylistItem(feedItem, @click)
      @playlist.push(playlistItem)
      list.append(playlistItem.render())

    @panel.hide()

  buttonHtml:
    """
    <button class="playlist-button" title="Show playlist"></button>
    """

  panelHtml:
    """
    <div class="playlist">
      <h3>Playlist</h3>

      <ul></ul>
    </div>
    """

module.exports = Playlist
