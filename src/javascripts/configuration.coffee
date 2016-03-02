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
      @configuration = JSON.parse(data)

      if @configuration.json_config
        @fetchJsonConfiguration()
      else
        @setConfigurations()

  fetchJsonConfiguration: =>
    return unless @configuration.json_config && @configuration.json_config.length
    self = this
    $.ajax(
      dataType: 'json'
      headers: {
        "Accept": "application/json"
      }
      url: @configuration.json_config
    ).done (data) =>
      self.configuration = _.extend(self.configuration, data)
      self.setConfigurations()

  setConfigurations: =>
    @app.podcast = @configuration.podcast || {}

    @app.episode = @configuration.episode
    if @app.episode.cover_url?
      console.warn('Please use episode.coverUrl instead of episode.cover_url in player configuration')
      @app.episode.coverUrl ?= @configuration.episode.cover_url

    @app.getProductionData()

    @app.extensionOptions = @configuration.extensions || {}

    @app.options = _.extend(@defaultOptions, @configuration.options, @frameOptions)
    @app.options.parentLocationHash = @configuration.parentLocationHash

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
