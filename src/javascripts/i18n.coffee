class I18n
  # List of locales that follow BCP-47
  SUPPORTED_LOCALES = ['en-US', 'de-DE', 'es-ES', 'nl-NL']
  # E.g a user with en-GB will get the language 'en'
  # The languages are in ISO 639-1
  SUPPORTED_LANGUAGES = ['en', 'de', 'es', 'nl']

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
      when "es" then "es-ES"
      when "nl" then "nl-NL"

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
        load_more: 'Load more episodes'
      progress_bar:
        switch_time_mode: 'Switch time display mode'
      share:
        copy_episode_link: 'Copy episode link'
        email: 'Email'
        embed_player: 'Embed player'
        episode: 'Episode'
        episode_url: 'Share link to episode'
        start_at: 'Start at'
      theme:
        playPause: 'Play'
        play: 'Play'
        pause: 'Pause'
        backward: 'Backward 10s'
        forward: 'Forward 30s'
        changePlaybackSpeed: 'Change Playback Speed'
      transcript:
        search: 'Search in transcript'
        show: 'Show transcription'
        title: 'Transcription'
      subscribeBar:
        allEpisodes: 'All Episodes'
        podcastOnItunes: 'View Podcast on Apple Podcasts'
        podcastOnSpotify: 'View Podcast on Spotify'
        podcastOnDeezer: 'View Podcast on Deezer'
        podcastOnAlexa: 'View Podcast on Alexa'
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
        load_more: 'Mehr Episoden laden'
      progress_bar:
        switch_time_mode: 'Anzeigemodus ändern'
      share:
        copy_episode_link: 'Link zur Episode kopieren'
        email: 'E-Mail'
        embed_player: 'Player einbetten'
        episode: 'Episode'
        episode_url: 'Link zur Episode teilen'
        start_at: 'Wiedergabe ab'
      theme:
        playPause: 'Play'
        play: 'Play'
        pause: 'Pause'
        backward: '10s zurück'
        forward: '30s vorwärts'
        changePlaybackSpeed: 'Abspielgeschwindigkeit ändern'
      transcript:
        search: 'Transkript durchsuchen'
        show: 'Transkript anzeigen'
        title: 'Transkript'
      subscribeBar:
        allEpisodes: 'Alle Episoden'
        podcastOnItunes: 'Podcast auf Apple Podcasts ansehen'
        podcastOnSpotify: 'Podcast auf Spotify ansehen'
        podcastOnDeezer: 'Podcast auf Deezer ansehen'
        podcastOnAlexa: 'Podcast auf Alexa ansehen'
        subscribe: 'Abonnieren'

    'es-ES':
      chaptermarks:
        show: 'Marca temporal'
        title: 'Marcas temporales'
      chromecast:
        play: 'Reproducir en chromecast'
      download:
        episode: 'Descargar capítulo'
      episode_info:
        more_info: 'Mostrar más informaciones'
        title: 'Informaciones del capítulo'
      playlist:
        show: 'Mostrar lista de reproducción'
        title: 'Lista de reproducción'
        load_more: 'Más capítulos'
      progress_bar:
        switch_time_mode: 'Cambiar el modo de visualización'
      share:
        copy_episode_link: 'Copiar enlace del capítulo'
        email: 'Correo electrónico'
        embed_player: 'Embed del reproductor'
        episode: 'Capítulo'
        episode_url: 'Compartir enlace del capítulo'
        start_at: 'Empezar en'
      theme:
        playPause: 'Reproducir'
        play: 'Reproducir'
        pause: 'Pausar'
        backward: 'Rebobinar 10s'
        forward: 'Avanzar 30s'
        changePlaybackSpeed: 'Cambiar velocidad de reproducción'
      transcript:
        search: 'Buscar en transcripción'
        show: 'Mostrar transcripción'
        title: 'Transcripción'
      subscribeBar:
        allEpisodes: 'Todos los capítulos'
        podcastOnItunes: 'Ver podcast en Apple Podcasts'
        podcastOnSpotify: 'Ver podcast en Spotify'
        podcastOnDeezer: 'Ver podcast en Deezer'
        podcastOnAlexa: 'Ver podcast en Alexa'
        subscribe: 'Suscríbete'
       
    'nl-NL':
      chaptermarks:
        show: 'Toon hoofdstukmarkeringen'
        title: 'Hoofdstukmarkeringen'
      chromecast:
        play: 'Speel af op chromecast'
      download:
        episode: 'Download aflevering'
      episode_info:
        more_info: 'Toon meer info'
        title: 'Aflevering info'
      playlist:
        show: 'Toon afspeellijst'
        title: 'Afspeellijst'
        load_more: 'Laad meer afleveringen'
      progress_bar:
        switch_time_mode: 'Verander tijdweergave'
      share:
        copy_episode_link: 'Kopieër link naar aflevering'
        email: 'E-mail'
        embed_player: 'Embed speler'
        episode: 'Aflevering'
        episode_url: 'Deel link naar aflevering'
        start_at: 'Begin op'
      theme:
        playPause: 'Afspelen'
        play: 'Afspelen'
        pause: 'Pauzeren'
        backward: 'Terug 10s'
        forward: 'Vooruit 30s'
        changePlaybackSpeed: 'Verander afspeelsnelheid'
      transcript:
        search: 'Zoek in transcript'
        show: 'Toon transcriptie'
        title: 'Transcriptie'
      subscribeBar:
        allEpisodes: 'Alle Afleveringen'
        podcastOnItunes: 'Toon Podcast op Apple Podcasts'
        podcastOnSpotify: 'Toon Podcast op Spotify'
        podcastOnDeezer: 'Toon Podcast op Deezer'
        podcastOnAlexa: 'Toon Podcast op Alexa'
        subscribe: 'Abonneer'

module.exports = I18n
