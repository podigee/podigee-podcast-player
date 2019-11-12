$ = require('jquery')

# This serves as an example as well as the base class for extionsions

class Extension
  @extension:
    name: 'Extension'
    type: 'default'

  constructor: (@app) ->

  defaultOptions: {}

  destroy: => return

  renderButton: =>
    @button = $(@buttonHtml())
    @button.on 'click', =>
      @app.theme.togglePanel(@panel)

  renderPanel: =>
    @panel = $(@panelHtml())
    @panel.hide()

  t: (key) -> @app.i18n.t(key)

  buttonHtml: ->
    """
    <button class="fa fa-bookmark" title="Show example extension"></button>
    """

  panelHtml: ->
    """
    <div class="example">
      <h3>Example</h3>

      <p>This is an example</p>
    </div>
    """

  name: -> @constructor.extension.name

module.exports = Extension
