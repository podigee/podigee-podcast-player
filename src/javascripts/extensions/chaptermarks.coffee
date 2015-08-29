$ = require('jquery')
_ = require('lodash')
sightglass = require('sightglass')
rivets = require('rivets')

Utils = require('../utils.coffee')

class ChapterMark
  constructor: (context, callback) ->
    @context = context
    @callback = callback

  render: =>
    @elem = $(@defaultHtml)
    rivets.bind(@elem, @context)
    @elem.on('click', 'img, span', @context, @callback)

    return @elem

  defaultHtml:
    """
    <li rv-data-start="start">
      <img rv-src="image" rv-if="image"/>
      <span>{ title }</span>
      <a rv-if="href" rv-href="href" target="_blank"><i class="fa fa-external-link"></i></a>
    </li>
    """

class ChapterMarks
  @extension:
    name: 'ChapterMarks'
    type: 'panel'

  constructor: (@app) ->
    @chaptermarks = @app.episode.chaptermarks
    return unless @chaptermarks && @chaptermarks.length

    @options = _.extend(@defaultOptions, @app.extensionOptions.ChapterMarks)

    @renderPanel()
    @renderButton()

    @app.renderPanel(this)

  defaultOptions:
    showOnStart: false

  click: (event) =>
    time = event.data.start
    @app.player.media.currentTime = Utils.hhmmssToSeconds(time)

  renderButton: =>
    @button = $(@buttonHtml)
    @button.on 'click', =>
      @app.togglePanel(@panel)

  renderPanel: =>
    @panel = $(@panelHtml)
    @panel.hide() unless @options.showOnStart
    @chaptermarks.forEach((item, index, array) =>
      chaptermark = new ChapterMark(item, @click).render()
      @panel.find('ul').append(chaptermark)
    )

  buttonHtml:
    """
    <i class="fa fa-list chaptermarks-button" title="Show chaptermarks"></i>
    """

  panelHtml:
    """
    <div class="chaptermarks">
      <h3>Chaptermarks</h3>

      <ul></ul>
    </div>
    """

module.exports = ChapterMarks
