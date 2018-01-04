$ = require('jquery')
_ = require('lodash')

Feed = require('./feed.coffee')

class Podcast
  constructor: (@app, @attributes) ->
    @title = @attributes.title
    @subtitle = @attributes.subtitle
    @feed = if @attributes.feed?
      new Feed(@app, @attributes.feed)

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
