class PodiChaptermark
  constructor: (data, callback) ->
    @data = data
    @callback = callback

  render: =>
    template = Handlebars.compile(@defaultHtml)
    $(template(@data)).on('click', null, @data, @callback)

  defaultHtml:
    """
    <li data-start="{{start}}">
      {{#if image}}
        <img src="{{image}}" />
      {{/if}}
      {{title}}
    </li>
    """
