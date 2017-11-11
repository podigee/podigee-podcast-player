$ = require('jquery')

AudioFile = require('./audio_file.coffee')

class FeedItem

  constructor: (@xml, @podcastCoverUrl) ->
    true

  episodeAttributes: ->
    title: @_extract('title').html()
    subtitle: @_findSubtitle()
    href: @_extract('link').html()
    url: @_extract('link').html()
    media: @_mapEnclosure()
    description: @_cleanDescription(@_extract('description').html())
    duration: parseInt(@_extract('duration').text(), 10)
    coverUrl: @_extract('image').attr('href') || @podcastCoverUrl

    number: null
    chaptermarks: null
    embedCode: null

  _extract: (elemName) =>
    @[elemName] ?= $(@xml).find(elemName)

  _findSubtitle: () ->
    @_extract('subtitle').html()

  _cleanDescription: (description) ->
    if description.match(/^<!/)
      description.match(/<!\[CDATA\[([\s\S]*)]]>$/)[1]
    else
      description

  _mapEnclosure: () =>
    media = {}
    enclosure = @_extract('enclosure')
    url = enclosure.attr('url')
    type = enclosure.attr('type')
    media[@_enclosureMapping(type)] = url
    media

  _enclosureMapping: (type) ->
    {
      'audio/aac': 'm4a',
      'audio/mp4': 'm4a',
      'audio/mpeg': 'mp3',
      'audio/ogg; codecs="vorbis"': 'ogg',
      'audio/ogg; codecs="opus"': 'opus',
    }[type]

class Feed
  constructor: (@app, @feedUrl) ->
    true

  fetch: () ->
    self = this

    @promise = @app.externalData.get(@feedUrl)
    @promise.done (data) ->
      self.episodes = $(data).find('item').map (_, item) ->
        new FeedItem(item, self.podcastCover(data)).episodeAttributes()

    self

  podcastCover: (data) ->
    $(data).find('channel image').first().find('url').text() ||
      $(data).find('channel > image').last().attr('href')


module.exports = Feed
