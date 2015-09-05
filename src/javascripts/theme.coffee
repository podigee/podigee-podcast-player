$ = require('jquery')
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

  findElements: ->
    @audioElement = @elem.find('audio')
    @progressBarElement = @elem.find('.progress-bar')
    @waveformElement = @elem.find('.waveform')
    @playPauseElement = @elem.find('.play-button')
    @backwardElement = @elem.find('.backward-button')
    @forwardElement = @elem.find('.forward-button')
    @speedElement = @elem.find('.speed-toggle')
    @coverImage = @elem.find('.cover-image')

    @buttons = @elem.find('.buttons')
    @panels = @elem.find('.panels')

  bindCoverLoad: =>
    @coverImage.on 'load', =>
      @app.sendHeightChange()

  addButton: (button) =>
    @buttons.append(button)

  addPanel: (panel) =>
    @panels.append(panel)

module.exports = Theme
