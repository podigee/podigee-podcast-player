$ = require('jquery')

AudioFile = require('./audio_file.coffee')

class FeedItem
  constructor: (@xml) ->
    @media = {}
    @parse()

  parse: () =>
    @title = @extract('title').html()
    @subtitle = @extract('subtitle').html() ||
      @extract('itunes\\:subtitle').html()
    @href = @extract('link').html()
    @enclosure = @mapEnclosure()
    @description = @extract('description')
      .html()
      .match(/<!\[CDATA\[([\s\S]*)]]>$/)[1]

  extract: (elemName) =>
    @[elemName] ?= $(@xml).find(elemName)

  mapEnclosure: () =>
    enclosure = @extract('enclosure')
    url = enclosure.attr('url')
    type = enclosure.attr('type')
    @media[@enclosureMapping(type)] = url
    @media

  enclosureMapping: (type) ->
    {
      'audio/aac': 'm4a',
      'audio/mp4': 'm4a',
      'audio/mpeg': 'mp3',
      'audio/ogg; codecs="vorbis"': 'ogg',
      'audio/ogg; codecs="opus"': 'opus',
    }[type]

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
