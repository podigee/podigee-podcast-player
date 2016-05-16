$ = require('jquery')
_ = require('lodash')
sightglass = require('sightglass')
rivets = require('rivets')

class Theme
  constructor: (@app) ->
    @context = @app.episode
    @themeName = @app.options.theme
    @html = @app.options.themeHtml
    @css = @app.options.themeCss
    @loadCustomHtml()
    @loadCustomCss()

  render: =>
    @elem = $(@html)
    rivets.bind(@elem, @context)
    $(@app.elemClass).replaceWith(@elem)

    @addEmbedModeClass()
    @findElements()
    @bindCoverLoad()

    return @elem

  loadCustomHtml: () =>
    loaded = $.Deferred()

    self = this
    @html ?= "themes/#{@themeName}/index.html"

    if @html.match('^.*\.html$')
      $.get(@html).done (html) =>
        self.html = html
        loaded.resolve()
      @html = null
    else
      @html ?= @defaultHtml
      loaded.resolve()

    @loaded = loaded.promise()

  loadCustomCss: =>
    @css ?= "themes/#{@themeName}/index.css"

    link = $('<link>').attr
      href: @css
      rel: 'stylesheet'
      type: 'text/css'
      media: 'all'

    $('head').append(link)

  addEmbedModeClass: ->
    modeClass = "mode-#{@app.options.iframeMode}"
    @elem.addClass(modeClass)

  findElements: ->
    @audioElement = @elem.find('audio')
    @progressBarElement = @elem.find('progressbar')
    @waveformElement = @elem.find('.waveform')
    @playPauseElement = @elem.find('.play-button')
    @backwardElement = @elem.find('.backward-button')
    @forwardElement = @elem.find('.forward-button')
    @speedElement = @elem.find('.speed-toggle')
    @coverImage = @elem.find('.cover-image')

    @buttons = @elem.find('.buttons')
    @panels = @elem.find('.panels')
    @panels.hide() unless @app.isInIframeMode()

  bindCoverLoad: =>
    @coverImage.on 'load', =>
      @app.sendSizeChange()

  changeActiveButton: (event) =>
    button = $(event.target)
    if button.hasClass('button-active')
      button.removeClass('button-active')
      return

    @buttons.find('.button-active').removeClass('button-active')
    button.addClass('button-active')

  removeButtons: () =>
    @buttons.empty()

  removePanels: () =>
    @panels.empty()

  addButton: (button) =>
    @buttons.append(button)
    button.on 'click', @changeActiveButton

  addExtension: (extension) =>
    @addButton(extension.button)
    @panels.append(extension.panel)

    if extension.name() == @app.options.startPanel
      extension.button.trigger('click')

    if !@app.options.startPanel && @app.isInIframeMode()
      @buttons.hide()
      @panels.hide()

  animationOptions: ->
    duration: 300
    step: _.debounce(@app.sendSizeChange, 50)

  activePanel: null
  togglePanel: (elem) =>
    if @activePanel?
      if @activePanel == elem
        if !@app.isInIframeMode()
          @activePanel.slideToggle(@animationOptions())
          @panels.slideToggle(@animationOptions())
          @activePanel = null
      else
        @activePanel.slideToggle(@animationOptions())
        elem.slideToggle(@animationOptions())
        @activePanel = elem
    else
      unless @app.isInIframeMode()
        @panels.slideToggle(@animationOptions())
      elem.slideToggle(@animationOptions())
      @activePanel = elem

module.exports = Theme
