# Podigee Podcast Player - Configuration

The player is either configured via a JavaScript object present in the same HTML tree as the `<script>` tag or by providing an URL to a JSON configuration file.

## Minimal example

```json
{
  "episode": {
    "media": {"mp3": "https://example.com/episode-1.mp3"},
    "title": "Transcript Test"
  }
}
```

## Full example

```json
{
  "options": {
    "theme": "default",
    "sslProxy": "https://example.com/ssl-proxy/",
    "startPanel": "Transcript"
  },
  "extensions": {
    "ChapterMarks": {},
    "EpisodeInfo": {},
    "Playlist": {},
    "Transcript": {},
    "SubscribeBar": {disabled: true}
  },
  "podcast": {
    "title": "Podcast Title",
    "feed": "https://example.com/feed.xml",
    "episodes": [
     {
      "media": {
        "mp3": "https://example.com/media2.mp3",
        "m4a": "https://example.com/media2.m4a",
        "ogg": "https://example.com/media2.ogg",
        "opus": "https://example.com/media2.opus"
      },
      "coverUrl": "https://example.com/cover.jpg",
      "title": "Episode 2 title",
      "subtitle": "Episode 2 subtitle",
      "url": "http://example.com/episode-2",
      "embedCode": "<script class=\"podigee-podcast-player\" src=\"https://cdn.podigee.com/podcast-player/javascripts/podigee-podcast-player.js\" data-configuration=\"https://example.com/episode-2.json\"><\/script>",
      "description": "Episode 2 description",
      "chaptermarks": [
        {"start": "00:00:00", "title": "First chapter"},
        {"start": "00:01:00", "title": "Second chapter"},
        ...
      ],
      "transcript": "https://example.com/transcript-2.vtt"
    },
    ...
  ],
  },
  "episode": {
    "media": {
      "mp3": "https://example.com/media.mp3",
      "m4a": "https://example.com/media.m4a",
      "ogg": "https://example.com/media.ogg",
      "opus": "https://example.com/media.opus"
    },
    "coverUrl": "https://example.com/cover.jpg",
    "title": "Episode title",
    "subtitle": "Episode subtitle",
    "url": "http://example.com/episode-1",
    "embedCode": "<script class=\"podigee-podcast-player\" src=\"https://cdn.podigee.com/podcast-player/javascripts/podigee-podcast-player.js\" data-configuration=\"https://example.com/episode-1.json\"><\/script>",
    "description": "Episode description",
    "chaptermarks": [
      {"start": "00:00:00", "title": "First chapter"},
      {"start": "00:01:00", "title": "Second chapter"},
      ...
    ],
    "transcript": "https://example.com/transcript.vtt"
  }
}
```

## Configuration options

The configuration passed into the player either as a Javascript Object or as a JSON file has the following options:

### General options

`options.theme` - The name of the theme to use (defaults to `default`)
`options.sslProxy` - URI of an application capable of proxying non-SSL requests
`options.startPanel` - The name of the panel which should be opened on start

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

`episode.transcript` - An URL where the player can fetch a WebVTT transcript file for this episode. If the WebVTT file is on another domain as the player, the [same-origin policy](https://en.wikipedia.org/wiki/Same-origin_policy) applies. You'll need to [enable CORS](http://enable-cors.org/) in order to do so.

### Media

`episode.media` - This is an object containing one or more mappings of audio format to url. For example:

`episode.media.opus` - The URL to play the OPUS version of the episode
`episode.media.m4a` - The URL to play the AAC version of the episode
`episode.media.mp3` - The URL to play the MP3 version of the episode
`episode.media.ogg` - The URL to play the Ogg vorbis version of the episode

(This is also the order in which the player will try to play the files)

### Chaptermarks

`episode.chaptermarks` - This is an object containing zero or more chaptermarks in the following format:

`episode.chaptermarks[0].start` - Starting time of the chapter as timestring (e.g. 00:05:26)

`episode.chaptermarks[0].title` - Title of the chapter

`episode.chaptermarks[0].image` - URL to a chapter image

`episode.chaptermarks[0].href` - URL to an external page

### Extension options

`extensions` - An object containing configuration for different extensions

At the moment extensions only have one option to disable them. The keys for the different extensions are:

`extensions.Chaptermarks`

`extensions.Download`

`extensions.EpisodeInfo`

`extensions.Playlist`

`extensions.Share`

`extensions.SubscribeBar`

`extensions.Transcript`

