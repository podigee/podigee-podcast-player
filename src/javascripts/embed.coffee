$ = require('jquery')
_ = require('lodash')

IframeResizer = require('./iframe_resizer.coffee')

class Iframe
  constructor: (@elem)->
    @id = Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1)
    config = $(@elem).data('configuration')
    @configuration = window[config] || {}
    if _.isEmpty(@configuration)
      @configuration.json_config = config
    @configuration.parentLocationHash = window.location.hash
    @configuration.embedCode = @elem.outerHTML

    scriptPath = $(@elem).attr('src').match(/(^.*\/)/)[0].replace(/javascripts\/$/, '').replace(/\/$/, '')
    @url = "#{scriptPath}/podigee-podcast-player.html?id=#{@id}"

    @buildIframe()
    @setupListeners()
    @replaceElem()
    @injectConfiguration() if @configuration

  buildIframe: ->
    @iframe = document.createElement('iframe')
    @iframe.id = @id
    @iframe.scrolling = 'no'
    @iframe.src = @url
    @iframe.style.border = '0'
    @iframe.style.overflowY = 'hidden'
    @iframe.style.transition = 'height 100ms linear'
    @iframe.width = @detectWidth()
    @iframe

  detectWidth: ->
    $(@elem).parent().width()

  setupListeners: ->
    IframeResizer.listen('resizePlayer', $(@iframe))

  replaceElem: ->
    $(@iframe).addClass($(@elem).attr('class'))
    @elem.parentNode.replaceChild(@iframe, @elem)

  injectConfiguration: ->
    _.delay (=>
      config = if @configuration.constructor == String
        @configuration
      else
        JSON.stringify(@configuration)
      @iframe.contentWindow.postMessage(config, '*')
    ), 1000

class Embed
  constructor: ->
    players = []
    elems = $('script.podigee-podcast-player')

    return if elems.length == 0

    for elem in elems
      players.push(new Iframe(elem))

    window.podigeePodcastPlayers = players

module.exports = Embed
