_ = require('lodash')
Peaks = require('peaks.js')

Extension = require('../extension.coffee')

class Waveform extends Extension
  @extension:
    name: 'Waveform'
    type: 'progress'

  constructor: (@app) ->
    return unless @app.theme.waveformElement.length

    @elem = @app.theme.waveformElement
    @audio = @app.theme.audioElement

    unless @app.extensionOptions.Waveform
      @elem.hide()
      return

    unless @app.episode.waveform
      @elem.hide()
      return

    @options = _.extend(@defaultOptions, @app.extensionOptions.Waveform)

    @render()

  defaultOptions:
    color: "rgba(100, 149, 237, 0.8)"
    playheadColor: "rgba(0, 0, 0, 0.1)"

  render: =>
    height = @elem.height() * 2
    transparent = 'rgba(0, 0, 0, 0)'
    Peaks.init
      #dataUri: { json: @app.episode.waveform }
      container: @elem[0]
      mediaElement: @audio[0]
      height: height
      template: """
        <div class="waveform">
          <div class="zoom-container"></div>
          <div class="overview-container"></div>
        </div>
      """
      inMarkerColor: transparent
      outMarkerColor: transparent
      zoomWaveformColor: @options.color
      overviewWaveformColor: @options.color
      overviewHighlightRectangleColor: transparent
      segmentColor: transparent
      playheadColor: @options.playheadColor
      playheadTextColor: transparent
      pointMarkerColor: transparent
      axisGridlineColor: transparent
      axisLabelColor: transparent

module.exports = Waveform
