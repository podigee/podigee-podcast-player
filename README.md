# Podigee Podcast Player

The Podigee Podcast Player is a state of the art web audio player specially crafted for listening to podcasts.

[Demo](https://podigee.github.com/podigee-podcast-player "Podigee Podcast Player Demo")

- [Features](#features)
- [Extensions](#extensions)
- [Themes](#themes)
- [Compatibility](#compatibility)
- [Usage](#usage)
- [Who did this?](#who)
- [Contribute](#contribute)
- [License](#license)

## Features

The PPP at it's core is an **embeddable HTML5 audio player**. It supports **theming**, **extensions** and **unicorns**.

## Extensions

The player is extensible and ships with the following default extensions:

- Sharing - This holds sharing options for different social networks, direct link sharing and the embed code.
- Chaptermarks - If the podcaster supplies chaptermarks for an episode listeners can will see where in the episode they currently are and jump to a chaptermark with a click or tap.
- Episode Info - Displays the episode title and description for the episode.
- Playlist - Displays a list of podcast episodes based on as standard podcast RSS feed.
- Transcript - Displays the transcript of an episode, highlights the currently spoken words and allows the listener to search and jump to certain passages by clicking or tapping.
- Chromecast (experimental) - Allows the listener to play the podcast episode on a Chromecast device. This is currently not enabled by default, because it's still in testing and requires a little polishing work.
- Deeplinking - Allows to share an URL in the form https://example.com/ep-1#t=123,321, which will set the player to start with second 123 and play until second 321 (see https://podlove.org/deep-link/ for details).
- Subscribe Bar / Subscribe Button - Shows the Podlove Subscribe Button and Links to iTunes, Spotify, Deezer if configured

## Themes

The player is completely themeable, you can even change the markup! It comes with a responsive default theme. Themes currently available:

- Default - The default theme
- Default dark - A dark version of the default theme
- Minimal - A very minimal theme

You can find some details on how to create your own theme [here](docs/theming.md).

## Compatibility

We aim to always support the latest 2-3 versions of modern browsers. Internet Explorer is fully supported from version 11 on. Version 9 is not officially supported, but basic playback should work fine there too.

## Usage

By default the player is integrated into the page using a `<script>` HTML tag. This is necessary to render the player in an iframe to ensure it does not interfere with the enclosing page's CSS and JS while still being able to resize the player interface dynamically.

### Inline configuration

`data-configuration` should be set to the JS variable name you saved the [configuration](docs/configuration.md) to.

```html
window.playerConfiguration = {
  "episode": {
    "media": {"mp3": "https://example.com/episode-1.mp3"},
    "title": "Transcript Test"
  }
}
<script class="podigee-podcast-player" src="https://cdn.podigee.com/podcast-player/javascripts/podigee-podcast-player.js" data-configuration="playerConfiguration"></script>
```

### Remote configuration

`data-configuration` should be set to a URL to a JSON [configuration](docs/configuration.md) file.

```html
<script class="podigee-podcast-player" src="https://cdn.podigee.com/podcast-player/javascripts/podigee-podcast-player.js" data-configuration="https://example.com/my-podcast-episode.json"></script>
```

### Simple Iframe with external configuration

If you can't use a `<script>` tag to embed the player, you can also use an `<iframe>` directly like this:

```html
iframe {
  border: none;
  height: 500px;
  width: 100%;
}

<iframe class="podigee-podcast-player" src="https://cdn.podigee.com/podcast-player/podigee-podcast-player.html?configuration=https://example.com/my-podcast-episode.json"></script>
```

Please note that with this method you need to either specify a `startPanel` to show by default and adjust the iframe height accordingly or disable all extensions to just show the player. With this method the player will not automatically resize when a panel is opened.

## Who

We are [Podigee](https://www.podigee.com "The Podcast Hosting Platform"), an awesome Podcast Hosting Platform.

## Contribute

If you would like to propose new features or have found a bug, please use [Github issues](https://github.com/podigee/podigee-podcast-player/issues) to tell us.

### Installing the dev dependencies

# Assuming nodejs is installed

## Install dependencies

Install yarn: https://yarnpkg.com/en/docs/install

```
yarn install
```

## Run dev server (also watches and builds assets live)

```
gulp serve
```

## Build dev assets

```
gulp dev
```

## Build production assets

```
gulp build
```

Open http://0.0.0.0:8081/ in your browser.

## License

[MIT](https://github.com/podigee/podigee-podcast-player/blob/master/LICENSE)
