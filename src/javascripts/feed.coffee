$ = require('jquery')

class FeedItem
  constructor: (@xml) ->
    @parse()

  parse: () =>
    @title = @extract('title').html()
    @subtitle = @extract('subtitle').html()
    @href = @extract('link').html()
    @enclosure = @extract('enclosure').attr('url')
    @description = @extract('description').html()

  extract: (elemName) =>
    $(@xml).find(elemName)

class Feed
  constructor: (@feedUrl) ->
    @fetch()

  fetch: () ->
    self = this
    @promise = $.get @feedUrl, (data) ->
      self.feed = $(data)
      self.items = self.feed.find('item').map (_, item) -> new FeedItem(item)

    self

module.exports = Feed
