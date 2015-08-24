$ = require('../../../vendor/javascripts/jquery.1.11.0.min.js')
sightglass = require('../../../vendor/javascripts/sightglass.js')
rivets = require('../../../vendor/javascripts/rivets.min.js')
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

    @renderPanel()
    @renderButton()

    @app.renderPanel(this)

  click: (event) =>
    time = event.data.start
    @app.player.media.currentTime = Utils.hhmmssToSeconds(time)

  renderButton: =>
    @button = $(@buttonHtml)
    @button.on 'click', =>
      @app.togglePanel(@panel)

  renderPanel: =>
    @panel = $(@panelHtml)
    @panel.hide()
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
    <div class="chaptermarks"><ul></ul></div>
    """

module.exports = ChapterMarks
