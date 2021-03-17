$ = require('jquery')
_ = require('lodash')
sightglass = require('sightglass')
rivets = require('rivets')
Uri = require('urijs')

Extension = require('../extension.coffee')

class ExtraOptionsV2 extends Extension
  @extension:
    name: 'Subscribe'
    type: 'menu'

  constructor: (app) ->
    super(app)
    return unless @isEnabled()
    @type = 'menu'

    @buildContext()

    @renderPanel()
    @renderButton()
    @renderPanelTabs()
    @bindEvents()

    @app.theme.addExtension(this)

  destroy: () ->
    @panelTabs?.empty()

  defaultOptions:
    showOnStart: false

  isEnabled: () =>
    @chapterMarksEnabled() or @episodeInfoEnabled() or @playlistEnabled() or @transcriptEnabled()

  buildContext: =>
    @context ?= {}
    @context.chapterMarksEnabled = @chapterMarksEnabled()
    @context.episodeInfoEnabled = @episodeInfoEnabled()
    @context.playlistEnabled = @playlistEnabled()
    @context.transcriptEnabled = @transcriptEnabled()

  chapterMarksEnabled: =>
    !@app.extensionOptions?.ChapterMarks?.disabled and @app.episode?.chaptermarks && @app.episode?.chaptermarks?.length

  episodeInfoEnabled: =>
    !@app.extensionOptions?.EpisodeInfo?.disabled and @app.episode?.description

  playlistEnabled: =>
    !@app.extensionOptions?.Playlist?.disabled and @app.podcast?.hasEpisodes()

  transcriptEnabled: =>
    !@app.extensionOptions?.Transcript?.disabled and @app.episode?.transcript

  bindEvents: =>
    @panelTabs.find('.chaptermarks-tab-button').on 'click', =>
      @tooglePanelWithClass('.chaptermarks')
    @panelTabs.find('.all-episodes-tab-button').on 'click', =>
      @tooglePanelWithClass('.playlist')
    @panelTabs.find('.episode-info-tab-button').on 'click', =>
      @tooglePanelWithClass('.episode-info')
    @panelTabs.find('.transcript-tab-button').on 'click', =>
      @tooglePanelWithClass('.transcript')

  tooglePanelWithClass: (className) =>
    @app.theme.togglePanel(@app.elem.find(className))

  renderPanelTabs: =>
    @panelTabs = $(@panelTabsHtml())
    @viewTabs = rivets.bind(@panelTabs, @context)
    panels = @app.theme.elem.find('.panels')
    @panelTabs.insertBefore(panels)

  renderPanel: =>
    @panel = $(@panelHtml())
    @view = rivets.bind(@panel, @context)
    @panel.hide()

  buttonHtml: ->
    """
      <button
          class="more-menu-button list-button"
          title="More"
          aria-label="More"
      >
        <p>
          <span></span>
          <span></span>
          <span></span>
        </p>
      </button>
    """

  panelHtml: ->
    """
      <div class="more-menu">
      </div>
    """

  panelTabsHtml: ->
    """
      <div class="panels-tabs">
        <div class="panels-tabs-menu">
          <ul>
            <li class="playlist-open-el" pp-if="playlistEnabled">
              <button class="panels-tab-button all-episodes-tab-button" title=" #{@t('menu.allEpisodes')}" aria-label=" #{@t('menu.allEpisodes')}">
                #{@t('menu.allEpisodes')}
              </button>
            </li>
            <li class="episode-info-open-el" pp-if="episodeInfoEnabled">
              <button class="panels-tab-button episode-info-tab-button" title="#{@t('menu.episodeInfo')}" aria-label="#{@t('menu.episodeInfo')}">
                #{@t('menu.episodeInfo')}
              </button>
            </li>
            <li class="transcript-open-el" pp-if="transcriptEnabled">
              <button class="panels-tab-button transcript-tab-button" title="#{@t('menu.transcript')}" aria-label="#{@t('menu.transcript')}">
                #{@t('menu.transcript')}
              </button>
            </li>
            <li class="chaptermarks-open-el" pp-if="chapterMarksEnabled">
              <button class="panels-tab-button chaptermarks-tab-button" title="#{@t('menu.chaptermarks')}" aria-label="#{@t('menu.chaptermarks')}">
                #{@t('menu.chaptermarks')}
              </button>
            </li>
          </ul>
        </div>
      </div>
    """

module.exports = ExtraOptionsV2
