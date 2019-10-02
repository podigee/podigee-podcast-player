$ = require('jquery')
_ = require('lodash')
sightglass = require('sightglass')
rivets = require('rivets')

Extension = require('../extension.coffee')

PlaylistItem = require('./playlist/playlist_item.coffee')
PlaylistLoader = require('./playlist/playlist_loader.coffee')

class Playlist extends Extension
  @extension:
    name: 'Playlist'
    type: 'panel'

  constructor: (@app) ->
    @options = _.extend(@defaultOptions, @app.extensionOptions.Playlist)
    return if @options.disabled

    unless @app.podcast.hasEpisodes()
      @app.theme.skipBackwardElement.hide()
      @app.theme.skipForwardElement.hide()
      return

    if @app.podcast.episodes.length
      @finishLoading()
    else
      @app.playlistLoader = new PlaylistLoader(@app)
      @app.playlistLoader = new PlaylistLoader(@app)
      @app.playlistLoader.loadEpisodes().done(@finishLoading)

  finishLoading: () =>
    @episodes = @app.podcast.episodes
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
    if current
      cleanedCurrent = @cleanFile(current)
      @currentEpisode = _.find @playlist, (episode) =>
        episode.deactivate()
        filteredMedia = _.filter episode.media, (file) =>
          cleanedFile = @cleanFile(file)
          cleanedCurrent == cleanedFile
        filteredMedia.length
    else
      @currentEpisode = @playlist[0]
    if @currentEpisode
      @currentEpisode.activate()
      @setSkippingAvailability()

  cleanFile: (file) ->
    file = file.split('?')[0]
    file = file.split('.')
    file.pop()
    file.join('.')

  click: (event) =>
    if @currentEpisode && event.data == @currentEpisode.feedItem
      @app.player.playPause()
    else
      @app.switchEpisode(event.data)

  playPrevious: () =>
    return if @isFirstEntry()

    prevItem = @playlist[@currentIndex() + 1]
    @app.switchEpisode(prevItem.episode)

  playNext: () =>
    return if @isLastEntry()

    nextItem = @playlist[@currentIndex() - 1]
    @app.switchEpisode(nextItem.episode)

  isFirstEntry: () =>
    (@currentIndex() + 1) > @playlist.length

  isLastEntry: () =>
    @currentIndex() == 0

  setSkippingAvailability: () =>
    @app.theme.skipBackwardElement.removeClass('disabled')
    @app.theme.skipForwardElement.removeClass('disabled')
    if @isLastEntry()
      @app.theme.skipForwardElement.addClass('disabled')
    if @isFirstEntry()
      @app.theme.skipBackwardElement.addClass('disabled')

  loadMoreEpisodes: () =>
    @app.playlistLoader.loadNextPage().done (data) =>
      if data.episodes.length == 0
        @panel.find('button.load-more').hide()
      else
        @renderPlaylistItems(data.episodes)

  buildPlaylistItem: (episode, index) =>
    playlistItem = new PlaylistItem(episode, @click)
    @playlist.push(playlistItem)
    playlistItem

  renderPlaylistItems: (episodes) =>
    list = @panel.find('ul')
    items = _.map episodes, @buildPlaylistItem
    _.each items, (item) => list.append(item.render())
    list.scrollTop(100000)

  renderPanel: =>
    @panel = $(@panelHtml())

    @renderPlaylistItems(@episodes)

    loadMoreButton = @panel.find('button.load-more')
    if @app.podcast.playlistUrl?
      loadMoreButton.on('click', @loadMoreEpisodes)
    else
      loadMoreButton.hide()
    @panel.hide()

  buttonHtml: ->
    """
    <button class="playlist-button" title="#{@t('playlist.show')}" aria-label="#{@t('playlist.show')}"></button>
    """

  panelHtml: ->
    """
    <div class="playlist">
      <h3>#{@t('playlist.title')}</h3>

      <ul></ul>

      <div class="buttons">
        <button class="load-more">#{@t('playlist.load_more')}</button>
      </div>
    </div>
    """

module.exports = Playlist
