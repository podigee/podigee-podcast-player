$ = require('jquery')
_ = require('lodash')
Utils = require('./utils.coffee')
rivets = require('rivets')

ExternalData = require('./external_data.coffee')
I18n = require('./i18n.coffee')
Podcast = require('./podcast.coffee')

class Configuration
  constructor: (@app, configurationUrl) ->
    @loader = $.Deferred()
    @loaded = @loader.promise()

    @frameOptions = Utils.locationToOptions(window.location.search)

    if configurationUrl
      @configuration =
        json_config: configurationUrl
      @fetchJsonConfiguration()
    else if @frameOptions.configuration
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
      try
        @configuration = JSON.parse(data)
      catch error
        return

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
      console.log("[podigee podcast player] Error while fetching player configuration:")
      console.log("xhr:", xhr)
      console.log("status:", status)
      console.log("trace:", trace)
    )

  setConfigurations: (viaJSON) =>
    return unless @configuration.episode
    @app.podcast = new Podcast(@app, @configuration.podcast || {})

    @app.extensionOptions = @configuration.extensions || {}

    @app.customOptions = @configuration.customOptions
    @configuration.options ?= {}
    @app.options = _.extend(@defaultOptions, @configuration.options, @frameOptions)
    @app.options.parentLocationHash = @configuration.parentLocationHash
    @app.options.configViaJSON = viaJSON
    @app.externalData = new ExternalData(@app)

    # The locale can be fixed in the player config, or autodetected by the browser.
    # It will fall back to en-US if no locale was found
    i18n = new I18n(@configuration.options.locale, @defaultOptions.locale)
    @app.i18n = i18n

    if @configuration.episode
      @app.episode = @configuration.episode
    else
      @app.podcast.getEpisodes().done =>
        if @app.podcast.episodes
          @configuration.episode = @app.podcast.episodes[0]
          @setConfigurations(viaJSON)
      return

    if @app.episode.cover_url?
      console.warn('Please use episode.coverUrl instead of episode.cover_url in player configuration')
      @app.episode.coverUrl ?= @configuration.episode.cover_url

    @app.episode.embedCode ?= @configuration.embedCode
    @app.getProductionData()

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
    amp: false,
    locale: 'en-US'
    theme: 'default'
    themeHtml: null
    themeCss: null
    customStyle: null
    startPanel: null
  }

  configureTemplating: =>
    rivets.configure(
      prefix: 'pp'
    )

    # make links text open in parent window
    rivets.formatters.description = (text) =>
      elem = document.createElement('div')
      elem.innerHTML = text.trim()
      links = elem.querySelectorAll('a')
      Array.prototype.forEach.call(links, (link) => link.target = '_parent')
      elem.innerHTML

    rivets.formatters.scale = (url, size) =>
      Utils.scaleImage(url, size)

    rivets.formatters.date = (datestring, locale) =>
      date = new Date(datestring)
      new Intl.DateTimeFormat(locale).format(date)

module.exports = Configuration
