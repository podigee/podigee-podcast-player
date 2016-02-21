$ = require('jquery')
_ = require('lodash')
sightglass = require('sightglass')
rivets = require('rivets')
Uri = require('urijs')

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

    @buildContext()

    @renderPanel()
    @renderButton()
    @attachEvents()

    @app.renderPanel(this)

  defaultOptions:
    showOnStart: false

  shareLinks: =>
    url = encodeURI(@shareUrl())
    title = encodeURI(@episode.title)

    shareLinks =
      email: "mailto:?subject=Podcast: #{title}&body=#{url}"
      facebook: "https://www.facebook.com/sharer/sharer.php?u=#{url}&t=#{title}"
      googleplus: "https://plus.google.com/share?url=#{url}"
      twitter: "https://twitter.com/intent/tweet?url=#{url}i&text=#{title}"
      whatsapp: "whatsapp://send?text=#{title}: #{url}"

  buildContext: =>
    @context ?= {}
    @context.shareLinks = @shareLinks()
    @context.url = @shareUrl()
    @context.currentTime = @app.player.currentTime
    @context.currentTimeInSeconds = @app.player.currentTimeInSeconds
    @context.showUrlWithTime ?= false
    @context.updateContext = @updateContext

  updateContext: =>
    @buildContext()

  shareUrl: =>
    parsed = Uri(@episode.url)
    if @context?.showUrlWithTime
      time = Math.round(@context.currentTimeInSeconds)
      parsed.fragment("t=#{time}")
    else
      @episode.url

  renderButton: =>
    @button = $(@buttonHtml)
    @button.on 'click', =>
      @app.togglePanel(@panel)

  renderPanel: =>
    @panel = $(@panelHtml)
    rivets.bind(@panel, @context)
    @panel.hide() unless @options.showOnStart

    @bindEvents()

  attachEvents: =>
    $(@app.player.media).on('timeupdate', @buildContext)

  bindEvents: () =>
    @panel.find('.share-copy-url').on 'focus', @copyUrlAction
    @panel.find("[name='enable-start-at']").on 'change', @toggleStartAt

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
        <h3>Copy episode link</h3>
        <input class="share-copy-url" pp-value="url">
      </p>
      <p>
        <input type="checkbox" pp-checked="showUrlWithTime" pp-on-change="updateContext">
        Start at
        <input type="text" pp-value="currentTime" disabled>
      </p>
    </div>
    """

module.exports = Share
