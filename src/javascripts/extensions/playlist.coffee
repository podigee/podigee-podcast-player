$ = require('jquery')
_ = require('lodash')
sightglass = require('sightglass')
rivets = require('rivets')

Utils = require('../utils.coffee')
Extension = require('../extension.coffee')

class PlaylistItem
  constructor: (@episode, @callback) ->
    @media = @context().media
    if @episode.duration
      @humanDuration = Utils.secondsToHHMMSS(_.clone(@episode.duration))

  humanDuration: null
  active: false
  context: () ->
    _.merge(@episode, {
      active: @active,
      humanDuration: @humanDuration
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
      <a class="episode-link" pp-if="url" pp-href="url" target="_blank">
        <svg id="icon-chain" viewBox="0 0 26 28">
          <title>chain</title>
          <path d="M22.75 19c0-0.406-0.156-0.781-0.438-1.062l-3.25-3.25c-0.281-0.281-0.672-0.438-1.062-0.438-0.453 0-0.812 0.172-1.125 0.5 0.516 0.516 1.125 0.953 1.125 1.75 0 0.828-0.672 1.5-1.5 1.5-0.797 0-1.234-0.609-1.75-1.125-0.328 0.313-0.516 0.672-0.516 1.141 0 0.391 0.156 0.781 0.438 1.062l3.219 3.234c0.281 0.281 0.672 0.422 1.062 0.422s0.781-0.141 1.062-0.406l2.297-2.281c0.281-0.281 0.438-0.656 0.438-1.047zM11.766 7.984c0-0.391-0.156-0.781-0.438-1.062l-3.219-3.234c-0.281-0.281-0.672-0.438-1.062-0.438s-0.781 0.156-1.062 0.422l-2.297 2.281c-0.281 0.281-0.438 0.656-0.438 1.047 0 0.406 0.156 0.781 0.438 1.062l3.25 3.25c0.281 0.281 0.672 0.422 1.062 0.422 0.453 0 0.812-0.156 1.125-0.484-0.516-0.516-1.125-0.953-1.125-1.75 0-0.828 0.672-1.5 1.5-1.5 0.797 0 1.234 0.609 1.75 1.125 0.328-0.313 0.516-0.672 0.516-1.141zM25.75 19c0 1.188-0.484 2.344-1.328 3.172l-2.297 2.281c-0.844 0.844-1.984 1.297-3.172 1.297-1.203 0-2.344-0.469-3.187-1.328l-3.219-3.234c-0.844-0.844-1.297-1.984-1.297-3.172 0-1.234 0.5-2.406 1.375-3.266l-1.375-1.375c-0.859 0.875-2.016 1.375-3.25 1.375-1.188 0-2.344-0.469-3.187-1.313l-3.25-3.25c-0.859-0.859-1.313-1.984-1.313-3.187 0-1.188 0.484-2.344 1.328-3.172l2.297-2.281c0.844-0.844 1.984-1.297 3.172-1.297 1.203 0 2.344 0.469 3.187 1.328l3.219 3.234c0.844 0.844 1.297 1.984 1.297 3.172 0 1.234-0.5 2.406-1.375 3.266l1.375 1.375c0.859-0.875 2.016-1.375 3.25-1.375 1.188 0 2.344 0.469 3.187 1.313l3.25 3.25c0.859 0.859 1.313 1.984 1.313 3.187z"></path>
        </svg>
      </a>
      <span class="playlist-episode-number" pp-if="number">{ number }.</span>
      <span class="playlist-episode-title" pp-html="title"></span>
      <span class="playlist-episode-duration" pp-if="humanDuration">{ humanDuration }</span>
    </li>
    """

class Playlist extends Extension
  @extension:
    name: 'Playlist'
    type: 'panel'

  constructor: (@app) ->
    @options = _.extend(@defaultOptions, @app.extensionOptions.Playlist)
    return if @options.disabled

    return unless @app.podcast.hasEpisodes()

    @app.podcast.getEpisodes().done =>
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
      @playItem(event.data)

  playItem: (episode) =>
    @updateEpisodeData(episode)
    @app.player.loadFile()
    @app.player.play()
    @app.initializeExtensions(this)
    @app.extensions.ProgressBar.updateView()

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
    @panel = $(@panelHtml())

    list = @panel.find('ul')
    _.each @episodes, (episode, index) =>
      playlistItem = new PlaylistItem(episode, @click)
      @playlist.push(playlistItem)
      list.append(playlistItem.render())

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
    </div>
    """

module.exports = Playlist
