$ = require('jquery')
_ = require('lodash')
sightglass = require('sightglass')
rivets = require('rivets')

class Share
  @extension:
    name: 'Share'
    type: 'panel'

  constructor: (@app) ->
    @episode = @app.episode
    return unless @episode

    return unless @episode.url

    @options = _.extend(@defaultOptions, @app.extensionOptions.Share)

    return if @options.disabled

    @prepareSocialLinks()

    @renderPanel()
    @renderButton()

    @app.renderPanel(this)

  defaultOptions:
    showOnStart: false

  prepareSocialLinks: =>
    url = encodeURI(@episode.url)
    title = encodeURI(@episode.title)
    @episode.shareLinks =
      email: "mailto:?subject=Podcast: #{title}&body=#{url}"
      facebook: "https://www.facebook.com/sharer/sharer.php?u=#{url}&t=#{title}"
      googleplus: "https://plus.google.com/share?url=#{url}"
      twitter: "https://twitter.com/intent/tweet?url=#{url}i&text=#{title}"
      whatsapp: "whatsapp://send?text=#{title}: #{url}"

  renderButton: =>
    @button = $(@buttonHtml)
    @button.on 'click', =>
      @app.togglePanel(@panel)

  renderPanel: =>
    @panel = $(@panelHtml)
    rivets.bind(@panel, @episode)
    @panel.hide() unless @options.showOnStart

    @bindEvents()

  bindEvents: () =>
    @panel.find('.share-copy-url').on 'focus', @copyUrlAction

  copyUrlAction: (event) =>
    event.target.select()

  buttonHtml:
    """
    <button class="fa fa-share-alt episode-share-button" title="Share episode URL"></button>
    """

  panelHtml:
    """
    <div class="share">
      <h1 class="share-title">Share episode</h1>
      <ul class="share-social-links">
        <li><a pp-href="shareLinks.facebook" class="share-link-facebook" target="_blank">Facebook</a></li>
        <li><a pp-href="shareLinks.googleplus" class="share-link-googleplus" target="_blank">Google+</a></li>
        <li><a pp-href="shareLinks.twitter" class="share-link-twitter" target="_blank">Twitter</a></li>
        <li><a pp-href="shareLinks.whatsapp" class="share-link-whatsapp" target="_blank">Whatsapp</a></li>
        <li><a pp-href="shareLinks.email" class="share-link-email" target="_blank">Email</a></li>
      </ul>
      <p>
        <h3>Copy address</h3>
        <input class="share-copy-url" pp-value="url">
      </p>
    </div>
    """

module.exports = Share

