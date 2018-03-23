$ = require('jquery')
_ = require('lodash')
sightglass = require('sightglass')
rivets = require('rivets')

Extension = require('../extension.coffee')

class EpisodeInfo extends Extension
  @extension:
    name: 'EpisodeInfo'
    type: 'panel'

  constructor: (@app) ->
    @options = _.extend(@defaultOptions, @app.extensionOptions.EpisodeInfo)
    return if @options.disabled

    @episode = @app.episode
    return unless @episode
    return unless @episode.description

    @renderPanel()
    @renderButton()

    @app.theme.addExtension(this)

  defaultOptions:
    showOnStart: false

  renderPanel: =>
    @panel = $(@panelHtml())
    rivets.bind(@panel, @episode)
    @panel.hide()

  buttonHtml: ->
    """
    <button class="episode-info-button" title="#{@t('episode_info.more_info')}" aria-label="#{@t('episode_info.more_info')}"></button>
    """

  panelHtml: ->
    """
    <div class="episode-info">
      <h3>#{@t('episode_info.title')}</h3>
      <h3 class="episode-title" pp-html="title"></h3>
      <p class="episode-subtitle" pp-html="subtitle"></p>
      <p class="episode-description" pp-html="description"></p>
    </div>
    """

module.exports = EpisodeInfo
