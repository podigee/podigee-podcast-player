$ = require('jquery')
EpisodeInfo = require('../extensions/episode_info.coffee')

class EpisodeInfoV2 extends EpisodeInfo
  buttonHtml: =>
    """
      <button class="episode-info-button" title="#{@t('menu.episodeInfo')}" aria-label="#{@t('menu.episodeInfo')}">#{@t('menu.episodeInfo')}</button>
    """

module.exports = EpisodeInfoV2
