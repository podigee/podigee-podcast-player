$ = require('jquery')
Playlist = require('../extensions/playlist.coffee')

class PlaylistV2 extends Playlist
  buttonHtml: =>
    """
      <button class="playlist-button" title="#{@t('chaptermarks.show')}" aria-label="#{@t('chaptermarks.show')}">#{@t('menu.allEpisodes')}</button>
    """

module.exports = PlaylistV2
