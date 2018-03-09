class I18n
  # List of locales that follow BCP-47
  SUPPORTED_LOCALES = ['en-US', 'de-DE']
  # E.g a user with en-GB will get the language 'en'
  # The languages are in ISO 639-1
  SUPPORTED_LANGUAGES = ['en', 'de']

  # locale<string> BCP-47, e.g. "en-US", can be nil
  # defaultLocale<string> BCP-47, e.g. "de-DE", should not be nil
  # if locale is nil, the locale will be computed, falling back to defaultLocale
  constructor: (@locale, @defaultLocale) ->
    @locale ||= @locale || @getLocale()
    true

  getLocale: ->
    preferredLocale = @getUserPreferredLocale()
    preferredLanguage = @getLanguageFromLocale(preferredLocale)
    bestLocale = @getLocaleForLanguage(preferredLanguage)

    bestLocale || @defaultLocale

  # private

  getUserPreferredLocale: ->
    navigator.language || navigator.userLanguage

  # locale<string>, e.g. "en-US", format: BCP-47
  getLanguageFromLocale: (locale) ->
    locale.substring(0, 2)

  # language<string>, e.g. "en", format: ISO 639-1
  # for now, it's pretty simple
  getLocaleForLanguage: (language) ->
    switch language
      when "en" then "en-US"
      when "de" then "de-DE"

  t: (key) ->
    keys = key.split('.')

    value = @translationMap[@locale]
    for k in keys
      value = value[k]

    if value
      value
    else
      key

  translationMap:
    'en-US':
      chaptermarks:
        show: 'Show chaptermarks'
        title: 'Chaptermarks'
      chromecast:
        play: 'Play on chromecast'
      download:
        episode: 'Download episode'
      episode_info:
        more_info: 'Show more info'
        title: 'Episode info'
      playlist:
        show: 'Show playlist'
        title: 'Playlist'
      share:
        copy_episode_link: 'Copy episode link'
        email: 'Email'
        embed_player: 'Embed player'
        episode: 'Episode'
        episode_url: 'Share link to episode'
        start_at: 'Start at'
      theme:
        playPause: 'Play/Pause'
        backward: 'Backward 10s'
        forward: 'Forward 30s'
        changePlaybackSpeed: 'Change Playback Speed'
      transcript:
        search: 'Search in transcript'
        show: 'Show transcription'
        title: 'Transcription'
      subscribeBar:
        allEpisodes: 'All Episodes'
        podcastOnItunes: 'View Podcast on iTunes'
        podcastOnSpotify: 'View Podcast on Spotify'
        podcastOnDeezer: 'View Podcast on Deezer'
        subscribe: 'Subscribe'

    'de-DE':
      chaptermarks:
        show: 'Kapitelmarken anzeigen'
        title: 'Kapitelmarken'
      chromecast:
        play: 'Auf Chromecast abspielen'
      download:
        episode: 'Episode herunterladen'
      episode_info:
        more_info: 'Mehr Infos anzeigen'
        title: 'Episoden-Infos'
      playlist:
        show: 'Wiedergabeliste anzeigen'
        title: 'Wiedergabeliste'
      share:
        copy_episode_link: 'Link zur Episode kopieren'
        email: 'E-Mail'
        embed_player: 'Player einbetten'
        episode: 'Episode'
        episode_url: 'Link zur Episode teilen'
        start_at: 'Wiedergabe ab'
      theme:
        playPause: 'Play/Pause'
        backward: '10s zurück'
        forward: '30s vorwärts'
        changePlaybackSpeed: 'Abspielgeschwindigkeit ändern'
      transcript:
        search: 'Transkript durchsuchen'
        show: 'Transkript anzeigen'
        title: 'Transkript'
      subscribeBar:
        allEpisodes: 'Alle Episoden'
        podcastOnItunes: 'Podcast auf iTunes ansehen'
        podcastOnSpotify: 'Podcast auf Spotify ansehen'
        podcastOnDeezer: 'Podcast auf Deezer ansehen'
        subscribe: 'Abonnieren'

module.exports = I18n
