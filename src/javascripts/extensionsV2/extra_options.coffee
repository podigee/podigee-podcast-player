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
    @type = 'menu'
    super(app)
    return unless @isEnabled()

    @buildContext()

    @renderPanel()
    @renderButton()
    @renderPanelTabs()
    @bindEvents()

    @app.theme.addExtension(this)

  defaultOptions:
    showOnStart: false

  isEnabled: () =>
    @app.extensionOptions.ChapterMarks or
    @app.extensionOptions.EpisodeInfo or
    @app.extensionOptions.Playlist or
    @app.extensionOptions.Transcript

  buildContext: =>
    @context ?= {}
    @context.chapterMarksEnabled = @app.extensionOptions.ChapterMarks
    @context.episodeInfoEnabled = @app.extensionOptions.EpisodeInfo
    @context.playlistEnabled = @app.extensionOptions.Playlist
    @context.transcriptEnabled = @app.extensionOptions.Transcript

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
            <li pp-if="chapterMarksEnabled">
              <button class="panels-tab-button chaptermarks-tab-button" title="#{@t('menu.chaptermarks')}" aria-label="#{@t('menu.chaptermarks')}">
                #{@t('menu.chaptermarks')}
              </button>
            </li>
            <li pp-if="playlistEnabled">
              <button class="panels-tab-button all-episodes-tab-button" title=" #{@t('menu.allEpisodes')}" aria-label=" #{@t('menu.allEpisodes')}">
                #{@t('menu.allEpisodes')}
              </button>
            </li>
            <li pp-if="episodeInfoEnabled">
              <button class="panels-tab-button episode-info-tab-button" title="#{@t('menu.episodeInfo')}" aria-label="#{@t('menu.episodeInfo')}">
                #{@t('menu.episodeInfo')}
              </button>
            </li>
            <li pp-if="transcriptEnabled">
              <button class="panels-tab-button transcript-tab-button" title="#{@t('menu.transcript')}" aria-label="#{@t('menu.transcript')}">
                #{@t('menu.transcript')}
              </button>
            </li>
          </ul>
        </div>
      </div>
    """

module.exports = ExtraOptionsV2
