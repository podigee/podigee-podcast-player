$ = require('../../../vendor/javascripts/jquery.1.11.0.min.js')
sightglass = require('../../../vendor/javascripts/sightglass.js')
rivets = require('../../../vendor/javascripts/rivets.min.js')

class EpisodeInfo
  constructor: (@app) ->
    @episode = @app.episode
    return unless @episode

    @renderPanel()
    @renderButton()

    @app.renderPanel(this)

  renderButton: =>
    @button = $(@buttonHtml)
    @button.on 'click', =>
      @app.togglePanel(@panel)

  renderPanel: =>
    @panel = $(@panelHtml)
    rivets.bind(@panel, @episode)
    @panel.hide()

  buttonHtml:
    """
    <i class="fa fa-info episode-info-button" title="Show more info"></i>
    """

  panelHtml:
    """
    <div class="episode-info">
      <h1 class="episode-title">{ title }</h1>
      <p class="episode-subtitle">{ subtitle }</p>
      <p class="episode-description">{ description }</p>
    </div>
    """

module.exports = EpisodeInfo
