$ = require('jquery')
_ = require('lodash')
Utils = require('./utils.coffee')
rivets = require('rivets')

class Configuration
  constructor: (@app) ->
    @loader = $.Deferred()
    @loaded = @loader.promise()

    @frameOptions = Utils.locationToOptions(window.location.search)

    @receiveConfiguration()

    @configureTemplating()

  receiveConfiguration: =>
    $(window).on 'message', (event) =>
      return unless event.originalEvent.data
      data = event.originalEvent.data
      try
        @configuration = JSON.parse(data)
        @setConfigurations()
      catch
        @configuration = data
        @fetchJsonConfiguration()

  fetchJsonConfiguration: =>
    return unless @configuration.constructor == String
    self = this
    $.ajax(
      dataType: 'json'
      headers: {
        "Accept": "application/json"
      }
      url: @configuration
    ).done (data) =>
      self.configuration = data
      self.setConfigurations()

  setConfigurations: =>
    @app.podcast = @configuration.podcast || {}

    @app.episode = @configuration.episode
    @app.getProductionData()

    @app.extensionOptions = @configuration.extensions || {}

    @app.options = _.extend(@defaultOptions, @configuration.options, @frameOptions)

    @loader.resolve()

  defaultOptions: {
    currentPlaybackRate: 1
    playbackRates: [0.5, 1.0, 1.5, 2.0]
    timeMode: 'countup'
    backwardSeconds: 10
    forwardSeconds: 30
    showChaptermarks: false
    showMoreInfo: false
    theme: 'default'
    sslProxy: null
  }

  configureTemplating: =>
    rivets.configure(
      prefix: 'pp'
    )
module.exports = Configuration
