IframeResizer = require('./iframe_resizer.coffee')
SubscribeButtonTrigger = require('./subscribe_button_trigger.coffee')

class Iframe
  constructor: (@elem)->
    config = @elem.getAttribute('data-configuration').replace(/(^\s+|\s+$)/g, '')
    @id = @randomId(config)
    @configuration = if typeof config == 'string'
      if config.match(/^{/)
        JSON.parse(config)
      else
        @getInSiteConfig(config) || {json_config: config}
    else
      config

    @configuration.parentLocationHash = window.location.hash
    @configuration.embedCode = @elem.outerHTML
    try
      @configuration.customOptions = JSON.parse(@elem.getAttribute('data-options'))
    catch
      console.debug('[Podigee Podcast Player] data-options has invalid JSON')

    @url = "#{@origin()}/podigee-podcast-player.html?id=#{@id}&iframeMode=script"

    @buildIframe()
    @setupListeners()
    @replaceElem()
    @injectConfiguration() if @configuration
    @setupSubscribeButton()

  getInSiteConfig: (config) ->
    inSiteConfig = if !(config.indexOf('http') == 0) && config.match(/\./) && !config.match(/^\//)
      configSplit = config.split('.')
      tempConfig = null
      configSplit.forEach (cfg) ->
        if tempConfig == null
          tempConfig = window[cfg]
        else
          tempConfig = tempConfig[cfg]
      tempConfig
    else
      window[config]

  randomId: (string) ->
    hash = 0
    return hash if string.length == 0

    hsh = (char) =>
      return if isNaN(char)
      hash = ((hash<<5)-hash)+char
      hash = hash & hash

    hsh(string.charCodeAt(i)) for i in [0..string.length]

    return hash.toString(16).substring(1)

  origin: () ->
    scriptSrc = @elem.src || @elem.getAttribute('src')
    unless window.location.protocol.match(/^https/)
      scriptSrc = scriptSrc.replace(/^https/, 'http')
    scriptSrc.match(/(^.*\/)/)[0].replace(/javascripts\/$/, '').replace(/\/$/, '')

  buildIframe: ->
    @iframe = document.createElement('iframe')
    @iframe.id = @id
    @iframe.scrolling = 'no'
    @iframe.src = @url
    @iframe.style.border = '0'
    @iframe.style.overflowY = 'hidden'
    @iframe.style.transition = 'height 100ms linear'
    @iframe.width = '100%'
    @iframe.title = 'Podcast'
    @iframe.setAttribute('aria-label', 'Podcast')
    @iframe

  setupListeners: ->
    IframeResizer.listen('resizePlayer', @iframe)

  setupSubscribeButton: ->
    window.addEventListener 'message', ((event) =>
      try
        eventData = JSON.parse(event.data || event.originalEvent.data)
      catch
        return
      return unless eventData.id == @iframe.id
      return unless eventData.listenTo == 'loadSubscribeButton'

      subscribeButton = new SubscribeButtonTrigger(@iframe)
      subscribeButton.listen()
    ), false

  replaceElem: ->
    @iframe.className += @elem.className
    @elem.parentNode.replaceChild(@iframe, @elem)

  injectConfiguration: ->
    window.addEventListener 'message', ((event) =>
      try
        eventData = JSON.parse(event.data || event.originalEvent.data)
      catch
        return
      return unless eventData.id == @iframe.id
      return unless eventData.listenTo == 'sendConfig'

      config = if @configuration.constructor == String
        @configuration
      else
        JSON.stringify(@configuration)
      @iframe.contentWindow.postMessage(config, '*')
    ), false

class Embed
  constructor: ->
    players = []
    elems = document.querySelectorAll('script.podigee-podcast-player, div.podigee-podcast-player')

    return if elems.length == 0

    for elem in elems
      players.push(new Iframe(elem))

    window.podigeePodcastPlayers = players

new Embed()
