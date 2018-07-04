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
    @language = @attributes.language

  forTheme: () ->
    {
      podcastTitle: @title,
      podcastSubtitle: @subtitle,
      podcastUrl: @url,
      podcastConnections: @connections
    }

  feed: null

  hasEpisodes: ->
    # has no episodes attribute at all
    return false unless @attributes.episodes || @feed
    # if the attribute is a string/URL we can fetch episodes later
    return true unless Array.isArray(@attributes.episodes)
    # if it is an array of episodes or if a feed is defined
    @attributes.episodes.length || @feed?

  episodes: []
  getEpisodes: () ->
    if @attributes.episodes? && @attributes.episodes.length
      if Array.isArray(@attributes.episodes)
        deferred = $.Deferred()
        @episodes = @attributes.episodes
        deferred.resolve()
        deferred.promise()
      else
        @playlistUrl = @attributes.episodes
        @fetchEpisodes(@playlistUrl, 0)
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

  fetchEpisodes: (url, page, pageSize) =>
    unless url?
      url = @playlistUrl

    self = this
    pageSize ?= 10
    params = {
      page_size: pageSize,
      offset: pageSize * page
    }
    promise = @app.externalData.get(url, params)
    promise.done (data) ->
      self.episodes = self.episodes.concat(data.episodes)
    promise

module.exports = Podcast
