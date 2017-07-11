$ = require('jquery')
_ = require('lodash')

IframeResizer = require('./iframe_resizer.coffee')

class Iframe
  constructor: (@elem)->
    @id = Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1)
    config = $(@elem).data('configuration')
    @configuration = if typeof config == 'string'
      window[config] || {}
    else
      config

    if _.isEmpty(@configuration)
      @configuration.json_config = config
    @configuration.parentLocationHash = window.location.hash
    @configuration.embedCode = @elem.outerHTML

    @url = "#{@origin()}/podigee-podcast-player.html?id=#{@id}&iframeMode=script"

    @buildIframe()
    @setupListeners()
    @replaceElem()
    @injectConfiguration() if @configuration

  origin: () ->
    scriptSrc = $(@elem).attr('src')
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
    @iframe.style.minWidth = '100%'
    @iframe.width = "1px"
    @iframe

  setupListeners: ->
    IframeResizer.listen('resizePlayer', $(@iframe))

  replaceElem: ->
    $(@iframe).addClass($(@elem).attr('class'))
    @elem.parentNode.replaceChild(@iframe, @elem)

  injectConfiguration: ->
    $(window).on 'message', (event) =>
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

class Embed
  constructor: ->
    players = []
    elems = $('script.podigee-podcast-player')

    return if elems.length == 0

    for elem in elems
      players.push(new Iframe(elem))

    window.podigeePodcastPlayers = players

module.exports = Embed
