$ = require('../../vendor/javascripts/jquery.1.11.0.min.js')
sightglass = require('../../vendor/javascripts/sightglass.js')
rivets = require('../../vendor/javascripts/rivets.min.js')

class PlaylistItem
  constructor: (context, callback) ->
    @context = context
    @callback = callback

  render: =>
    @elem = $(@defaultHtml)
    rivets.bind(@elem, @context)

    @elem.data('item', @context)
    @elem.on('click', 'img, span', @context, @callback)

    return @elem

  defaultHtml:
    """
    <li>
      <img rv-src="image" rv-if="image" />
      <span>{ title }</span>
      <a rv-if="href" rv-href="href" target="_blank"><i class="fa fa-external-link"></i></a>
    </li>
    """

module.exports = PlaylistItem
