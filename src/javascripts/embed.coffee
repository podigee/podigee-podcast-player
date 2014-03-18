class PodiEmbed
  constructor: ->
    @init()

  init: ->
    elems = document.getElementsByClassName('podi-embed')
    @elem = elems[elems.length-1]
    @url = @elem.dataset.source

    @buildIframe()
    @setupListeners()
    @replaceElem()

  buildIframe: ->
    @iframe = document.createElement('iframe')
    @iframe.scrolling = 'no'
    @iframe.src = @url
    @iframe.style.border = '0'
    @iframe.style.overflowY = 'hidden'
    @iframe.style.transition = 'height 100ms linear'
    @iframe.height = '173px'
    @iframe.width = '100%'
    @iframe

  setupListeners: ->
    window.addEventListener("message", @receiveMessage, false)

  receiveMessage: (event) =>
    newHeight = event.data.split(':')[1]
    @iframe.height = "#{newHeight}px"

  replaceElem: ->
    @elem.parentNode.replaceChild(@iframe, @elem)

new PodiEmbed()
