$ = require('jquery')

class ChromeCast
  @extension:
    name: 'ChromeCast'
    type: 'player'

  constructor: (@app) ->
    window.__onGCastApiAvailable = (loaded, errorInfo) =>
      if loaded
        @player = @app.player.media
        @initializeCastApi()
        @renderButton()

        @app.theme.addButton(@button)
      else
        console.debug(errorInfo)

  togglePlayState: () ->
    if @paused() then @play() else @pause()

  #private

  initializeCastApi: () ->
    sessionRequest = new chrome.cast.SessionRequest(
      chrome.cast.media.DEFAULT_MEDIA_RECEIVER_APP_ID)
    apiConfig = new chrome.cast.ApiConfig(sessionRequest,
      @sessionListener, @receiverListener)
    chrome.cast.initialize(apiConfig, @onInitSuccess, @onError)

  onInitSuccess: () =>
    #console.debug('onInitSuccess:', arguments)

  onError: () =>
    #console.debug('onError:', arguments)

  sessionListener: (session) =>
    #console.debug('sessionListener:', arguments)
    @onRequestSessionSuccess(session)

  receiverListener: (event) =>
    #console.debug('receiverListener:', event)

  initializeUI: () =>
    elem = @app.elem.find('.chromecast-ui')

    elem.show()

  renderButton: =>
    @button = $(@buttonHtml)
    @button.on 'click', =>
      @active = true
      chrome.cast.requestSession(@onRequestSessionSuccess, @onLaunchError)

    @castButton = @button.find('.chromecast-button')
    @castReceiver = @button.find('.chromecast-receiver')

  buttonHtml:
    """
    <button class="chromecast-ui">
      <img class="chromecast-button" title="Play on chromecast" src="images/chromcast.png"/>
      <span class="chromecast-receiver"></span>
    </button>
    """

  onRequestSessionSuccess: (event) =>
    @session = event
    @castReceiver.text("Receiver: #{event.receiver.friendlyName}")

    request = new chrome.cast.media.LoadRequest(@buildMediaInfo())
    request.autoplay = false
    @session.loadMedia(request, @onMediaDiscovered.bind(this, 'loadMedia'), @onMediaError)

  buildMediaInfo: () =>
    mediaInfo = new chrome.cast.media.MediaInfo(@player.src, 'audio/mpeg')
    mediaInfo.duration = @player.duration

    metadata = new chrome.cast.media.MusicTrackMediaMetadata()
    image = new chrome.cast.Image(@app.episode.logo_url)
    metadata.title = @app.episode.title
    metadata.images = [image]
    mediaInfo.metadata = metadata

    mediaInfo

  onMediaDiscovered: (how, media) ->
    @currentMedia = media

  play: () ->
    @currentMedia.play(null, @onPlaySuccess, @onPlayError)

  pause: () ->
    @currentMedia.pause(null, @onPlaySuccess, @onPlayError)

  paused: () ->
    @currentMedia.playerState == 'PAUSED'

  onPlaySuccess: () ->
    #console.debug('onPlaySuccess', arguments)

  onPlayError: () ->
    #console.debug('onPlayError', arguments)

  onMediaError: () =>
    #console.debug('onMediaError:', arguments)

  onLaunchError: () =>
    #console.debug('onLaunchError:', arguments)

module.exports = ChromeCast
