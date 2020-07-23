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

    $.ajax
      url: url
      data: (params || {})
      success: (data) -> deferred.resolve(data)
      xhrFields:
        withCredentials: true

    deferred.promise()

module.exports = ExternalData
