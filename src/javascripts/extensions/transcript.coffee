$ = require('jquery')
_ = require('lodash')
sightglass = require('sightglass')
rivets = require('rivets')
window.WebVTT = WebVTT = require('vtt.js').WebVTT
if window.navigator.appVersion.match /Trident/
  window.VTTCue = VTTCue = require('vtt.js').VTTCue


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

    @search = new Search(@app)

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
    parsedTranscript = if @transcriptFileFormat() == 'vtt'
      @parseWebVTT(rawTranscript)
    else if @transcriptFileFormat() == 'srt'
      @parseSrt(rawTranscript)
    else if @transcriptFileFormat() == 'json'
      @parseJson(rawTranscript)
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

      @renderLine(data)

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

      @renderLine(data)

  parseWebVTT: (raw) =>
    cues = []
    parser = new WebVTT.Parser(window, WebVTT.StringDecoder())
    parser.oncue = (cue) -> cues.push(cue)
    parser.parse(raw)
    parser.flush()

    track = @app.player.media.addTextTrack('captions', 'Transcript')
    track.mode = 'showing'

    cues.map (cue) =>
      unless window.navigator.appVersion.match /Trident/
        track.addCue(cue)
      startTime = Math.round(cue.startTime)
      cueHTML = cue.getCueAsHTML().firstChild
      data =
        time: Utils.secondsToHHMMSS(startTime)
        timestamp: startTime.toString()
        speaker: cueHTML.title
        text: cueHTML.textContent
      @renderLine(data)

  parseJson: (raw) ->
    raw.transcription.map (segment) =>
      data =
        time: Utils.secondsToHHMMSS(segment.start)
        timestamp: segment.start.toString()
        speaker: segment.speaker
        text: segment.text
      @renderLine(data)

  renderLine: (data) ->
    tl = new TranscriptLine(data)
    @search.addLine(tl)
    tl.render().prop('outerHTML')

  currentSearchResultIndex: 0
  bindEvents: =>
    $(@app.player.media).on('timeupdate', @setActiveLine)
    @panel.find('li').click (event) =>
      @app.player.setCurrentTime(event.currentTarget.dataset.timestamp)

    @search.initInterface(this, @panel)

  activateLine: (line) =>
    $line = $(line)
    return if $line.hasClass('active')
    $line.addClass('active')
    @scrollToLine(line)

  scrollToLine: (elem) ->
    return unless elem
    if @panel.find('ul').width() < 517
      @panel.find('ul').scrollTop(elem.offsetTop - 80)
    else
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
    @panel = $(@panelHtml())
    rivets.bind(@panel, @data)
    @panel.hide()

  buttonHtml: ->
    """
    <button class="transcript-button" title="#{@t('transcript.show')}" aria-label="#{@t('transcript.show')}"></button>
    """

  panelHtml: ->
    """
    <div class="transcript">
      <h3>#{@t('transcript.title')}</h3>

      <div class="search"></div>

      <ul class="transcript-text" pp-html="transcript"></ul>
    </div>
    """

module.exports = Transcript
