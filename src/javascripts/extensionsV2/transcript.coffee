$ = require('jquery')
Transcript = require('../extensions/transcript.coffee')

class TranscriptV2 extends Transcript
  buttonHtml: =>
    """
      <button class="transcript-button" title="#{@t('chaptermarks.show')}" aria-label="#{@t('chaptermarks.show')}">#{@t('menu.transcript')}</button>
    """

module.exports = TranscriptV2
