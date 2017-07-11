$ = require('jquery')

class IframeResizer
  @listen: (listenTo, iframe, offset = {}, callback) ->
    $(window).on 'message', (event) =>
      try
        resizeData = JSON.parse(event.data || event.originalEvent.data)
      catch
        return

      return unless resizeData.id == iframe.attr('id')
      return unless resizeData.listenTo == listenTo

      height = resizeData.height + (offset.height || 0)
      width = if /%$/.test(resizeData.width)
        resizeData.width
      else
        resizeData.width + (offset.width || 0)

      iframe.height(height)
      iframe.css("max-height", height)
      iframe.width(width)
      iframe.css("max-width", width)

      callback(iframe) if callback?

module.exports = IframeResizer
