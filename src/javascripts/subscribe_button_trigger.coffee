require('./polyfills/custom_event.coffee')

class SubscribeButtonTrigger
  # referenceElement is the DOM element after which the script tag should be inserted
  constructor: (@referenceElement) ->
    @referenceId = @referenceElement.id
    @id = @randomId(@referenceElement.toString())
    @buildTags()
    @insert()

  buildTags: () ->
    @scriptTag = document.createElement('script')
    @scriptTag.className = "podlove-subscribe-button"
    @scriptTag.src = "https://cdn.podigee.com/subscribe-button/javascripts/app.js"
    @scriptTag.dataset.language = 'en'
    @scriptTag.dataset.size = 'medium'
    @scriptTag.setAttribute('data-hide', true)
    @scriptTag.setAttribute('data-buttonid', @id)

    @button = document.createElement('button')
    @button.style.display = 'none'
    @button.className = "podlove-subscribe-button-#{@id}"

  insert: () ->
    @referenceElement.parentNode.insertBefore(@scriptTag, @referenceElement.nextSibling)
    @referenceElement.parentNode.insertBefore(@button, @referenceElement.nextSibling)

  randomId: (string) ->
    randomPart = Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1)
    string += randomPart
    hash = 0
    return hash if string.length == 0

    hsh = (char) =>
      return if isNaN(char)
      hash = ((hash<<5)-hash)+char
      hash = hash & hash

    hsh(string.charCodeAt(i)) for i in [0..string.length]

    return hash.toString(16).substring(1)

  listen: () ->
    window.addEventListener 'message', ((event) =>
      try
        data = JSON.parse(event.data || event.originalEvent.data)
      catch
        return
      return unless data.listenTo == 'subscribeButtonTrigger'
      return unless data.id == @referenceId

      detail = data.detail
      detail.id = @id
      event = new CustomEvent('openSubscribeButtonPopup', {detail: detail})
      document.body.dispatchEvent(event)
    ), false

module.exports = SubscribeButtonTrigger
