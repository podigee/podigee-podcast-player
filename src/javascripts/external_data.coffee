$ = require('jquery')

class ExternalData

  constructor: (app) ->
    if app
      @sslProxy = app.options.sslProxy

  get: (url, params) ->
    deferred = $.Deferred()

    url = if url.match(/^http:/)? && @sslProxy
      "#{@sslProxy}#{url}"
    else
      url

    if url.indexOf('transcript') > -1
      url = url.replace('http', 'https')

    $.get url, (params || {}), (data) -> deferred.resolve(data)

    deferred.promise()

module.exports = ExternalData
