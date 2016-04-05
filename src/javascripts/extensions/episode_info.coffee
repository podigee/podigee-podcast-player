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
    @panel = $(@panelHtml)
    rivets.bind(@panel, @episode)
    @panel.hide()

  buttonHtml:
    """
    <button class="fa fa-info episode-info-button" title="Show more info"></button>
    """

  panelHtml:
    """
    <div class="episode-info">
      <h1 class="episode-title">{ title }</h1>
      <p class="episode-subtitle">{ subtitle }</p>
      <p class="episode-description" pp-html="description"></p>
    </div>
    """

module.exports = EpisodeInfo
