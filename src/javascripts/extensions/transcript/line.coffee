$ = require('jquery')
sightglass = require('sightglass')
rivets = require('rivets')

class TranscriptLine
  constructor: (data) ->
    @data = data

  render: =>
    @line = $(@defaultHtml)
    rivets.bind(@line, @data)
    @line

  defaultHtml:
    """
      <li class="transcript-line" pp-data-timestamp="timestamp">
        <span class="transcript-line-timestamp" pp-if="time">{ time }</span>
        <span class="transcript-line-speaker" pp-if="speaker">
          [{ speaker }]
        </span>
        <span class="transcript-line-text" pp-if="text" pp-html="text"></span>
      </li>
    """

module.exports = TranscriptLine
