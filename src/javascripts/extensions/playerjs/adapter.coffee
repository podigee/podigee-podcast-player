class Adapter
  constructor: (@app, @receiver) ->
    @player = @app.player
    @setupEvents()
    @setupMethods()

  setupEvents: () ->
    @app.addEventListener 'subscribeIntent', (payload) =>
      @receiver.emit('subscribeIntent', payload)

    @player.media.addEventListener 'playing', () =>
      # This is diverging from the playerjs spec.
      # According to the spec, the play event don't deliver
      # any data. However, we find it quite useful to know
      # at which time the person has pressed play.
      # This can be either due to a chapter mark or
      # by clicking somehwere in the progressbar/timeline.
      @receiver.emit 'play',
        seconds: @player.media.currentTime

    @player.media.addEventListener 'pause', () =>
      @receiver.emit('pause')

    @player.media.addEventListener 'ended', () =>
      @receiver.emit('ended')

    @player.media.addEventListener 'timeupdate', () =>
      @receiver.emit 'timeupdate',
        seconds: @player.media.currentTime,
        duration: @player.media.duration

    @player.media.addEventListener 'progress', () =>
      @receiver.emit 'buffered',
        percent: @player.media.buffered.length

    @player.media.addEventListener 'seeked', () =>
      @receiver.emit('seeked')

  setupMethods: () ->
    @receiver.on 'play', () =>
      @player.play()

    @receiver.on 'pause', () =>
      @player.pause()

    @receiver.on 'getPaused', (callback) =>
      callback(@player.media.paused)

    @receiver.on 'getCurrentTime', (callback) =>
      callback(@player.media.currentTime)

    @receiver.on 'setCurrentTime', (value) =>
      @player.media.currentTime = value

    @receiver.on 'getDuration', (callback) =>
      callback(@player.media.duration)

    @receiver.on 'setConfiguration', (configuration) =>
      @app.initConfiguration(configuration).loaded.done (configuration) =>
        @app.switchEpisode(@app.episode)

module.exports = Adapter
