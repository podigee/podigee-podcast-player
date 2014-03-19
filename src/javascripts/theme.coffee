class PodiTheme
  constructor: (render_to, context, html) ->
    @render_to = $(render_to)
    @html = html || @defaultHtml
    @context = context

  render: =>
    template = Handlebars.compile(@html)
    output = $(template(@context))
    @render_to.replaceWith(output)
    output

  defaultHtml:
    """
    <div class="video-player">
      <div class="info">
        <img src="{{logo_url}}" />
        <div class="title">{{title}}</div>
        <div class="description">{{subtitle}}</div>
      </div>
      <!--<audio id="player" src="http://cdn.files.podigee.com/tmp_media/auphonic-example.mp3" preload="metadata"></audio>-->
      <audio id="player" src="{{playlist.mp3}}" preload="metadata"></audio>
      <div class="time-scrubber">
        <div class="time-played" title="Switch display mode"></div>
        <div class="rail">
          <span class="time-scrubber-loaded"></span>
          <div class="time-scrubber-buffering"></div>
          <span class="time-scrubber-played"></span>
        </div>
      </div>

      <div class="controls">
        <i class="fa fa-backward backward-button" title="Backward 10s"></i>
        <i class="fa fa-play play-button" title="Play/Pause"></i>
        <i class="fa fa-forward forward-button" title="Forward 30s"></i>

        <span class="speed-toggle" title="Playback speed">1x</span>
      </div>

      <div class="buttons">
        <i class="fa fa-list chaptermarks-button" title="Show chaptermarks"></i>
        <i class="fa fa-info more-info-button" title="Show more info"></i>
        <span class="chromecast-ui">
          <img class="chromecast-button" title="Play on chromecast" src="samples/chromcast.png"/>
          <span class="chromecast-receiver"></span>
        </span>
      </div>
      <div class="chaptermarks"></div>
      <div class="more-info">{{description}}</div>
    </div>
    """
