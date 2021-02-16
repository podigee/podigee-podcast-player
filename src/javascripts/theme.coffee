$ = require('jquery')
_ = require('lodash')
sightglass = require('sightglass')
rivets = require('rivets')

Utils = require('./utils.coffee')
CustomStyles = require('./custom_styles.coffee')
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

        shareText: @t('share.title'),

        playEpisode: @t('splash.playEpisode'),

        chaptermarksMenu: @t('menu.chaptermarks'),
        transcriptMenu: @t('menu.transcript'),
        episodeInfoMenu: @t('menu.episodeInfo'),
        allEpisodesMenu: @t('menu.allEpisodes'),

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

    return @elem

  updateView: () =>
    @view.update(@context())

  addCustomStyles: () =>
    tag = new CustomStyles(@app.options.customStyle).toStyleTag()
    return unless tag
    $('head').append(tag)

  loadThemeFiles: () =>
    theme = @app.options.theme || 'default'
    # theme = 'default-redesign'
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
    ## Redesigned theme extras start -->
    # Splash button
    @splashButton = @elem.find('.splash-button')
    @mainPlayer = @elem.find('.main-player')
    # More menu
    @moreMenu = @elem.find('.more-menu')
    @moreMenuButton = @elem.find('.more-menu-button')
    @allEpisodesMenuButton = @elem.find('.all-episodes-menu-button')
    @episodeInfoMenuButton = @elem.find('.episode-info-menu-button')
    @transcriptMenuButton = @elem.find('.transcript-menu-button')
    @chaptermarksMenuButton = @elem.find('.chaptermarks-menu-button')
    # Share menu
    @shareMenu = @elem.find('.share-menu')
    @shareMenuFooterButton = @elem.find('.share-menu-button')
    # Subscribe menu
    @subscribeMenu = @elem.find('.subscribe-menu')
    @subscribeMenuFooterButton = @elem.find('.subscribe-menu-button')
    # Close button
    @closeButton = @elem.find('.close-button')
    # Embed button
    @embedList = @elem.find('.embed-list')
    @embedButton = @elem.find('.embed-button')
    # Panels tabs
    @panelsTabs = @elem.find('.panels-tabs')
    @panelsTabButton = @elem.find('.panels-tab-button')
    @allEpisodesTabButton = @elem.find('.all-episodes-tab-button')
    @episodeInfoTabButton = @elem.find('.episode-info-tab-button')
    @transcriptTabButton = @elem.find('.transcript-tab-button')
    @chaptermarksTabButton = @elem.find('.chaptermarks-tab-button')
    # Panels tabs click events
    @panelsTabButton.on 'click', @changeTabsActiveButton
    @allEpisodesTabButton.on 'click', @showAllEpisodesPanel
    @episodeInfoTabButton.on 'click', @showEpisodeInfoPanel
    @transcriptTabButton.on 'click', @showTranscriptPanel
    @chaptermarksTabButton.on 'click', @showChaptermarksPanel
    # Embed button click event
    @embedButton.on 'click', @changeEmbedActiveButton
    # More menu button events
    @allEpisodesMenuButton.on 'click', @toggleAllEpisodesPanel
    @episodeInfoMenuButton.on 'click', @toggleEpisodeInfoPanel
    @transcriptMenuButton.on 'click', @toggleTranscriptPanel
    @chaptermarksMenuButton.on 'click', @toggleChaptermarksPanel
    ## Redesigned theme extras end <--

    @subscribeButton.on 'click', () =>
      @app.emit('subscribeIntent', 'subscribeButton')
      SubscribeButton.open(@app)

    @connectionLinks = @elem.find('.podcast-connections-items a')
    @connectionLinks.on 'click', @handleConnectionClick

    @buttons = @elem.find('.buttons')
    @panels = @elem.find('.panels')
    @panels.hide() unless @app.isInIframeMode() || @app.options.startPanels
    @subscribeButton.hide() if @app.isInIframeMode()

  bindCoverLoad: =>
    @coverImage.on 'load', =>
      @app.sendSizeChange()

  handleConnectionClick: (event) =>
    link = event.currentTarget
    linkTarget = link.attributes['pp-href'].value
    service = linkTarget.split('.')[1]
    @app.emit('subscribeIntent', service)

  ## Redesigned theme extras start -->
  showPlayer: =>
    @splashButton.hide()
    @mainPlayer.fadeIn()

  openMoreMenu: =>
    @elem.addClass('more-menu-open')
    @moreMenu.stop().fadeIn(300).css('display', 'flex')
  
  # openShareMenu and openSubscribeMenu could be merged?
  openShareMenu: =>
    @elem.addClass('share-menu-open')
    @shareMenuFooterButton.addClass('button-active')
    @shareMenu.stop().fadeIn(300).css('display', 'flex')

  openSubscribeMenu: =>
    @elem.addClass('subscribe-menu-open')
    @subscribeMenuFooterButton.addClass('button-active')
    @subscribeMenu.stop().fadeIn(300).css('display', 'flex')
  
  closeMoreMenu: =>
    @elem.removeClass('more-menu-open')
    @moreMenu.stop().fadeOut(300)
  
  # closeShareMenu and closeSubscribeMenu could be merged?
  closeShareMenu: =>
    @elem.removeClass('share-menu-open')
    @shareMenuFooterButton.removeClass('button-active')
    @shareMenu.stop().fadeOut(300)
  
  closeSubscribeMenu: =>
    @elem.removeClass('subscribe-menu-open')
    @subscribeMenuFooterButton.removeClass('button-active')
    @subscribeMenu.stop().fadeOut(300)

  # changeTabsActiveButton and changeEmbedActiveButton could be merged?
  changeTabsActiveButton: (event) =>
    button = $(event.target)
    @panelsTabs.find('.button-active').removeClass('button-active')
    button.addClass('button-active')
  
  changeEmbedActiveButton: (event) =>
    button = $(event.target)
    @embedList.find('.button-active').removeClass('button-active')
    button.addClass('button-active')

  showPanels: =>
    if @panelsTabs.is(":hidden") && @panels.is(":hidden")
      @panelsTabs.slideDown()
      @panels.slideDown()

  hidePanels: =>
    if @panelsTabs.is(":visible") && @panels.is(":visible")
      @panelsTabs.slideUp()
      @panels.slideUp()

  toggleAllEpisodesPanel: =>
    @closeMoreMenu()
    if @allEpisodesPanel.is(':visible')
      @hidePanels()
    else
      @showAllEpisodesPanel()
  
  toggleEpisodeInfoPanel: =>
    @closeMoreMenu()
    if @episodeInfoPanel.is(':visible')
      @hidePanels()
    else
      @showEpisodeInfoPanel()
  
  toggleTranscriptPanel: =>
    @closeMoreMenu()
    if @transcriptPanel.is(':visible')
      @hidePanels()
    else
      @showTranscriptPanel()
  
  toggleChaptermarksPanel: =>
    @closeMoreMenu()
    if @chaptermarksPanel.is(':visible')
      @hidePanels()
    else
      @showChaptermarksPanel()

  showAllEpisodesPanel: =>
    @closeMoreMenu()
    @showPanels()
    @panelsTabButton.removeClass('button-active')
    @allEpisodesTabButton.addClass('button-active')
    @singlePanel.not('.playlist').hide()
    if @allEpisodesPanel.is(':hidden')
      @allEpisodesPanel.fadeIn()      

  showEpisodeInfoPanel: =>
    @closeMoreMenu()
    @showPanels()
    @panelsTabButton.removeClass('button-active')
    @episodeInfoTabButton.addClass('button-active')
    @singlePanel.not('.episode-info').hide()
    if @episodeInfoPanel.is(':hidden')
      @episodeInfoPanel.fadeIn()
  
  showTranscriptPanel: =>
    @closeMoreMenu()
    @showPanels()
    @panelsTabButton.removeClass('button-active')
    @transcriptTabButton.addClass('button-active')
    @singlePanel.not('.transcript').hide()
    if @transcriptPanel.is(':hidden')
      @transcriptPanel.fadeIn()
  
  showChaptermarksPanel: =>
    @closeMoreMenu()
    @showPanels()
    @panelsTabButton.removeClass('button-active')
    @chaptermarksTabButton.addClass('button-active')
    @singlePanel.not('.chaptermarks').hide()
    if @chaptermarksPanel.is(':hidden')
      @chaptermarksPanel.fadeIn()
  ## Redesigned theme extras end <--

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

  addExtension: (extension) =>
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

    ## Redesigned theme extras start -->
    # Find panels when extensions loaded
    @singlePanel = @elem.find('.single-panel')
    @episodeInfoPanel = @elem.find('.episode-info')
    @allEpisodesPanel = @elem.find('.playlist')
    @transcriptPanel = @elem.find('.transcript')
    @chaptermarksPanel = @elem.find('.chaptermarks')
    ## Redesigned theme extras end <--

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
        if @activePanel == elem
          if !@app.isInIframeMode()
            @activePanel.slideToggle(@animationOptions())
            @panels.slideToggle(@animationOptions())
            @panels.removeClass("#{elem[0].className}-open")
            @activePanel = null
        else
          @activePanel.slideToggle(@animationOptions())
          elem.slideToggle(@animationOptions())
          @panels.addClass("#{elem[0].className}-open")
          @activePanel = elem
      else
        unless @app.isInIframeMode()
          @panels.slideToggle(@animationOptions())
        elem.slideToggle(@animationOptions())
        @panels.addClass("#{elem[0].className}-open")
        @activePanel = elem

module.exports = Theme
