$ = require('jquery')
ChapterMarks = require('../extensions/chaptermarks.coffee')

class ChapterMarksV2 extends ChapterMarks
  buttonHtml: =>
    """
      <button class="chaptermarks-button" title="#{@t('chaptermarks.show')}" aria-label="#{@t('chaptermarks.show')}">#{@t('menu.chaptermarks')}</button>
    """

module.exports = ChapterMarksV2
