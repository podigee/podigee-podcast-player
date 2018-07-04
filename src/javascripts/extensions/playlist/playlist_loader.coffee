class PlaylistLoader
  constructor: (@app) ->
    @currentPage = 0

  loadEpisodes: =>
    @app.podcast.getEpisodes()

  loadNextPage: =>
    @loadPage(@nextPage()).done =>
      @currentPage += 1

  loadPage: (page) =>
    @app.podcast.fetchEpisodes(null, page)

  hasPlaylistUrl: () =>
    @app.podcast.playlistUrl?

  nextPage: () =>
    @currentPage + 1

module.exports = PlaylistLoader
