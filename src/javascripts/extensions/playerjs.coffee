Extension = require('../extension.coffee')
Adapter = require('./playerjs/adapter.coffee')
Receiver = require('./playerjs/receiver.coffee')

class Playerjs extends Extension
  @extension:
    name: 'Playerjs'
    type: 'internal'

  constructor: (@app) ->
    @receiver = new Receiver()
    new Adapter(@app, @receiver)

    @receiver.ready()

  destroy: () ->
    @receiver.unbind()

module.exports = Playerjs
