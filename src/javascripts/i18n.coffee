class I18n
  # List of locales that follow BCP-47
  SUPPORTED_LOCALES = ['en-US', 'de-DE', 'es-ES', 'nl-NL', 'pl-PL']
  # E.g a user with en-GB will get the language 'en'
  # The languages are in ISO 639-1
  SUPPORTED_LANGUAGES = ['en', 'de', 'es', 'nl', 'pl']

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
      when "pl" then "pl-PL"

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
        copy_embed_code: 'Copy embed code'
        email: 'Email'
        embed_player: 'Embed player'
        episode: 'Episode'
        episode_url: 'Share link to episode'
        start_at: 'Start at'
        title: 'Share'
      theme:
        playPause: 'Play'
        play: 'Play'
        pause: 'Pause'
        backward: 'Backward 10s'
        forward: 'Forward 30s'
        changePlaybackSpeed: 'Change Playback Speed'
        previous: 'Previous episode'
        next: 'Next episode'
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
        podcastOnPodimo: 'View Podcast on Podimo'
        podcastOnGoogle: 'View Podcast on Google'
        rssCopy: 'Copy RSS link'
        subscribe: 'Subscribe'
      splash:
        playEpisode: 'Play episode'
      menu:
        chaptermarks: 'Chaptermarks'
        transcript: 'Transcript'
        episodeInfo: 'Episode info'
        allEpisodes: 'All Episodes'
      podigee:
        title: 'Start podcasting with Podigee'

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
        copy_embed_code: 'Link zum Einbetten kopieren'
        email: 'E-Mail'
        embed_player: 'Player einbetten'
        episode: 'Episode'
        episode_url: 'Link zur Episode teilen'
        start_at: 'Wiedergabe ab'
        title: 'Teilen'
      theme:
        playPause: 'Play'
        play: 'Play'
        pause: 'Pause'
        backward: '10s zurück'
        forward: '30s vorwärts'
        changePlaybackSpeed: 'Abspielgeschwindigkeit ändern'
        previous: 'Vorherige Episode'
        next: 'Nächste Episode'
      transcript:
        search: 'Transkript durchsuchen'
        show: 'Transkript anzeigen'
        title: 'Transkript'
      subscribeBar:
        allEpisodes: 'Alle Episoden'
        podcastOnItunes: 'Podcast auf Apple Podcasts anhören'
        podcastOnSpotify: 'Podcast auf Spotify anhören'
        podcastOnDeezer: 'Podcast auf Deezer anhören'
        podcastOnAlexa: 'Podcast auf Alexa anhören'
        podcastOnPodimo: 'Podcast auf Podimo anhören'
        podcastOnGoogle: 'Podcast auf Google anhören'
        rssCopy: 'RSS-Link kopieren'
        subscribe: 'Abonnieren'
      splash:
        playEpisode: 'Episode abspielen'
      menu:
        chaptermarks: 'Kapitelmarken'
        transcript: 'Transkript'
        episodeInfo: 'Episodeninfo'
        allEpisodes: 'Alle Episoden'
      podigee:
        title: 'Podcast erstellen mit Podigee'

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
        copy_embed_code: 'Copiar enlace de incrustación'
        email: 'Correo electrónico'
        embed_player: 'Embed del reproductor'
        episode: 'Capítulo'
        episode_url: 'Compartir enlace del capítulo'
        start_at: 'Empezar en'
        title: 'Compartir'
      theme:
        playPause: 'Reproducir'
        play: 'Reproducir'
        pause: 'Pausar'
        backward: 'Rebobinar 10s'
        forward: 'Avanzar 30s'
        changePlaybackSpeed: 'Cambiar velocidad de reproducción'
        previous: 'Episodio anterior'
        next: 'Próximo episodio'
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
        podcastOnPodimo: 'Ver podcast en Podimo'
        podcastOnGoogle: 'Ver podcast en Google'
        rssCopy: 'Copiar enlace RSS'
        subscribe: 'Suscríbete'
      splash:
        playEpisode: 'Reproducir episodio'
      menu:
        chaptermarks: 'Marcas capitulares'
        transcript: 'Transcripción'
        episodeInfo: 'Información del episodio'
        allEpisodes: 'Todos los capítulos'
      podigee:
        title: 'Empieza a hacer podcasting con Podigee'

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
        copy_embed_code: 'Kopieër embed link'
        email: 'E-mail'
        embed_player: 'Embed speler'
        episode: 'Aflevering'
        episode_url: 'Deel link naar aflevering'
        start_at: 'Begin op'
        title: 'Aandeel'
      theme:
        playPause: 'Afspelen'
        play: 'Afspelen'
        pause: 'Pauzeren'
        backward: 'Terug 10s'
        forward: 'Vooruit 30s'
        changePlaybackSpeed: 'Verander afspeelsnelheid'
        previous: 'Vorige aflevering'
        next: 'Volgende aflevering'
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
        podcastOnPodimo: 'Toon Podcast op Podimo'
        podcastOnGoogle: 'Toon Podcast op Google'
        rssCopy: 'Kopieer de RSS-link'
        subscribe: 'Abonneer'
      splash:
        playEpisode: 'Afspelen'
      menu:
        chaptermarks: 'Chaptermarks'
        transcript: 'Transcript'
        episodeInfo: 'Aflevering info'
        allEpisodes: 'Alle Afleveringen'
      podigee:
        title: 'Begin met podcasten met Podigee'

    'pl-PL':
      chaptermarks:
        show: 'Pokaż znaczniki rozdziałów'
        title: 'Rozdziały'
      chromecast:
        play: 'Odtwórz w chromecast'
      download:
        episode: 'Pobierz odcinek'
      episode_info:
        more_info: 'Pokaż więcej informacji'
        title: 'Informacje o odcinku'
      playlist:
        show: 'Pokaż listę odtwarzania'
        title: 'Lista odtwarzania'
        load_more: 'Załaduj więcej odcinków'
      progress_bar:
        switch_time_mode: 'Przełącz tryb wyświetlania czasu'
      share:
        copy_episode_link: 'Kopiuj link do odcinka'
        copy_embed_code: 'Kopiuj link do osadzenia'
        email: 'E-mail'
        embed_player: 'Osadź odtwarzacz'
        episode: 'Odcinek'
        episode_url: 'Udostępnij link do odcinka'
        start_at: 'Rozpocznij od'
        title: 'Udział'
      theme:
        playPause: 'Odtwórz'
        play: 'Odtwórz'
        pause: 'Pauza'
        backward: '10s wstecz'
        forward: '30s do przodu'
        changePlaybackSpeed: 'Zmień prędkość odtwarzania'
        previous: 'Poprzedni odcinek'
        next: 'Następny odcinek'
      transcript:
        search: 'Szukaj w transkrypcji'
        show: 'Pokaż transkrypcję'
        title: 'Transkrypcja'
      subscribeBar:
        allEpisodes: 'Wszystkie odcinki'
        podcastOnItunes: 'Zobacz podcast na Apple Podcasts'
        podcastOnSpotify: 'Zobacz podcast na Spotify'
        podcastOnDeezer: 'Zobacz podcast na Deezer'
        podcastOnAlexa: 'Zobacz podcast na Alexa'
        podcastOnPodimo: 'Zobacz podcast na Podimo'
        podcastOnGoogle: 'Zobacz podcast na Google'
        rssCopy: 'Kopiuj link do RSS'
        subscribe: 'Subskrybuj'
      splash:
        playEpisode: 'Odtwórz odcinek'
      menu:
        chaptermarks: 'Zakładki rozdziałów'
        transcript: 'Transkrypt'
        episodeInfo: 'Informacje o odcinku'
        allEpisodes: 'Wszystkie odcinki'
      podigee:
        title: 'Rozpocznij podcasting z Podigee'

module.exports = I18n
