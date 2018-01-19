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
    return unless typeof seconds == 'number'
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

  @padNumber: (number, length=2) ->
    number = number.toString()
    while number.length < length
      number = "0#{number}"

    number

  @calculateCursorPosition: (event, elem) ->
    if event.originalEvent.changedTouches?.length
      pageX = event.originalEvent.changedTouches[0].pageX
    else
      pageX = event.pageX

    pageX - elem.getBoundingClientRect().left

  @isIE9: () ->
    try
      isIE = navigator.appVersion.indexOf("MSIE") != -1
      return false unless isIE
      version = parseFloat(navigator.appVersion.split("MSIE")[1])
      return false if version > 9
      return true
    catch
      return true

module.exports = Utils
