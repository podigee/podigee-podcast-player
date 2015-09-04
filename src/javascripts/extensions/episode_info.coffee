$ = require('jquery')
_ = require('lodash')
sightglass = require('sightglass')
rivets = require('rivets')

class EpisodeInfo
  @extension:
    name: 'EpisodeInfo'
    type: 'panel'

  constructor: (@app) ->
    @episode = @app.episode
    return unless @episode

    return unless @episode.description

    @options = _.extend(@defaultOptions, @app.extensionOptions.EpisodeInfo)

    @renderPanel()
    @renderButton()

    @app.renderPanel(this)

  defaultOptions:
    showOnStart: false

  renderButton: =>
    @button = $(@buttonHtml)
    @button.on 'click', =>
      @app.togglePanel(@panel)

  renderPanel: =>
    @panel = $(@panelHtml)
    rivets.bind(@panel, @episode)
    @panel.hide() unless @options.showOnStart

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
