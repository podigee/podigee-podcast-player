$ = require('jquery')
_ = require('lodash')
sightglass = require('sightglass')
rivets = require('rivets')

class Download
  @extension:
    name: 'Download'
    type: 'panel'

  constructor: (@app) ->
    @options = _.extend(@defaultOptions, @app.extensionOptions.Download)
    return if @options.disabled

    @episode = @app.episode
    return unless @episode
    return unless @episode.media

    @prepareDownloadLinks()

    @renderPanel()
    @renderButton()

    @app.renderPanel(this)

  defaultOptions:
    showOnStart: false

  prepareDownloadLinks: =>
    @episode.downloadLinks = _.map(@episode.media, (value, key, object)=>
      return unless value
      url = value.replace(/source=\w*/g, 'source=webplayer-download')
      filename= value.substring(value.lastIndexOf('/')+1).split('?')[0]
      newObject =
        cssClass: "download-link download-link-#{key}"
        filename: filename
        type: key
        url: url
      newObject
    )

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
    <button class="fa fa-cloud-download episode-download-button" title="Download episode"></button>
    """

  panelHtml:
    """
    <div class="download">
      <h1 class="download-title">Download episode</h1>
      <div class="download-icon"></div>
      <ul class="download-links">
        <li pp-each-link="downloadLinks">
          <a pp-href="link.url" pp-download="link.filename" pp-class="link.cssClass" target="_blank">{ link.type }</a>
        </li>
      </ul>
    </div>
    """

module.exports = Download

