TinyColor = require('tinycolor2')

CustomStyles = require('./custom_styles.coffee')
Ie11CustomProperties = require('ie11-custom-properties')

class CustomStylesV2 extends CustomStyles
 buildCSS: () =>
    colors = @buildColors()
    "
      :root {
        --main-player-color: #{@primary};
        --main-player-light-color: #{@lightColor};
        --player-contrast-text: #{@contrastText};
      }
    "

  buildColors: () =>
    @primary = new TinyColor(@config.main || '#db4615')
    @lightColor = @primary.clone().brighten(50)
    @contrastText = new TinyColor('#fff')
    if TinyColor.readability(@config.main, "#fff") < 3.5
      @contrastText = new TinyColor('#000')

module.exports = CustomStylesV2
