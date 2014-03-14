class PodiChaptermark
  constructor: (data, callback) ->
    @data = data
    @callback = callback

  render: =>
    template = Handlebars.compile(@defaultHtml)
    $(template(@data)).on('click', 'img, span', @data, @callback)

  defaultHtml:
    """
    <li data-start="{{start}}">
      {{#if image}}
        <img src="{{image}}" />
      {{/if}}
      <span>{{title}}</span>
      {{#if href}}
        <a href="{{href}}" target="_blank"><i class="fa fa-external-link"></i></a>
      {{/if}}
    </li>
    """
