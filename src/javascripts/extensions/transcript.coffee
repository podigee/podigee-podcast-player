$ = require('jquery')
_ = require('lodash')
sightglass = require('sightglass')
rivets = require('rivets')

Extension = require('../extension.coffee')
Utils = require('../utils.coffee')
TranscriptLine = require('./transcript/line.coffee')
Search = require('./transcript/search.coffee')

class Transcript extends Extension
  @extension:
    name: 'Transcript'
    type: 'panel'

  constructor: (@app) ->
    @options = _.extend(@defaultOptions, @app.extensionOptions.Transcript)

    return if @options.disabled
    return unless @app.episode
    return unless @app.episode.transcript

    @transcript = @app.episode.transcript

    @search = new Search()

    @load().done =>
      @renderPanel()
      @renderButton()

      @app.theme.addExtension(this)
      @bindEvents()

  defaultOptions:
    showOnStart: false

  transcriptFileFormat: ->
    _.last(@transcript.split('.'))

  data:
    transcript: ''

  load: =>
    promise = @app.externalData.get(@transcript)
    promise.done (transcript) =>
      @processTranscript(transcript)

  processTranscript: (rawTranscript) =>
    parsedTranscript = if @transcriptFileFormat() == 'srt'
      @parseSrt(rawTranscript)
    else
      @parseTimScript(rawTranscript)

    @data.transcript = parsedTranscript.join('')

  parseTimScript: (raw) =>
    splitLines = raw.split("\n")
    splitLines.map (line) =>
      return if line == ""
      meta = line.match(/^\[(.*) (.*)\]/)
      text = line.match(/\] (.*)/)
      time = meta[1]

      data =
        time: time.split('.')[0]
        timestamp: Utils.hhmmssToSeconds(time)
        speaker: meta[2]
        text: text[1] if text

      tl = new TranscriptLine(data)
      @search.addLine(tl)
      tl.render().prop('outerHTML')

  parseSrt: (raw) ->
    splitBy = if (raw.search("\n\r\n") > -1) then "\n\r\n" else "\n\n"
    segments = raw.split(splitBy)

    segments.map (segment) =>
      parts = segment.split("\n")
      return "" if parts.length < 3

      times = parts[1].split(' --> ')

      data =
        id: parseInt(parts[0], 10)
        time: times[0].split(',')[0]
        timestamp: Utils.hhmmssToSeconds(times[0])
        text: parts.slice(2).join("\n")

      tl = new TranscriptLine(data)
      @search.addLine(tl)
      tl.render().prop('outerHTML')

  currentSearchResultIndex: 0
  bindEvents: =>
    $(@app.player.media).on('timeupdate', @setActiveLine)
    @panel.find('li').click (event) =>
      @app.player.media.currentTime = event.currentTarget.dataset.timestamp

    @search.initInterface(this, @panel)

  activateLine: (line) =>
    $line = $(line)
    return if $line.hasClass('active')
    $line.addClass('active')
    @scrollToLine(line)

  scrollToLine: (elem) ->
    return unless elem
    @panel.find('ul').scrollTop(elem.offsetTop - 50)

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

  renderPanel: =>
    @panel = $(@panelHtml)
    rivets.bind(@panel, @data)
    @panel.hide()

  buttonHtml:
    """
    <button class="transcript-button" title="Show transcript"></button>
    """

  panelHtml:
    """
    <div class="transcript">
      <h3>Transcript</h3>

      <div class="search"></div>

      <ul class="transcript-text" pp-html="transcript"></ul>
    </div>
    """

module.exports = Transcript
