TinyColor = require('tinycolor2')

class CustomStyles
  constructor: (config) ->
    @config = config

  toStyleTag: () =>
    return unless @config
    style = document.createElement('style')
    style.textContent = @buildCSS()
    style

  buildCSS: () =>
    colors = @buildColors()
    "
    .podcast-player {
      background-color: #{@background};
      color: #{@text};
    }

    .podcast-player a,
    .podcast-player .episode-basic-info .episode-title,
    .podcast-player .episode-title a {
      color: #{@primary};
    }

    .podcast-player a:hover,
    .podcast-player .episode-basic-info .episode-title:hover,
    .podcast-player .episode-title a:hover {
      color: #{@primaryHover};
    }

    .podcast-player .buttons button {
      color: #{@text};
    }

    .podcast-player .buttons button:hover,
    .podcast-player .buttons button.button-active {
      color: #{@primary};
    }

    .podcast-player .episode-basic-info .episode-subtitle {
      color: #{@text};
    }

    .podcast-player .controls .play-button {
      border-color: #{@progressBar};
      color: #{@progressBar};
    }

    .podcast-player .controls .play-button:hover {
      border-color: #{@progressBarAlt};
      color: #{@progressBarAlt};
    }

    .podcast-player .progress-bar .progress-bar-rail {
      background: #{@progressBar};
    }

    .podcast-player .progress-bar-played {
      background: #{@primary};
    }

    .podcast-player .progress-bar-loaded {
      background: #{@text};
    }

    .podcast-player .panels {
      color: #{@text};
    }

    .podcast-player .panels .chaptermarks ul li:hover,
    .podcast-player .panels .playlist ul li:hover {
      background-color: #{@backgroundHover};
    }

    .podcast-player .panels .transcript .transcript-text li:hover {
      color: #{@textHover};
    }

    .podcast-player .panels .chaptermarks ul li.active,
    .podcast-player .panels .playlist ul li.active,
    .podcast-player .panels .transcript .transcript-text li.active {
      color: #{@primary};
    }

    .podcast-player .panels .share .share-copy-url,
    .podcast-player .panels .share .share-embed-code {
      border-color: #{@text};
      color: #{@text};
    }

    .podcast-player .footer button {
      border-color: #{@primary};
      color: #{@primary};
    }

    .podcast-player .footer button:hover {
      border-color: #{@primaryHover};
      color: #{@primaryHover};
    }
    "

  buildColors: () =>
    @primary = new TinyColor(@config.primary)
    @primaryHover = @getHoverColor(@primary)
    @background = new TinyColor(@config.background)
    @backgroundHover = @getHoverColor(@background)
    @text = if @config.text
      new TinyColor(@config.text)
    else
      @getContrastColor(@background)
    @textHover = @getHoverColor(@text)
    @progressBar = @getProgressColor(@textHover)
    @progressBarAlt = @getHoverColor(@progressBar)

  getContrastColor: (color) ->
    color = color.clone()
    newColor = color.clone()
    if color.getBrightness() >= 190
      color.darken(70)
    else if color.getBrightness() >= 155 && color.getBrightness() < 190
      color.darken(45)
    else if color.getBrightness() < 155 && color.getBrightness() >= 50
      color.lighten(45)
    else
      color.lighten(70)

  getHoverColor: (color) ->
    color = color.clone()
    newColor = color.clone()
    if color.getBrightness() < 50
      color.lighten(15)
    else
      color.darken(10)

  getProgressColor: (color) ->
    color = color.clone()
    newColor = color.clone()
    if color.getBrightness() < 50
      color.darken(10)
    else
      color.lighten(30)

module.exports = CustomStyles
