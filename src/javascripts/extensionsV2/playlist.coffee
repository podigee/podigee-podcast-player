$ = require('jquery')

Playlist = require('../extensions/playlist.coffee')
PlaylistItem = require('./playlist/playlist_item.coffee')

class PlaylistV2 extends Playlist
  constructor: (app) ->
    super(app)
    if @options.disabled and @app.podcast.hasEpisodes()
      @loadExtension()
    @attachEvents()

  attachEvents: =>
    $(@app.player.media).on('loadedmetadata', @onPlay)

  click: (event) =>
    @app.theme.showPlayer()
    @app.switchEpisode(event.data, @app.extensions.Playlist)

  onPlay: =>
    @app.theme.skipBackwardElement.prop('disabled', false)
    @app.theme.skipForwardElement.prop('disabled', false)
    if @isFirstEntry()
      @app.theme.skipBackwardElement.prop('disabled', true)
    if @isLastEntry()
      @app.theme.skipForwardElement.prop('disabled', true)

  buildPlaylistItem: (episode, index) =>
    playlistItem = new PlaylistItem(episode, @click)
    @playlist.push(playlistItem)
    playlistItem

  buttonHtml: =>
    if !@options.disabled
      """
        <button pp-if class="playlist-button" title="#{@t('menu.allEpisodes')}" aria-label="#{@t('menu.allEpisodes')}">#{@t('menu.allEpisodes')}</button>
      """

module.exports = PlaylistV2
