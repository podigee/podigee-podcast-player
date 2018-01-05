$ = require('jquery')
_ = require('lodash')
sightglass = require('sightglass')
rivets = require('rivets')

Utils = require('../utils.coffee')
Extension = require('../extension.coffee')

class ChapterMark
  constructor: (data, callback) ->
    @data = data
    @cleanData()
    @callback = callback

  cleanData: =>
    @data.start = @data.start.split('.')[0]
    @data.startInSeconds = Utils.hhmmssToSeconds(@data.start)

  render: =>
    @elem = $(@defaultHtml)
    rivets.bind(@elem, @data)
    @elem.on('click', @data, @callback)

    return @elem

  defaultHtml:
    """
    <li pp-data-start="start" class="chaptermark">
      <img pp-src="image" pp-if="image" class="chaptermark-image"/>
      <span class="chaptermark-start">{ start }</span>
      <span class="chaptermark-title">{ title }</span>
      <a pp-if="href" pp-href="href" target="_blank" class="chaptermark-href"><i class="fa fa-link"></i></a>
    </li>
    """

class ChapterMarks extends Extension
  @extension:
    name: 'ChapterMarks'
    type: 'panel'

  constructor: (@app) ->
    @options = _.extend(@defaultOptions, @app.extensionOptions.ChapterMarks)
    return if @options.disabled

    @chapters = @app.episode.chaptermarks
    return unless @chapters && @chapters.length

    @renderPanel()
    @renderButton()
    @attachEvents()

    @app.theme.addExtension(this)

  defaultOptions:
    showOnStart: false

  click: (event) =>
    time = event.data.start
    @app.player.media.currentTime = Utils.hhmmssToSeconds(time)

  renderPanel: =>
    @panel = $(@panelHtml())
    @panel.hide()
    @chaptermarks = _.map(@chapters, (item) =>
      new ChapterMark(item, @click)
    )
    @chaptermarks = _.sortBy(@chaptermarks, (mark) =>
      mark.data.startInSeconds
    )
    _.map(@chaptermarks, (mark) =>
      @panel.find('ul').append(mark.render())
    )

  attachEvents: =>
    $(@app.player.media).on('timeupdate', @setActiveMark)

  setActiveMark: () =>
    time = @app.player.currentTimeInSeconds
    if time <= Utils.hhmmssToSeconds(@chaptermarks[0].data.start)
      @deactivateAll()
      @activateMark(@chaptermarks[0])
    else
      _(@chaptermarks).findLast (mark) =>
        markTime = Utils.hhmmssToSeconds(mark.data.start)
        return unless time >= markTime

        @deactivateAll()
        @activateMark(mark)

  activateMark: (mark) =>
    mark.elem.addClass('active')

  deactivateAll: =>
    @panel.find('li').removeClass('active')

  buttonHtml: =>
    """
    <button class="chaptermarks-button" title="#{@t('chaptermarks.show')}"></button>
    """

  panelHtml: =>
    """
    <div class="chaptermarks">
      <h3>#{@t('chaptermarks.title')}</h3>

      <ul></ul>
    </div>
    """

module.exports = ChapterMarks
