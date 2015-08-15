class Utils
  @locationToOptions: (location) ->
    options = {}
    string = window.location.search.replace(/^\?/, '')
    split = string.split('&')

    for string in split
      array = string.split('=')
      options[array[0]] = decodeURIComponent(array[1])

    options

module.exports = Utils
