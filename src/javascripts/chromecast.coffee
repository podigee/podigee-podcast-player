class PodiCast
  constructor: (podiplay) ->
    @podiplay = podiplay
    @player = @podiplay.player
    @initializeCastApi()
    @initializeUI()

  initializeCastApi: () ->
    sessionRequest = new chrome.cast.SessionRequest(chrome.cast.media.DEFAULT_MEDIA_RECEIVER_APP_ID)
    apiConfig = new chrome.cast.ApiConfig(sessionRequest, @sessionListener, @receiverListener)
    chrome.cast.initialize(apiConfig, @onInitSuccess, @onError)

  onInitSuccess: () =>
    console.log('onInitSuccess:', arguments)

  onError: () =>
    console.log('onError:', arguments)

  sessionListener: (session) =>
    console.log('sessionListener:', arguments)
    @onRequestSessionSuccess(session)

  receiverListener: (event) =>
    console.log('receiverListener:', event)

  initializeUI: () =>
    elem = @podiplay.elem.find('.chromecast-ui')
    @castButton = elem.find('.chromecast-button')
    @castReceiver = elem.find('.chromecast-receiver')

    elem.show()

    @castButton.on 'click', =>
      chrome.cast.requestSession(@onRequestSessionSuccess, @onLaunchError);

  onRequestSessionSuccess: (event) =>
    @session = event
    @castReceiver.text("Receiver: #{event.displayName}")

    request = new chrome.cast.media.LoadRequest(@buildMediaInfo())
    request.autoplay = false
    @session.loadMedia(request, @onMediaDiscovered.bind(this, 'loadMedia'), @onMediaError)

  buildMediaInfo: () =>
    mediaInfo = new chrome.cast.media.MediaInfo(@player.src, 'audio/mpeg')
    mediaInfo.duration = @player.duration

    metadata = new chrome.cast.media.MusicTrackMediaMetadata()
    image = new chrome.cast.Image(@podiplay.data.logo_url)
    metadata.title = @podiplay.data.title
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
    console.log('onPlaySuccess', arguments)

  onPlayError: () ->
    console.log('onPlayError', arguments)

  onMediaError: () =>
    console.log('onMediaError:', arguments)

  onLaunchError: () =>
    console.log('onLaunchError:', arguments)
