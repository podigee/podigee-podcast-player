# Podigee Podcast Player

The Podigee Podcast Player is a state of the art web audio player specially crafted for listening to podcasts.

[Demo](https://podigee.github.com/podigee-podcast-player "Podigee Podcast Player Demo")

- [Features](#features)
- [Themes](#themes)
- [Extensions](#extensions)
- [Compatibility](#compatibility)
- [Usage](#usage)
- [Configuration options](#configuration-options)
- [Who did this?](#who)
- [Contribute](#contribute)
- [License](#license)

## Features

The PPP at it's core is an **embeddable HTML5 audio player**. It supports **theming**, **extensions** and **unicorns**.

## Themes

The player is completely themeable, you can even change the markup! It comes with a responsive default theme.

## Extensions

The player is extensible and ships with the following default extensions:

### Sharing

This holds sharing options for different social networks, direct link sharing and the embed code.

### Chaptermarks

If the podcaster supplies chaptermarks for an episode listeners can will see where in the episode they currently are and jump to a chaptermark with a click or tap.

### Episodeinfo

Displays the episode title and description for the episode.

### Playlist

Displays a list of podcast episodes based on as standard podcast RSS feed.

### Transcript

Displays the transcript of an episode, highlights the currently spoken words and allows the listener to search and jump to certain passages by clicking or tapping.

### Waveform (experimental)

Given [the right waveform input data](https://github.com/bbcrd/audiowaveform) the player can render a nice waveform whereever the theme has foreseen a place for it (Note: the default theme will not display it).

### Chromecast (experimental)

Allows the listener to play the podcast episode on a Chromecast device. This is currently not enabled by default, because it's still in testing and requires a little polishing work.

## Compatibility

We aim to always support the latest 2-3 versions of modern browsers. Internet Explorer is fully supported from version 11 on. Version 9 is not officially supported, but basic playback should work fine there too.

## Usage

```javascript
window.playerConfiguration = {
  "options": {
    "theme": "default"
  },
  "extensions": {
    "ChapterMarks": {
      "showOnStart": false
    },
    "EpisodeInfo": {
      "showOnStart": false
    },
    "Playlist": {
      "showOnStart": false,
      "disabled": true
    },
    "Transcript": {
      "showOnStart": false,
      "data": "https://cdn.podigee.com/ppp/samples/transcript.txt"
    },
    "Waveform": {
      "color": "rgba(100, 149, 237, 0.3)",
      "data": "https://cdn.podigee.com/ppp/samples/waveform.json",
    }
  },
  "podcast": {
    "feed": "https://cdn.podigee.com/ppp/samples/feed.xml",
  },
  "episode": {
    "media": {
      "mp3": "https://cdn.podigee.com/ppp/samples/media.mp3",
      "m4a": "https://cdn.podigee.com/ppp/samples/media.m4a",
      "ogg": "https://cdn.podigee.com/ppp/samples/media.ogg",
      "opus": "https://cdn.podigee.com/ppp/samples/media.opus"
    },
    "coverUrl": "https://cdn.podigee.com/ppp/samples/cover.jpg",
    "title": "FG009 Wirtschaftspolitischer Journalismus",
    "subtitle": "Wie Henrik Müller in Dortmund wirtschaftspolitischen Journalismus lehrt und erforscht. Und was guten Wirtschaftsjournalismus ausmacht.",
    "url": "http://forschergeist.de/podcast/fg009-wirtschaftspolitischer-journalismus/",
    "embedCode": "<script class=\"podigee-podcast-player\" src=\"https://cdn.podigee.com/podcast-player/javascripts/podigee-podcast-player.js\" data-configuration=\"https://podigee.github.io/podigee-podcast-player/example/config.json\"><\/script>",
    "description": "Raus aus der prallen journalistischen Praxis, rein in die Gremien-Universität. Henrik Müller hat diesen ungewöhnlichen Schritt gewagt: 2013 übernahm der damalige stellvertretende Chefredakteur des "manager magazin" den Lehrstuhl für wirtschaftspolitischen Journalismus am Institut für Journalistik der Technischen Universität Dortmund. Dort baut er seitdem die neuen Bachelor- und Master-Studiengänge für wirtschaftspolitischen Journalismus auf. Wie er diesen Wechsel zwischen den  Welten erlebt hat, was er seinen Studierenden vermitteln will und woran er forscht, erzählt der immer noch sehr umtriebige Autor ("Wirtschaftsirrtümer: 50 Denkfehler, die uns Kopf und Kragen kosten") und Spiegel-Online-Kolumnist in dieser anregenden Episode. Dabei geht es darum, was Wirtschaftsjournalismus leisten soll und muss, was Studierende erst mühsam über Lobbyismus lernen müssen und was eigentlich "gute Geschichten" sind.",
    "chaptermarks": [
      {"start": "00:00:00.000", "title": "Intro"},
      {"start": "00:00:41.018", "title": "Begrüßung"},
      {"start": "00:01:30.542", "title": "Vorstellung"},
      {"start": "00:05:48.377", "title": "Aufgaben des Wirtschaftsjournalismus"},
      {"start": "00:10:29.462", "title": "Neuer Studiengang"},
      {"start": "00:13:50.076", "title": "Wechsel von der Wirtschaft in die Wissenschaft"},
      {"start": "00:20:13.397", "title": "Inhalte des Studiums"},
      {"start": "00:25:37.755", "title": "Herdentrieb im Journalismus und gute Geschichten"},
      {"start": "00:32:40.790", "title": "Onlinejournalismus"},
      {"start": "00:36:12.318", "title": "Herausforderungen und Chancen für junge Journalisten"},
      {"start": "00:41:01.342", "title": "Multimediale Ausbildung"},
      {"start": "00:43:11.011", "title": "Datenjournalismus"},
      {"start": "00:46:34.093", "title": "Politischer Wirtschaftsjournalismus"},
      {"start": "00:50:28.321", "title": "Kooperationspartner und praktisches Studium"},
      {"start": "00:56:02.258", "title": "Lobbyismus"},
      {"start": "00:58:07.342", "title": "Spannungsfeld PR"},
      {"start": "01:00:44.639", "title": "Wirtschaftsirrtümer"},
      {"start": "01:04:09.361", "title": "Forschungsprojekte"},
      {"start": "01:14:56.559", "title": "Andere Studiengänge in Europa"},
      {"start": "01:20:54.085", "title": "Ausklang"}
    ]
  }
}
```

```html
<script class="podigee-podcast-player" src="cdn.podigee.com/podcast-player/javascripts/podigee-podcast-player.js" data-configuration="playerConfiguration"></script>
```

## Configuration options

The configuration passed into the player either as a Javascript Object or as a JSON file has the following options:

### General options

`options.theme` - The name of the theme to use (defaults to `default`)

### Podcast

`podcast` - An object containing information about the podcast

`podcast.feed` - The podcast's feed address

### Episode

`episode` - An object containing information about the episode

`episode.title` - The episode title

`episode.subtitle` - The episode subtitle

`episode.description` - The episode description / shownotes

`episode.coverUrl` - An URL pointing to the episode cover

`episode.url` - An URL pointing the episode webpage

`episode.embedCode` - This overrides the default embed code (normally you don't need this)

`episode.media` - An object containing media files for an episode (see below)

`episode.chaptermarks` - An object containing chaptermark information (see below)

### Episode media

This is an object containing one or more mappings of audio format to url. For example:

`episode.media.mp3` - The URL to play the MP3 version of the episode

### Chaptermarks

This is an object containing zero or more chaptermarks in the following format:

`episode.chaptermarks[0].start` - Starting time of the chapter

`episode.chaptermarks[0].title` - Title of the chapter

`episode.chaptermarks[0].image` - URL to a chapter image

`episode.chaptermarks[0].href` - URL to an external page

### Extension options

`extensions` - An object containing configuration for different extensions

## Who

We are [Podigee](https://www.podigee.com "The Podcast Hosting Platform"), an awesome Podcast Hosting Platform.

## Contribute

If you would like to propose new features or have found a bug, please use [Github issues](https://github.com/podigee/podigee-podcast-player/issues) to tell us.

If you would like to help us improve the player please [get in touch with us](mailto:hello@podigee.com).

## License

[MIT](https://github.com/podigee/podigee-podcast-player/blob/master/LICENSE)
