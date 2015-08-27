$ = require('jquery')

class Feed
  constructor: (@feedUrl) ->
    @fetch()

  fetch: () ->
    self = this
    @promise = $.get @feedUrl, (data) ->
      self.feed = $(data)
      self.items = self.feed.find('item')

    self

module.exports = Feed
