class IframeResizer
  @listen: (listenTo, iframe, offset = {}, callback) ->
    window.addEventListener 'message', ((event) =>
      try
        resizeData = JSON.parse(event.data || event.originalEvent.data)
      catch
        return

      return unless resizeData.id == iframe.id
      return unless resizeData.listenTo == listenTo

      height = resizeData.height + (offset.height || 0)
      width = if /%$/.test(resizeData.width)
        resizeData.width
      else
        resizeData.width + (offset.width || 0)

      iframe.style.height = "#{height}px"
      iframe.style.maxHeight = "#{height}px"
      iframe.style.width = "#{width}px"
      iframe.style.maxWidth = "#{width}px"

      callback(iframe) if callback?
    ), false

module.exports = IframeResizer
