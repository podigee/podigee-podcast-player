$ = require('jquery')
_ = require('lodash')
Utils = require('./utils.coffee')
rivets = require('rivets')

Podcast = require('./podcast.coffee')

class Configuration
  constructor: (@app) ->
    @loader = $.Deferred()
    @loaded = @loader.promise()

    @frameOptions = Utils.locationToOptions(window.location.search)

    if @frameOptions.configuration
      @configuration =
        json_config: @frameOptions.configuration
      @fetchJsonConfiguration()
    else
      @receiveConfiguration()

    @configureTemplating()

  receiveConfiguration: =>
    $(window).on 'message', (event) =>
      return unless event.originalEvent.data
      data = event.originalEvent.data
      @configuration = JSON.parse(data)
      return unless @configuration.episode? || @configuration.json_config?

      if @configuration.json_config
        @fetchJsonConfiguration()
      else
        @setConfigurations()
    data = JSON.stringify({
      id: @frameOptions.id,
      listenTo: 'sendConfig'
    })
    window.parent.postMessage(data, '*')

  fetchJsonConfiguration: =>
    return unless @configuration.json_config && @configuration.json_config.length
    self = this
    $.ajax(
      dataType: 'json'
      headers: {
        "Accept": "application/json"
      }
      url: @configuration.json_config
    ).done((data) =>
      self.configuration = _.extend(self.configuration, data)
      self.setConfigurations(true)
    ).error((xhr, status, trace) ->
      console.debug("[podigee podcast player] Error while fetching player configuration:")
      console.debug("xhr:", xhr)
      console.debug("status:", status)
      console.debug("trace:", trace)
    )

  setConfigurations: (viaJSON) =>
    @app.podcast = new Podcast(@app, @configuration.podcast || {})

    @app.episode = @configuration.episode
    if @app.episode.cover_url?
      console.warn('Please use episode.coverUrl instead of episode.cover_url in player configuration')
      @app.episode.coverUrl ?= @configuration.episode.cover_url

    @app.episode.embedCode ?= @configuration.embedCode
    @app.getProductionData()

    @app.extensionOptions = @configuration.extensions || {}

    @app.options = _.extend(@defaultOptions, @configuration.options, @frameOptions)
    @app.options.parentLocationHash = @configuration.parentLocationHash
    @app.options.configViaJSON = viaJSON

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
    # Can be 'script' or 'iframe' depending on how the player is embedded
    # Using a <iframe> tag is considered the default
    iframeMode: 'iframe'
  }

  configureTemplating: =>
    rivets.configure(
      prefix: 'pp'
    )
module.exports = Configuration
