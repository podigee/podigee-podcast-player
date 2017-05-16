$ = require('jquery')
_ = require('lodash')
sightglass = require('sightglass')
rivets = require('rivets')

Utils = require('../utils.coffee')
Extension = require('../extension.coffee')

class PlaylistItem
  constructor: (@episode, @callback) ->
    @media = @context().media

  active: false
  context: () ->
    _.merge(@episode, {
      active: @active,
      humanDuration: Utils.secondsToHHMMSS(_.clone(@episode.duration))
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
    @elem.on('click', @episode, @callback)

    return @elem

  defaultHtml:
    """
    <li pp-class-active="active">
      <a class="episode-link" pp-if="url" pp-href="url" target="_blank"><i class="fa fa-link"></i></a>
      <span class="playlist-episode-number" pp-if="number">{ number }.</span>
      <span class="playlist-episode-title" pp-html="title"></span>
      <span class="playlist-episode-duration">{ humanDuration }</span>
    </li>
    """

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

    @app.podcast.getEpisodes().done =>
      @episodes = @app.podcast.episodes
      @renderPanel()
      @renderButton()

      @app.theme.addExtension(this)
      $(@app.player.media).on 'loadedmetadata', @setCurrentEpisode

  defaultOptions:
    showOnStart: false
    disabled: false

  playlist: []

  currentEpisode: null
  currentIndex: => @playlist.indexOf(@currentEpisode)
  setCurrentEpisode: () =>
    current = @app.player.currentFile()
    cleanedCurrent = @cleanFile(current)
    @currentEpisode = _.find @playlist, (episode) =>
      episode.deactivate()
      filteredMedia = _.filter episode.media, (file) =>
        cleanedFile = @cleanFile(file)
        cleanedCurrent == cleanedFile
      filteredMedia.length
    @currentEpisode.activate()
    @setSkippingAvailability()

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

  playItem: (episode) =>
    @updateEpisodeData(episode)
    @app.player.loadFile()
    @app.player.play()
    @app.initializeExtensions(this)

  playPrevious: () =>
    return if @isFirstEntry()

    prevItem = @playlist[@currentIndex() + 1]
    @playItem(prevItem.episode)

  playNext: () =>
    return if @isLastEntry()

    nextItem = @playlist[@currentIndex() - 1]
    @playItem(nextItem.episode)

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

  updateEpisodeData: (episode) ->
    @app.episode = episode

    @app.theme.updateView()

  renderPanel: =>
    @panel = $(@panelHtml)

    list = @panel.find('ul')
    _.each @episodes, (episode, index) =>
      playlistItem = new PlaylistItem(episode, @click)
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
