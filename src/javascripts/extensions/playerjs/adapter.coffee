class Adapter
  constructor: (@player, @receiver) ->
    @setupEvents()
    @setupMethods()

  setupEvents: () ->
    @player.media.addEventListener 'playing', () =>
      @receiver.emit('play')

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

module.exports = Adapter
