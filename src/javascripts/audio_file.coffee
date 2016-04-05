class AudioFile
  constructor: (format, @uri, @media) ->
    @format = format
    @findOutIfPlayable()

  findOutIfPlayable: ->
    @playable = @media.canPlayType(@fileFormat())

  fileFormat: () ->
    {
      m4a: 'audio/mp4',
      mp3: 'audio/mpeg',
      ogg: 'audio/ogg; codecs="vorbis"',
      opus: 'audio/ogg; codecs="opus"',
    }[@format]

module.exports = AudioFile
