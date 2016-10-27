# Podigee Podcast Player - Theming

You can create your own themes for the Podigee Podcast Player. All you need is a HTML and a CSS file accessible by the browser the player is loaded in.

## Configuration

```
window.playerConfiguration = {
  "options": {
    "theme": {
      "html": "https://example.com/theme.html",
      "css": "https://example.com/theme.css"
    }
  },
  ...
}
```

## HTML

An example HTML file would look like this:


```
<div class="podcast-player">
  <audio></audio>

  <div class="main-player">
    <img class="cover-image" pp-src="coverUrl" />

    <div class="controls">
      <button class="play-button"></button>
    </div>

    <div class="episode-basic-info">
      <div class="episode-title">
        <a pp-if="url" pp-href="url" target="_parent">{ title }</a>
        <span pp-unless="url">{ title }</a>
      </div>
      <div class="episode-subtitle">{ subtitle }</div>
    </div>

    <div class="controls-advanced">
      <button class="backward-button" title="Backward 10s"></button>
      <button class="forward-button" title="Forward 30s"></button>
      <button class="speed-toggle" title="Playback speed">1x</button>
    </div>

    <div class="buttons"></div>

    <progressbar/>
  </div>

  <div class="panels"></div>
</div>
```

Everything configured in the `episode` block of the player configuration can be accessed in the template. Additionally the following variables are also available:

- `duration` - The total duration of the episode

You can have a look at the [included themes](src/themes) for more examples.

## CSS

There are no special requirements regarding CSS. You can have a look at the [included themes](src/themes) for examples.
