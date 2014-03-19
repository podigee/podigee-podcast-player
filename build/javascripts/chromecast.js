var PodiCast,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

PodiCast = (function() {
  function PodiCast(podiplay) {
    this.onLaunchError = __bind(this.onLaunchError, this);
    this.onMediaError = __bind(this.onMediaError, this);
    this.buildMediaInfo = __bind(this.buildMediaInfo, this);
    this.onRequestSessionSuccess = __bind(this.onRequestSessionSuccess, this);
    this.initializeUI = __bind(this.initializeUI, this);
    this.receiverListener = __bind(this.receiverListener, this);
    this.sessionListener = __bind(this.sessionListener, this);
    this.onError = __bind(this.onError, this);
    this.onInitSuccess = __bind(this.onInitSuccess, this);
    this.podiplay = podiplay;
    this.player = this.podiplay.player;
    this.initializeCastApi();
    this.initializeUI();
  }

  PodiCast.prototype.initializeCastApi = function() {
    var apiConfig, applicationID, sessionRequest;
    applicationID = 'D7C34EC7';
    sessionRequest = new chrome.cast.SessionRequest(chrome.cast.media.DEFAULT_MEDIA_RECEIVER_APP_ID);
    apiConfig = new chrome.cast.ApiConfig(sessionRequest, this.sessionListener, this.receiverListener);
    return chrome.cast.initialize(apiConfig, this.onInitSuccess, this.onError);
  };

  PodiCast.prototype.onInitSuccess = function() {
    return console.log('onInitSuccess:', arguments);
  };

  PodiCast.prototype.onError = function() {
    return console.log('onError:', arguments);
  };

  PodiCast.prototype.sessionListener = function(session) {
    console.log('sessionListener:', arguments);
    return this.onRequestSessionSuccess(session);
  };

  PodiCast.prototype.receiverListener = function(event) {
    return console.log('receiverListener:', event);
  };

  PodiCast.prototype.initializeUI = function() {
    var elem;
    elem = this.podiplay.elem.find('.chromecast-ui');
    this.castButton = elem.find('.chromecast-button');
    this.castReceiver = elem.find('.chromecast-receiver');
    elem.show();
    return this.castButton.on('click', (function(_this) {
      return function() {
        return chrome.cast.requestSession(_this.onRequestSessionSuccess, _this.onLaunchError);
      };
    })(this));
  };

  PodiCast.prototype.onRequestSessionSuccess = function(event) {
    var request;
    this.session = event;
    this.castReceiver.text("Receiver: " + event.displayName);
    request = new chrome.cast.media.LoadRequest(this.buildMediaInfo());
    request.autoplay = false;
    return this.session.loadMedia(request, this.onMediaDiscovered.bind(this, 'loadMedia'), this.onMediaError);
  };

  PodiCast.prototype.buildMediaInfo = function() {
    var image, mediaInfo, metadata;
    mediaInfo = new chrome.cast.media.MediaInfo(this.player.src, 'audio/mpeg');
    mediaInfo.duration = this.player.duration;
    metadata = new chrome.cast.media.MusicTrackMediaMetadata();
    image = new chrome.cast.Image(this.podiplay.data.logo_url);
    metadata.title = this.podiplay.data.title;
    metadata.images = [image];
    mediaInfo.metadata = metadata;
    return mediaInfo;
  };

  PodiCast.prototype.onMediaDiscovered = function(how, media) {
    return this.currentMedia = media;
  };

  PodiCast.prototype.play = function() {
    return this.currentMedia.play(null, this.onPlaySuccess, this.onPlayError);
  };

  PodiCast.prototype.pause = function() {
    return this.currentMedia.pause(null, this.onPlaySuccess, this.onPlayError);
  };

  PodiCast.prototype.paused = function() {
    return this.currentMedia.playerState === 'PAUSED';
  };

  PodiCast.prototype.onPlaySuccess = function() {
    return console.log('onPlaySuccess', arguments);
  };

  PodiCast.prototype.onPlayError = function() {
    return console.log('onPlayError', arguments);
  };

  PodiCast.prototype.onMediaError = function() {
    return console.log('onMediaError:', arguments);
  };

  PodiCast.prototype.onLaunchError = function() {
    return console.log('onLaunchError:', arguments);
  };

  return PodiCast;

})();
