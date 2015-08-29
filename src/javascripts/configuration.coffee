$ = require('jquery')
_ = require('lodash')
Utils = require('./utils.coffee')

class Configuration
  constructor: (@app) ->
    @loader = $.Deferred()
    @loaded = @loader.promise()

    @frameOptions = Utils.locationToOptions(window.location.search)

    if @frameOptions.configuration.match('^.*.json$')
      @fetchJsonConfiguration()
    else
      @configuration = window.parent[@frameOptions.configuration]
      @setConfigurations()

  fetchJsonConfiguration: =>
    self = this
    $.getJSON(@frameOptions.configuration).done (data) =>
      self.configuration = data
      self.setConfigurations()

  setConfigurations: =>
    @app.podcast = @configuration.podcast || {}
    @app.getFeed()

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
  }

module.exports = Configuration
