_ = require('lodash')
Utils = require('./utils.coffee')

class DeeplinkParser
  constructor: (location) ->
    timecode = @_parseLocation(location)
    [@startTime, @endTime] = @parseTimes(timecode)

  parseTimes: (timecode) ->
    return [0] unless timecode?
    return [0] if timecode.split(',').length > 2

    codes = timecode.split(',').map (code) ->
      return 0 if code == ''
      if code.match(':')
        Utils.hhmmssToSeconds(code)
      else
        parseInt(code, 10)

    return [0] if codes[0] > codes[1]

    return codes

  # private

  _parseLocation: (location) ->
    return null unless location
    hash = location[1..-1].split('&')
    timeHash = _(hash).find (h) -> _(h).startsWith('t')

    if timeHash
      timeHash.split('=')[1]

module.exports = DeeplinkParser
