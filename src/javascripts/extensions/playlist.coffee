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
    item = event.data
    @app.episode.title = item.title
    @app.episode.subtitle = item.subtitle
    @app.episode.description = item.description
    @app.episode.media.mp3 = item.enclosure
    @app.episode.media.m4a = null
    @app.episode.media.ogg = null
    @app.episode.media.opus = null
    @app.episode.url = item.link

    @app.episode.transcript = null
    @app.episode.chaptermarks = null

    @app.initializeExtensions()

  renderPanel: =>
    @panel = $(@panelHtml)

    list = @panel.find('ul')
    $(@feed.items).each (index, feedItem) =>
      playlistItem = new PlaylistItem(feedItem, @click).render()
      list.append(playlistItem)

    @panel.hide()

  buttonHtml:
    """
    <button class="fa fa-list playlist-button" title="Show playlist"></button>
    """

  panelHtml:
    """
    <div class="playlist">
      <h3>Playlist</h3>

      <ul></ul>
    </div>
    """

module.exports = Playlist
