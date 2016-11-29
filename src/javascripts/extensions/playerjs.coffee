Extension = require('../extension.coffee')
Adapter = require('./playerjs/adapter.coffee')
Receiver = require('./playerjs/receiver.coffee')

class Playerjs extends Extension
  @extension:
    name: 'Playerjs'
    type: 'internal'

  constructor: (@app) ->
    @player = @app.player

    @receiver = new Receiver()
    new Adapter(@player, @receiver)

    @receiver.ready()

module.exports = Playerjs
