class Utils
  @locationToOptions: (location) ->
    options = {}
    string = window.location.search.replace(/^\?/, '')
    split = string.split('&')

    for string in split
      array = string.split('=')
      options[array[0]] = decodeURIComponent(array[1])

    options

  # used to determine the width of bars for
  # current playtime and loaded data indicator
  @secondsToHHMMSS: (seconds) ->
    hours   = Math.floor(seconds / 3600)
    minutes = Math.floor((seconds - (hours * 3600)) / 60)
    seconds = seconds - (hours * 3600) - (minutes * 60)

    seconds = seconds.toFixed(0)

    hours = @padNumber(hours)
    minutes = @padNumber(minutes)
    seconds = @padNumber(seconds)

    "#{hours}:#{minutes}:#{seconds}"

  @hhmmssToSeconds: (string) ->
    parts = string.split(':')
    seconds = parseInt(parts[2], 10)
    minutes = parseInt(parts[1], 10)
    hours = parseInt(parts[0], 10)
    result = seconds + minutes * 60 + hours * 60 * 60

  @padNumber: (number) ->
    if number < 10
      "0#{number}"
    else
      number

  @calculateCursorPosition: (event) ->
    event.pageX - event.target.offsetLeft

module.exports = Utils
