$ = require('../../vendor/javascripts/jquery.1.11.0.min.js')
ChapterMark = require('./chaptermark.coffee')

class ChapterMarks
  constructor: (chaptermarks, @elem, button, callback) ->
    return unless chaptermarks.length

    html = $('<ul>')
    chaptermarks.forEach((item, index, array) =>
      chaptermark = new ChapterMark(item, callback).render()
      html.append(chaptermark)
    )
    @elem.append(html)

module.exports = ChapterMarks
