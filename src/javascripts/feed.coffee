$ = require('jquery')

AudioFile = require('./audio_file.coffee')

class FeedItem
  constructor: (@xml) ->
    @parse()

  parse: () =>
    @title = @extract('title').html()
    @subtitle = @extract('subtitle').html()
    @href = @extract('link').html()
    @enclosure = @mapEnclosure()
    @description = @extract('description').html()

  extract: (elemName) =>
    @[elemName] ?= $(@xml).find(elemName)

  mapEnclosure: () =>
    enclosure = @extract('enclosure')
    url = enclosure.attr('url')
    type = enclosure.attr('type')
    media = {}
    media[@enclosureMapping(type)] = url
    media

  enclosureMapping: (type) ->
    AudioFile.reverseFormatMapping[type]

class Feed
  constructor: (app) ->
    unless app.podcast.feed.constructor == Feed
      @feedUrl = app.podcast.feed
      @externalData = app.externalData
      @fetch()
    else
      @feed = app.podcast.feed.feed
      @items = app.podcast.feed.items
      deferred = $.Deferred()
      @promise = deferred.promise()
      deferred.resolve()

  fetch: () ->
    self = this

    @promise = @externalData.get(@feedUrl)
    @promise.done (data) ->
      self.feed = data
      self.items = $(self.feed).find('item').map (_, item) -> new FeedItem(item)

    self

module.exports = Feed
