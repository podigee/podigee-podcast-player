$ = require('jquery')
_ = require('lodash')
elasticlunr = require('elasticlunr')
sightglass = require('sightglass')
rivets = require('rivets')

class TranscriptSearch
  constructor: (@app) ->
    @setupIndex()

  setupIndex: ->
    @index = elasticlunr () ->
      this.addField('time')
      this.addField('speaker')
      this.addField('text')
      this.setRef('timestamp')
    @index.pipeline.reset()

  addLine: (line) ->
    @index.addDoc(line.data)

  find: (query) ->
    @index.search query,
      fields:
        speaker: {boost: 1}
        text: {boost: 1}
      expand: true

  results: []

  initInterface: (transcripts, elem) ->
    searchInterface = elem.find('.search')
    html = @render()
    searchInterface.append(html)
    searchResult = searchInterface.find('.search-result')
    searchInput = searchInterface.find('input')
    searchClear = searchInterface.find('.search-clear')
    searchPrevResult = searchResult.find('.search-result-prev')
    searchNextResult = searchResult.find('.search-result-next')
    searchResultSize = searchResult.find('.search-result-size')

    transcriptLines = elem.find('.transcript-text li')
    elems = []

    nextResult = () =>
      if @currentSearchResultIndex < @results.length
        @currentSearchResultIndex = @currentSearchResultIndex + 1
      else
        @currentSearchResultIndex = 1

      transcripts.scrollToLine(elems[@currentSearchResultIndex - 1])
      @updateSearchResult()

    prevResult = () =>
      if @currentSearchResultIndex > 1
        @currentSearchResultIndex = @currentSearchResultIndex - 1
      else
        @currentSearchResultIndex = @results.length

      transcripts.scrollToLine(elems[@currentSearchResultIndex - 1])
      @updateSearchResult()

    searchInput.on 'keyup', (event) =>
      if event.keyCode == 13
        return nextResult()

      @query = @data.query = event.target.value

      @results = _.sortBy(@find(@query), (r) => parseInt(r.ref, 10))

      transcriptLines.removeClass('search-highlight')

      if @results.length
        elems = @results.map ((result, index) ->
          elem = _.find transcriptLines, (line) =>
            line.dataset.timestamp == result.ref
          elem
        ), @

        $(elems).addClass('search-highlight')

        @updateSearchResult()
        transcripts.scrollToLine(elems[@currentSearchResultIndex - 1])

        searchPrevResult.off('click').on 'click', prevResult
        searchNextResult.off('click').on 'click', nextResult
      else
        @currentSearchResultIndex = 1
        @updateSearchResult()

    searchClear.on 'click', (event) ->
      searchInput.val(null)
      searchInput.trigger('keyup')

  currentSearchResultIndex: 1
  updateSearchResult: ->
    if @results.length
      @data.currentIndex = @currentSearchResultIndex
    else
      @data.currentIndex = 0
    @data.resultCount = @results.length

  data:
    currentIndex: 0
    resultCount: 0
    query: null

  render: ->
    html = $(@html())
    rivets.bind(html, @data)
    html

  t: (key) -> @app.i18n.t(key)

  html: ->
    """
      <div class="search-result" pp-show="query">
        <button class="search-result-prev"></button>
        <span class="search-result-size">{currentIndex}/{resultCount}</span>
        <button class="search-result-next"></button>
      </div>
      <input type="text" class="search-input" placeholder="#{@t('transcript.search')}">
      <button class="search-clear" pp-show="query">&times;</button>
    """
module.exports = TranscriptSearch
