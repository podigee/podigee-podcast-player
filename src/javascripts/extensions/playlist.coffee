$ = require('jquery')
_ = require('lodash')
sightglass = require('sightglass')
rivets = require('rivets')

Extension = require('../extension.coffee')

class PlaylistItem
  constructor: (context, callback) ->
    @context = context
    @callback = callback

  render: =>
    @elem = $(@defaultHtml)
    rivets.bind(@elem, @context)

    @elem.data('item', @context)
    @elem.on('click', @context, @callback)

    return @elem

  defaultHtml:
    """
    <li>
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

  defaultOptions:
    showOnStart: false
    disabled: false

  click: (event) =>
    @updateEpisodeData(event.data)

    @app.initializeExtensions()
    @app.player.loadFile()

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
      playlistItem = new PlaylistItem(feedItem, @click).render()
      list.append(playlistItem)

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
