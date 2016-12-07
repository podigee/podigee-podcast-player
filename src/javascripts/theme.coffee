$ = require('jquery')
_ = require('lodash')
sightglass = require('sightglass')
rivets = require('rivets')

class Theme
  constructor: (@app) ->
    @context = @app.episode
    @loadThemeFiles()

  html: null
  render: =>
    @elem = $(@html)
    rivets.bind(@elem, @context)
    $(@app.elemClass).replaceWith(@elem)

    @addEmbedModeClass()
    @findElements()
    @bindCoverLoad()

    return @elem

  loadThemeFiles: () =>
    theme = @app.options.theme || 'default'
    themeHtml = @app.options.themeHtml
    themeCss = @app.options.themeCss
    if themeHtml && themeCss
      @loadCss(themeCss)
      @loadHtml(themeHtml)
    else if theme.constructor == String
      @loadInternalTheme(theme)
    else
      @loadCss(@app.options.themeCss || theme.css)
      @loadHtml(@app.options.themeHtml || theme.html)

  loadInternalTheme: (name) =>
    pathPrefix = "themes/#{name}/index"
    @loadCss("#{pathPrefix}.css")
    @loadHtml("#{pathPrefix}.html")

  loadHtml: (path) =>
    loaded = $.Deferred()
    self = this

    $.get(path).done (html) =>
      self.html = html
      loaded.resolve()

    @loaded = loaded.promise()

  loadCss: (path) =>
    style = $('<link>').attr
      href: path
      rel: 'stylesheet'
      type: 'text/css'
      media: 'all'
    $('head').append(style)

  addLoadingClass: ->
    @elem.addClass('loading')

  removeLoadingClass: ->
    @elem.removeClass('loading')

  addFailedLoadingClass: ->
    @elem.addClass('error-loading')

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
