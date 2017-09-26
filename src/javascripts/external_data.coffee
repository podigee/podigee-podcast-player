$ = require('jquery')

class ExternalData

  constructor: (app) ->
    @sslProxy = app.options.sslProxy

  get: (url) ->
    deferred = $.Deferred()

    url = if url.match(/^http:/)? && @sslProxy
      "#{@sslProxy}#{url}"
    else
      url

    $.get url, (data) -> deferred.resolve(data)

    deferred.promise()

module.exports = ExternalData
