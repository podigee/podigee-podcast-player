$ = require('jquery')
_ = require('lodash')
sightglass = require('sightglass')
rivets = require('rivets')

Utils = require('./utils.coffee')
CustomStyles = require('./custom_styles.coffee')
CustomStylesV2 = require('./custom_styles_v2.coffee')
SubscribeButton = require('./extensions/subscribe_button.coffee')

class Theme
  constructor: (@app) ->
    @loadThemeFiles()
    @addCustomStyles()

  themeConfig: =>
    options = @app.extensionOptions.SubscribeBar
    if options?.disabled == false
      SubscribeButton.load(@app)
    {
      showSubscribeBar: options?.disabled == false,
      showSubscribeButton: !@app.isInAMPMode(),
      translations: {
        playPause: @t('theme.playPause'),
        backward: @t('theme.backward'),
        forward: @t('theme.forward'),
        changePlaybackSpeed: @t('theme.changePlaybackSpeed'),
        previous: @t('theme.previous'),
        next: @t('theme.next'),
        allEpisodes: @t('subscribeBar.allEpisodes'),
        podcastOnItunes: @t('subscribeBar.podcastOnItunes'),
        podcastOnSpotify: @t('subscribeBar.podcastOnSpotify'),
        podcastOnDeezer: @t('subscribeBar.podcastOnDeezer'),
        podcastOnAlexa: @t('subscribeBar.podcastOnAlexa'),
        podcastOnPodimo: @t('subscribeBar.podcastOnPodimo'),
        subscribe: @t('subscribeBar.subscribe'),
        playEpisode: @t('splash.playEpisode'),
        downloadEpisode: @t('download.episode'),
        shareEmail: @t('share.email'),
        podigeeTitle: @t('podigee.title')
      },
      customOptions: @app.customOptions,
      or: @orFunction,
      locale: @app.i18n.locale
    }

  # used in template to fall back to arg2 if arg1 is undefined or null
  orFunction: (arg1, arg2) =>
    arg1 || arg2

  context: =>
    attrs = _.merge(@app.episode, @app.podcast.forTheme(), @themeConfig())
    # hide All Episodes link when on the page that is linked to
    if @app.options.theme == 'default' && Utils.onSameUrl(attrs.podcastUrl)
      attrs.podcastUrl = null
    attrs

  t: (key) ->
    @app.i18n.t(key)

  html: null
  render: =>
    @elem = $(@html)
    @view = rivets.bind(@elem, @context())
    $(@app.elemClass).replaceWith(@elem)

    @addEmbedModeClass()
    @findElements()
    @bindCoverLoad()
    @initializeSpeedToggle()
    if @app.options.themeVersion == 2
      @changeLogoUrl()

    return @elem

  updateView: () =>
    @view.update(@context())

  addCustomStyles: () =>
    if @app.options.themeVersion == 2
      tag = new CustomStylesV2(@app.options.customStyle).toStyleTag()
    else
      tag = new CustomStyles(@app.options.customStyle).toStyleTag()
    return unless tag
    $('head').append(tag)

  loadThemeFiles: () =>
    theme = @app.options.theme || 'default'
    themeHtml = @app.options.themeHtml || theme.html
    themeCss = @app.options.themeCss || theme.css
    if themeHtml && themeCss
      @loadCss(themeCss)
      @loadHtml(themeHtml)
    else if theme.constructor == String
      @loadInternalTheme(theme, themeHtml, themeCss)

  loadInternalTheme: (name, themeHtml, themeCss) =>
    pathPrefix = "themes/#{name}/index"
    @loadCss(themeCss || "#{pathPrefix}.css?#{@app.version}")
    @loadHtml(themeHtml || "#{pathPrefix}.html?#{@app.version}")

  loadHtml: (path) =>
    loaded = $.Deferred()
    self = this
    if @app.origin and path.indexOf('http') != 0
      $.ajax("#{@app.origin}/#{path}").done (html) =>
        self.html = html
        loaded.resolve()
    else
      $.get(path).done (html) =>
        self.html = html
        loaded.resolve()

    @loaded = loaded.promise()

  loadCss: (path) =>
    path = if @app.origin and path.indexOf('http') != 0 then "#{@app.origin}/#{path}" else path
    style = $('<link>').attr
      href: path
      rel: 'stylesheet'
      type: 'text/css'
      media: 'all'
    unless @stylesheetExists(path)
      $('head').append(style)

  stylesheetExists: (path) ->
    result = false
    stylesheets = document.querySelectorAll('link')
    for stylesheet in stylesheets
      if stylesheet.href == path
        result = true

    result

  addPlayingClass: ->
    @elem.addClass('playing')
    @playPauseElement[0].title = @t('theme.pause')
    @playPauseElement[0].setAttribute('aria-label', @t('theme.pause'))

  removePlayingClass: ->
    @elem.removeClass('playing')
    @playPauseElement[0].title = @t('theme.play')
    @playPauseElement[0].setAttribute('aria-label', @t('theme.play'))

  addLoadingClass: ->
    @removePlayingClass()
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
    @playPauseElement = @elem.find('.play-button')
    @backwardElement = @elem.find('.backward-button')
    @forwardElement = @elem.find('.forward-button')
    @skipForwardElement = @elem.find('.skip-forward-button')
    @skipBackwardElement = @elem.find('.skip-backward-button')
    @speedElement = @elem.find('.speed-toggle')
    @speedSelectElement = @elem.find('.speed-select')
    @coverImage = @elem.find('.cover-image')
    @subscribeButton = @elem.find('.subscribe-button')

    @subscribeButton.on 'click', () =>
      @app.emit('subscribeIntent', 'subscribeButton')
      SubscribeButton.open(@app)

    @connectionLinks = @elem.find('.podcast-connections-items a')
    @connectionLinks.on 'click', @handleConnectionClick

    @buttons = @elem.find('.buttons')
    @panels = @elem.find('.panels')
    @panels.hide() unless @app.isInIframeMode() || @app.options.startPanels
    @subscribeButton.hide() if @app.isInIframeMode()

    # Theme V2
    @splashButton = @elem.find('.splash-button')
    @mainPlayer = @elem.find('.main-player')
    @moreMenuButton = @elem.find('.more-menu-button')

    @splashButton.on 'click', () =>
      @showPlayer()
      @app.player.play()

  bindCoverLoad: =>
    @coverImage.on 'load', =>
      @app.sendSizeChange()

  handleConnectionClick: (event) =>
    link = event.currentTarget
    linkTarget = link.attributes['pp-href'].value
    service = linkTarget.split('.')[1]
    @app.emit('subscribeIntent', service)

  initializeSpeedToggle: =>
    @speedElement.text('1x')
    @speedSelectElement.val('1.0')

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

  addMoreMenuButton: (button) =>
    moreMenu = @elem.find('.more-menu')
    moreMenu.append(button)

  handleMoreMenuVisiblity: (elem) =>
    if @app.options.themeVersion == 2
      panelsTabs = @elem.find('.panels-tabs')
      panelsTabs.attr('class', 'panels-tabs')
      if elem[0].className.indexOf('single-panel') > -1 and @activePanel
        panelsTabs.css('display', 'block')
        panelsTabs.addClass("#{elem[0].className}-open")
      else
        panelsTabs.css('display', 'none')

  addExtension: (extension) =>
    if @app.options.themeVersion == 2 and extension.type != 'menu'
      @addMoreMenuButton(extension.button)
    else
      @addButton(extension.button)
    @panels.append(extension.panel)

    if extension.name() == @app.options.startPanel
      extension.button.trigger('click')

    if @app.options.startPanels && @app.options.startPanels.indexOf(extension.name()) != -1
      extension.panel.show()
      @panels.toggleClass("#{extension.panel[0].className}-open")

    if !@app.options.startPanel && @app.isInIframeMode()
      @buttons.hide()
      @panels.hide()

  animationOptions: ->
    duration: 300
    step: _.debounce(@app.sendSizeChange, 50)

  activePanel: null
  togglePanel: (elem) =>
    return unless elem
    if @app.isInMultiPanelMode()
      elem.slideToggle(@animationOptions())
      @panels.toggleClass("#{elem[0].className}-open")
    else
      if @activePanel?
        if @activePanel.is(elem)
          if !@app.isInIframeMode()
            @activePanel.slideToggle(@animationOptions())
            @panels.slideToggle(@animationOptions())
            @panels.removeClass("#{elem[0].className}-open")
            @activePanel = null
        else
          @activePanel.slideToggle(@animationOptions())
          elem.slideToggle(@animationOptions())
          @panels.removeClass("#{@activePanel[0].className}-open")
          @panels.addClass("#{elem[0].className}-open")
          @activePanel = elem
      else
        unless @app.isInIframeMode()
          @panels.slideToggle(@animationOptions())
          elem.slideToggle(@animationOptions())
        @panels.addClass("#{elem[0].className}-open")
        @activePanel = elem
    @handleMoreMenuVisiblity(elem)

  showPlayer: =>
    @splashButton.hide()
    @mainPlayer.fadeIn()

  changeLogoUrl: =>
    href = 'https://www.podigee.com/en/start-a-podcast-with-podigee?utm_source=podigee&utm_medium=referral&utm_campaign=w-en-en-webplayer'
    @elem.find('.podigee-link').attr("href", href)

module.exports = Theme
