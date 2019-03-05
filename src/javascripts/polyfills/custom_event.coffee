(() ->
  if typeof window.CustomEvent == "function" || this.CustomEvent.toString().indexOf('CustomEventConstructor') > -1
    return

  CustomEvent = (event, params) ->
    params = params || { bubbles: false, cancelable: false, detail: undefined }
    evt = document.createEvent( 'CustomEvent' )
    evt.initCustomEvent( event, params.bubbles, params.cancelable, params.detail )
    evt

  CustomEvent.prototype = window.Event.prototype

  window.CustomEvent = CustomEvent
)()
