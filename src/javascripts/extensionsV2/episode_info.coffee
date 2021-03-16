$ = require('jquery')
EpisodeInfo = require('../extensions/episode_info.coffee')

class EpisodeInfoV2 extends EpisodeInfo
  buttonHtml: =>
    """
      <button class="episode-info-button" title="#{@t('chaptermarks.show')}" aria-label="#{@t('chaptermarks.show')}">#{@t('menu.episodeInfo')}</button>
    """

module.exports = EpisodeInfoV2
