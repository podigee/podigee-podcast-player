_ = require('lodash')

class AudioFile
  @formatMapping:
    m4a: 'audio/mp4',
    mp3: 'audio/mpeg',
    ogg: 'audio/ogg; codecs="vorbis"',
    opus: 'audio/ogg; codecs="opus"',

  @reverseFormatMapping: _.invert(@formatMapping)

  constructor: (format, @uri, @media) ->
    @format = format
    @findOutIfPlayable()

  findOutIfPlayable: ->
    @playable = if @uri
      @media.canPlayType(@fileFormat())
    else
      ''

  fileFormat: () ->
    AudioFile.formatMapping[@format]

module.exports = AudioFile
