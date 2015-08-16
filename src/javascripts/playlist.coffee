$ = require('../../vendor/javascripts/jquery.1.11.0.min.js')
PlaylistItem = require('./playlist_item.coffee')

class Playlist
  constructor: (@items, @container, @callback) ->
    self = this
    list = $('<ul>')
    $(@items).each((index, item) =>
      item = $(item)
      item = {
        title: item.find('title').html(),
        href: item.find('link').html(),
        enclosure: item.find('enclosure').attr('url'),
        description: item.find('description').html()
      }
      playlistItem = new PlaylistItem(item, self.callback).render()
      list.append(playlistItem)
    )
    @container.append(list)

    @container.show(400, @sendHeightChange)

module.exports = Playlist
