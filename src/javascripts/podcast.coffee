$ = require('jquery')
_ = require('lodash')

Feed = require('./feed.coffee')

class Podcast
  constructor: (@app, @attributes) ->
    @assignAttributes()
    @feed = if @attributes.feed?
      new Feed(@app, @attributes.feed)

  assignAttributes: () ->
    @title = @attributes.title
    @subtitle = @attributes.subtitle
    @url = @attributes.url
    @connections = @attributes.connections

  forTheme: () ->
    {
      podcastTitle: @title,
      podcastSubtitle: @subtitle,
      podcastUrl: @url,
      podcastConnections: @connections
    }

  feed: null

  hasEpisodes: ->
    (@attributes.episodes? && @attributes.episodes.length) ||
      @feed?

  episodes: []
  getEpisodes: () ->
    if @attributes.episodes? && @attributes.episodes.length
      deferred = $.Deferred()
      @episodes = @attributes.episodes
      deferred.resolve()
      deferred.promise()
    else if @feed?
      self = this
      feedResult = @feed.fetch()
      feedResult.promise.done (episodes) ->
        self.episodes = feedResult.episodes
      feedResult.promise
    else
      deferred = $.Deferred()
      deferred.resolve()
      deferred.promise()

module.exports = Podcast
