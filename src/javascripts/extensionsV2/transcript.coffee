$ = require('jquery')
Transcript = require('../extensions/transcript.coffee')

TranscriptLine = require('./transcript/line.coffee')

class TranscriptV2 extends Transcript
  renderLine: (data) ->
    tl = new TranscriptLine(data)
    @search.addLine(tl)
    tl.render().prop('outerHTML')

  buttonHtml: =>
    """
      <button class="transcript-button" title="#{@t('menu.transcript')}" aria-label="#{@t('menu.transcript')}">#{@t('menu.transcript')}</button>
    """

  panelHtml: ->
    """
    <div class="single-panel transcript">
      <h3 class="single-panel-title">#{@t('transcript.title')}</h3>

      <ul class="transcript-text" pp-html="transcript"></ul>
    </div>
    """

module.exports = TranscriptV2
