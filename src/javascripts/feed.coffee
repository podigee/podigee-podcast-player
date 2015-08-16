$ = require('../../vendor/javascripts/jquery.1.11.0.min.js')

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
