class Utils
  @locationToOptions: (location) ->
    options = {}
    string = window.location.search.replace(/^\?/, '')
    split = string.split('&')

    processValue = (value) =>
      value = decodeURIComponent(value)
      value = true if value == 'true'
      value = false if value == 'false'
      value

    for string in split
      [key, value] = string.split('=')
      options[key] = processValue(value)

    options

  # used to determine the width of bars for
  # current playtime and loaded data indicator
  @secondsToHHMMSS: (seconds) ->
    return unless typeof seconds == 'number'
    hours   = Math.floor(seconds / 3600)
    minutes = Math.floor((seconds - (hours * 3600)) / 60)
    seconds = Math.floor(seconds - (hours * 3600) - (minutes * 60))

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

  # check if the player is embedded on the same URL as the parameter
  @onSameUrl: (url) ->
    document.referrer.replace(/\/$/, '') == url

  @isIE9: () ->
    try
      isIE = navigator.appVersion.indexOf("MSIE") != -1
      return false unless isIE
      version = parseFloat(navigator.appVersion.split("MSIE")[1])
      return false if version > 9
      return true
    catch
      return true

  @isLteIE11: () ->
    try
      return navigator.appVersion.indexOf("Trident/7.0") != -1
    catch
      return true

  # check if Safari 10 or below is used
  @isLteSafari10: () ->
    try
      isSafari = navigator.appVersion.indexOf('Safari') != -1
      return false unless isSafari
      version = parseInt(navigator.appVersion.match(/Version\/(\d{1,2})\.\d/)[1], 10)
      return true if version <= 10
      return false
    catch
      return false

  @scaleImage: (url, size) ->
    return url if url == null
    return url unless url.match(/images\.podigee\.com/)

    url.replace(/\/\d+x,/, "/#{size}x,")

module.exports = Utils
