$ = require('jquery')

class ExternalData

  constructor: (app) ->
    @sslProxy = app.options.sslProxy

  get: (url, params) ->
    deferred = $.Deferred()

    url = if url.match(/^http:/)? && @sslProxy
      "#{@sslProxy}#{url}"
    else
      url

    $.get url, (params || {}), (data) -> deferred.resolve(data)

    deferred.promise()

module.exports = ExternalData
