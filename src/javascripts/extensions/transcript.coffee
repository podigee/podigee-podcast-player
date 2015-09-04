$ = require('jquery')
_ = require('lodash')
sightglass = require('sightglass')
rivets = require('rivets')

Utils = require('../utils.coffee')

class TranscriptLine
  constructor: (time, speaker, text, timestamp) ->
    @data =
      speaker: speaker
      text: text
      time: time
      timestamp: timestamp

  render: =>
    @line = $(@defaultHtml)
    rivets.bind(@line, @data)
    @line

  defaultHtml:
    """
      <li class="transcript-line" rv-data-timestamp="timestamp">
        <span class="transcript-line-timestamp" rv-if="time">{ time }</span>
        <span class="transcript-line-speaker" rv-if="speaker">{ speaker }</span>
        <span class="transcript-line-separator" rv-if="text">-</span>
        <span class="transcript-line-text" rv-if="text">{ text }</span>
      </li>
    """

class Transcript
  @extension:
    name: 'Transcript'
    type: 'panel'

  constructor: (@app) ->
    @options = _.extend(@defaultOptions, @app.extensionOptions.Transcript)

    return unless @options.data

    @load().done =>
      @renderPanel()
      @renderButton()

      @app.renderPanel(this)
      @app.togglePanel(@panel) if @options.showOnStart
      @bindEvents()

  defaultOptions:
    showOnStart: false

  data:
    transcript: ''

  load: =>
    $.get(@options.data).done (transcript) =>
      @processTranscript(transcript)

  processTranscript: (rawTranscript) =>
    parsedTranscript = @parseTimScript(rawTranscript)
    @data.transcript = parsedTranscript.join('')

  parseTimScript: (raw) =>
    splitLines = raw.split("\n")
    splitLines.map (line) =>
      return if line == ""
      meta = line.match(/^\[(.*) (.*)\]/)
      time = meta[1]
      timestamp = Utils.hhmmssToSeconds(time)
      speaker = meta[2]
      text = line.match(/\] (.*)/)
      text = text[1] if text
      tl = new TranscriptLine(time, speaker, text, timestamp)
      tl.render().prop('outerHTML')

  bindEvents: =>
    $(@app.player.media).on('timeupdate', @setActiveLine)
    @panel.find('li').click (event) =>
      @app.player.media.currentTime = event.currentTarget.dataset.timestamp

  activateLine: (line) =>
    $line = $(line)
    return if $line.hasClass('active')
    $line.addClass('active')
    @panel.find('ul').scrollTop(line.offsetTop - 50)

  deactivateAll: (currentLine) =>
    $(currentLine).siblings().removeClass('active')

  setActiveLine: =>
    currentTime = @app.player.media.currentTime
    lines = @panel.find('li')
    if currentTime <= parseInt(lines.first().data('timestamp'), 10)
      @activateLine(lines[0])
      @deactivateAll(lines[0])
    else
      _(lines).findLast (line) =>
        lineTime = parseInt(line.dataset.timestamp, 10)
        return unless currentTime >= lineTime

        @activateLine(line)
        @deactivateAll(line)

  renderButton: =>
    @button = $(@buttonHtml)
    @button.on 'click', =>
      @app.togglePanel(@panel)

  renderPanel: =>
    @panel = $(@panelHtml)
    rivets.bind(@panel, @data)
    @panel.hide()

  buttonHtml:
    """
    <button class="fa fa-pencil transcript-button" title="Show transcript"></button>
    """

  panelHtml:
    """
    <div class="transcript">
      <h3>Transcript</h3>

      <ul class="transcript-text" rv-html="transcript"></pre>
    </div>
    """

module.exports = Transcript
