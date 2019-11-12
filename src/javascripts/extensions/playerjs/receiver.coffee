$ = require('jquery')

class Receiver
  constructor: ->
    @isReady = false
    window.addEventListener 'message', @receive

  context: 'player.js'
  version: '0.0.11'

  supported:
    events: [
      'play'
      'pause'
      'ended'
      'error'
      'timeupdate'
      'subscribeIntent'
    ]
    methods: [
      'play'
      'pause'
      'addEventListener'
      'removeEventListener'
      'getPaused'
      'getDuration'
      'setCurrentTime'
      'getCurrentTime'
      'setConfiguration'
    ]

  methods: {}
  eventListeners: {}

  unbind: () ->
    window.removeEventListener 'message', @receive

  receive: (e) =>
    try
      data = window.JSON.parse(e.data)
    catch error
      console.debug("[podigee] error handling player.js data:", error, e)
      return

    unless data.method
      return false

    unless data.context == @context
      return false

    if @supported.methods.indexOf(data.method) == -1
      @emit 'error',
        code: 2
        msg: "Invalid Method #{data.method}"
      return false

    listener = if data.listener? then data.listener else null

    if  data.method == 'addEventListener'
      if @eventListeners.hasOwnProperty(data.value)
        if @eventListeners[data.value].indexOf(listener) == -1
          @eventListeners[data.value].push(listener)
      else
        @eventListeners[data.value] = [listener]

      if data.value == 'ready' && @isReady
        @ready()

    else if  data.method == 'removeEventListener'
      if @eventListeners.hasOwnProperty(data.value)
        index = @eventListeners[data.value].indexOf(listener)

        if index > -1
          @eventListeners[data.value].splice(index, 1)

        if @eventListeners[data.value].length == 0
          delete @eventListeners[data.value]

    else
      @get(data.method, data.value, listener)

  get: (method, value, listener) ->
    unless @methods.hasOwnProperty(method)
      @emit 'error',
        code: 3
        msg: "Method Not Supported '#{method}'"
      return false

    func = @methods[method]

    if method.substr(0,3) == 'get'
      callback = (val) =>
        @send(method, val, listener)

      func.call(@, callback)
    else
      func.call(@, value)

  on: (event, callback) ->
    @methods[event] = callback

  send: (event, value, listener) =>
    data =
      context: @context
      version: @version
      event: event

    if value?
      data.value = value

    if listener?
      data.listener = listener

    msg = JSON.stringify(data)
    window.parent.postMessage(msg, '*')

  emit: (event, value) =>

    unless @eventListeners.hasOwnProperty(event)
      return false

    Object.keys(@eventListeners).map (key) =>
      @eventListeners[key].map (listener) =>
        @send(event, value, listener)

    return true

  ready: () ->
    @isReady = true

    data =
      src: window.location.toString(),
      events: @supported.events,
      methods: @supported.methods

    unless @emit('ready', data)
      @send('ready', data)

module.exports = Receiver
