$ = require('jquery')
_ = require('lodash')
sightglass = require('sightglass')
rivets = require('rivets')
Uri = require('urijs')

Extension = require('../extension.coffee')

class ShareV2 extends Extension
  @extension:
    name: 'Share'
    type: 'menu'

  constructor: (app) ->
    super(app)

    @episode = @app.episode
    return unless @episode and @episode.url

    @options = _.extend(@defaultOptions, @app.extensionOptions.Share)

    return if @options.disabled
    @type = 'menu'

    @buildContext()

    @renderPanel()
    @renderButton()
    @attachEvents()

    @app.theme.addExtension(this)

  defaultOptions:
    showOnStart: false

  shareLinks: (currentTimeInSeconds) =>
    url = encodeURI(@shareUrl())
    title = encodeURIComponent(@episode.title)
    whatsappText = encodeURIComponent("#{@episode.title}: #{url}")

    shareLinks =
      email: "mailto:?subject=Podcast: #{title}&body=#{url}"
      facebook: "https://www.facebook.com/sharer/sharer.php?u=#{url}&t=#{title}"
      twitter: "https://twitter.com/intent/tweet?url=#{url}&text=#{title}"
      whatsapp: "whatsapp://send?text=#{whatsappText}"

  audioFileUrl: () ->
    url = (@app.episode.media.mp3 || @app.episode.media.m4a).replace(/source=\w*/g, 'source=webplayer-download')

  buildContext: =>
    @context ?= {}
    @context.currentTime = @app.player.currentTime
    @context.currentTimeInSeconds = @app.player.currentTimeInSeconds
    @context.shareLinks = @shareLinks(@context.currentTimeInSeconds)
    @context.url = @shareUrl()
    @context.showUrlWithTime ?= true
    @context.embedCode = @app.episode.embedCode
    @context.embedScript = true
    @context.iframeCode = @app.episode.iframeCode
    @context.showEmbedUrl = @app.options.configViaJSON
    @context.downloadLink = @audioFileUrl()

  updateTime: =>
    @context.currentTime = @app.player.currentTime
    @context.currentTimeInSeconds = @app.player.currentTimeInSeconds
    @context.shareLinks = @shareLinks(@context.currentTimeInSeconds)
    @context.url = @shareUrl()

  shareUrl: =>
    parsed = Uri(@episode.url)
    if @context?.showUrlWithTime
      time = Math.round(@context.currentTimeInSeconds)
      parsed.fragment("t=#{time}")
    else
      @episode.url

  renderPanel: =>
    @panel = $(@panelHtml())
    @view = rivets.bind(@panel, @context)
    @panel.hide()
    @bindEvents()

  attachEvents: =>
    @app.player.addEventListener('timeupdate', @updateTime)

  closePanel: () =>
    @app.theme.togglePanel(@panel)

  bindEvents: () =>
    @panel.find('.share-copy-url-btn').on 'click', =>
      @copyUrlAction(@context.url)
    @panel.find('.script-button').on 'click', =>
      @context.embedScript = true
    @panel.find('.iframe-button').on 'click', =>
      @context.embedScript = false

    @panel.find('.share-embed-url-btn').on 'click', =>
      if @context.embedScript
        @copyUrlAction(@context.embedCode)
      else
        @copyUrlAction(@context.iframeCode)

    @panel.find('.close-button').on 'click', @closePanel

  copyUrlAction: (url) =>
    temp = document.createElement('input')
    document.body.appendChild(temp)
    temp.value =  url
    temp.select()
    document.execCommand('copy')
    document.body.removeChild(temp)

  buttonHtml: ->
    """
    <button
      class="share-menu-button list-button"
      aria-label="#{@t('share.title')}"
      title"#{@t('share.title')}"
    >#{@t('share.title')}</button>
    """

  panelHtml: ->
    """
     <div class="share-menu">
      <button class="close-button" title="Close" aria-label="Close">
        <svg viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
          <title>Close</title>
          <path
            d="M17.0575 19.429L9.92732 12.3102L2.79879 19.429C2.47847 19.713 2.06169 19.8641 1.63361 19.8513C1.20554 19.8386 0.798489 19.663 0.495659 19.3604C0.19283 19.0579 0.0170805 18.6512 0.00432973 18.2235C-0.00842104 17.7958 0.142789 17.3794 0.427058 17.0594L7.55059 9.93731L0.427058 2.8119C0.141393 2.49213 -0.0111538 2.07537 0.000635795 1.64692C0.0124254 1.21846 0.18766 0.81071 0.490478 0.507102C0.793296 0.203494 1.2008 0.0269879 1.6296 0.0137052C2.05839 0.000422413 2.47606 0.151367 2.79712 0.43565L9.92732 7.56106L17.0592 0.43565C17.3792 0.145477 17.7987 -0.0103567 18.2307 0.00053476C18.6627 0.0114263 19.0739 0.188205 19.3788 0.494133C19.6837 0.800061 19.8589 1.21161 19.868 1.64325C19.8771 2.0749 19.7194 2.49344 19.4276 2.8119L12.3041 9.93731L19.4276 17.0594C19.6004 17.2108 19.7403 17.396 19.8386 17.6036C19.9369 17.8112 19.9915 18.0367 19.9991 18.2662C20.0067 18.4957 19.967 18.7243 19.8826 18.9379C19.7982 19.1515 19.6708 19.3455 19.5083 19.508C19.3459 19.6704 19.1518 19.7978 18.9381 19.8823C18.7243 19.9668 18.4955 20.0065 18.2658 19.9991C18.0361 19.9917 17.8103 19.9373 17.6025 19.8392C17.3946 19.7412 17.2092 19.6015 17.0575 19.429Z"
          />
        </svg>
      </button>

      <div class="copy-episode flex-item">
        <button class="share-copy-url-btn" title="#{@t('share.copy_episode_link')}" aria-label="#{@t('share.copy_episode_link')}">
          <svg viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
            <title>#{@t('share.copy_episode_link')}</title>
            <path
              d="M18 4H6C5.46957 4 4.96086 4.21071 4.58579 4.58579C4.21071 4.96086 4 5.46957 4 6V18C4 18.5304 4.21071 19.0391 4.58579 19.4142C4.96086 19.7893 5.46957 20 6 20H18C18.5304 20 19.0391 19.7893 19.4142 19.4142C19.7893 19.0391 20 18.5304 20 18V6C20 5.46957 19.7893 4.96086 19.4142 4.58579C19.0391 4.21071 18.5304 4 18 4V4ZM18 18H6V6H18V18Z"
            />
            <path
              d="M2 2H16V0H2C1.46957 0 0.960859 0.210714 0.585786 0.585786C0.210714 0.960859 0 1.46957 0 2V16H2V2Z"
            />
          </svg>
          <span>#{@t('share.copy_episode_link')}</span>
        </button>
      </div>
      <div class="flex-item">
        <div>#{@t('share.start_at')}</div>
        <div class="start-at" pp-html="currentTime"></div>
      </div>

      <div class="copy-embed flex-item">
        <button class="share-embed-url-btn" title="#{@t('share.copy_embed_code')}" aria-label="#{@t('share.copy_embed_code')}">
          <svg viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
            <title>#{@t('share.copy_embed_code')}</title>
            <path
              d="M18 4H6C5.46957 4 4.96086 4.21071 4.58579 4.58579C4.21071 4.96086 4 5.46957 4 6V18C4 18.5304 4.21071 19.0391 4.58579 19.4142C4.96086 19.7893 5.46957 20 6 20H18C18.5304 20 19.0391 19.7893 19.4142 19.4142C19.7893 19.0391 20 18.5304 20 18V6C20 5.46957 19.7893 4.96086 19.4142 4.58579C19.0391 4.21071 18.5304 4 18 4V4ZM18 18H6V6H18V18Z"
            />
            <path
              d="M2 2H16V0H2C1.46957 0 0.960859 0.210714 0.585786 0.585786C0.210714 0.960859 0 1.46957 0 2V16H2V2Z"
            />
          </svg>
          <span>#{@t('share.copy_embed_code')}</span>
        </button>
      </div>
       <div class="flex-item">
          <ul class="items-list embed-list">
            <li class="list-item">
              <button class="list-button script-button" pp-class-button-active="embedScript">JavaScript</button>
            </li>
            <li class="list-item">
              <button class="list-button iframe-button" pp-classinverted-button-active="embedScript">iFrame</button>
            </li>
          </ul>
        </div>

      <div class="share-buttons flex-item">
        <ul>
          <li class="share-fb">
            <a pp-href="shareLinks.facebook" target="_blank">
              <svg
                viewBox="0 0 20 20"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
              >
                <title>Facebook</title>
                <path
                  d="M18.1818 0H1.81818C1.33597 0 0.873508 0.191558 0.532533 0.532533C0.191558 0.873508 0 1.33597 0 1.81818V18.1818C0 18.664 0.191558 19.1265 0.532533 19.4675C0.873508 19.8084 1.33597 20 1.81818 20H10.9091V11.8182H8.18182V9.09091H10.9091V7.62636C10.9091 4.85364 12.26 3.63636 14.5645 3.63636C15.2211 3.62769 15.8775 3.66749 16.5282 3.75545V6.36364H14.9564C13.9782 6.36364 13.6364 6.88 13.6364 7.92546V9.09091H16.5036L16.1145 11.8182H13.6364V20H18.1818C18.664 20 19.1265 19.8084 19.4675 19.4675C19.8084 19.1265 20 18.664 20 18.1818V1.81818C20 1.33597 19.8084 0.873508 19.4675 0.532533C19.1265 0.191558 18.664 0 18.1818 0V0Z"
                />
              </svg>
            </a>
          </li>
          <li class="share-tw">
            <a pp-href="shareLinks.twitter" target="_blank">
              <svg viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
                <title>Twitter</title>
                <path
                  d="M18.1818 0H1.81818C1.33597 0 0.873508 0.191558 0.532533 0.532533C0.191558 0.873508 0 1.33597 0 1.81818V18.1818C0 18.664 0.191558 19.1265 0.532533 19.4675C0.873508 19.8084 1.33597 20 1.81818 20H18.1818C18.664 20 19.1265 19.8084 19.4675 19.4675C19.8084 19.1265 20 18.664 20 18.1818V1.81818C20 1.33597 19.8084 0.873508 19.4675 0.532533C19.1265 0.191558 18.664 0 18.1818 0V0ZM15.1636 7.26273C15.1691 7.38091 15.1718 7.5 15.1718 7.61909C15.1722 9.02482 14.7944 10.4048 14.0778 11.6141C13.3612 12.8235 12.3324 13.8178 11.0992 14.4926C9.86609 15.1674 8.47404 15.498 7.06915 15.4495C5.66426 15.4011 4.29829 14.9754 3.11455 14.2173C3.3327 14.2429 3.55217 14.2556 3.77182 14.2555C5.01217 14.2567 6.21684 13.8404 7.19182 13.0736C6.61761 13.0629 6.06107 12.8731 5.59987 12.5309C5.13866 12.1887 4.79579 11.711 4.61909 11.1645C5.03216 11.2433 5.45773 11.2271 5.86364 11.1173C5.24036 10.9914 4.67984 10.6537 4.27719 10.1616C3.87454 9.66942 3.65455 9.05314 3.65455 8.41727V8.38182C4.0369 8.59444 4.46454 8.71257 4.90182 8.72636C4.31909 8.33668 3.90668 7.73966 3.74844 7.05674C3.59021 6.37381 3.69804 5.65626 4.05 5.05C4.74162 5.90091 5.6045 6.59681 6.58259 7.09251C7.56068 7.58821 8.6321 7.87263 9.72727 7.92727C9.68001 7.72153 9.65622 7.5111 9.65636 7.3C9.65652 6.74776 9.82267 6.20832 10.1332 5.75168C10.4438 5.29505 10.8845 4.9423 11.398 4.73924C11.9116 4.53617 12.4743 4.49215 13.0132 4.6129C13.5521 4.73364 14.0422 5.01357 14.42 5.41636C15.0368 5.29488 15.6284 5.0689 16.1691 4.74818C15.9637 5.38669 15.533 5.92861 14.9573 6.27273C15.5033 6.20814 16.0365 6.06196 16.5391 5.83909C16.168 6.39096 15.7024 6.87291 15.1636 7.26273V7.26273Z"
                />
              </svg>
            </a>
          </li>
          <li class="share-wa">
            <a pp-href="shareLinks.whatsapp" target="_blank">
              <svg viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
                <title>WhatsApp</title>
                <path
                  d="M9.99997 -1.07496e-06C8.23129 -0.00298201 6.49357 0.463954 4.96459 1.35303C3.43561 2.24211 2.17026 3.52142 1.29801 5.06006C0.425765 6.5987 -0.0220758 8.34145 0.000311737 10.11C0.0226992 11.8785 0.514511 13.6094 1.42543 15.1255L0.0908837 20L5.06997 18.6927C6.40142 19.4499 7.88901 19.8911 9.41797 19.9823C10.9469 20.0734 12.4764 19.8122 13.8884 19.2186C15.3004 18.6251 16.5572 17.7151 17.5618 16.5589C18.5664 15.4027 19.292 14.0312 19.6826 12.5502C20.0733 11.0691 20.1184 9.51817 19.8147 8.01691C19.5109 6.51565 18.8664 5.10422 17.9308 3.89152C16.9951 2.67881 15.7935 1.69724 14.4184 1.02252C13.0433 0.347795 11.5317 -0.00204012 9.99997 -1.07496e-06V-1.07496e-06ZM6.57725 5.33545C6.73997 5.33545 6.90634 5.33545 7.05088 5.34182C7.2327 5.34182 7.42361 5.35909 7.60907 5.77C7.82997 6.25818 8.31088 7.48363 8.3727 7.60727C8.41236 7.67185 8.43491 7.74546 8.43825 7.82116C8.44159 7.89687 8.4256 7.97218 8.39179 8.04C8.32908 8.18872 8.24684 8.32844 8.14725 8.45545C8.0227 8.59909 7.88725 8.77636 7.77452 8.88545C7.64997 9.01 7.52179 9.14545 7.66543 9.39363C8.03673 10.0302 8.50094 10.6077 9.0427 11.1073C9.62972 11.6302 10.3039 12.0462 11.0345 12.3364C11.2827 12.4609 11.4263 12.4409 11.57 12.2745C11.7136 12.1082 12.1891 11.5545 12.3563 11.3064C12.5236 11.0582 12.6845 11.1009 12.91 11.1827C13.1354 11.2645 14.3563 11.8645 14.6045 11.9882C14.8527 12.1118 15.0154 12.17 15.0782 12.2745C15.1491 12.6738 15.0998 13.0852 14.9363 13.4564C14.7568 13.7592 14.5152 14.0205 14.2273 14.2231C13.9395 14.4257 13.612 14.565 13.2663 14.6318C12.8118 14.6745 12.3818 14.8373 10.2927 14.0145C8.55617 13.1929 7.08842 11.8954 6.05998 10.2727C5.48136 9.53664 5.1306 8.64743 5.05088 7.71454C5.04422 7.32891 5.11761 6.94609 5.26642 6.59027C5.41523 6.23444 5.63622 5.91335 5.91543 5.64727C5.99813 5.55229 6.09966 5.47553 6.21359 5.42185C6.32751 5.36817 6.45135 5.33875 6.57725 5.33545Z"
                />
              </svg>
            </a>
          </li>
          <li class="share-mail">
            <a pp-href="shareLinks.email" target="_blank">
              <svg viewBox="0 0 20 14" xmlns="http://www.w3.org/2000/svg">
                <title pp-html="translations.shareEmail"></title>
                <path
                  d="M1.09786 0L9.15071 8.183C9.38151 8.41688 9.68508 8.5469 10.0004 8.5469C10.3156 8.5469 10.6192 8.41688 10.85 8.183L18.9021 0H1.09786ZM0 1.01111V14H20V1.01111L11.825 9.31933C11.3292 9.82119 10.6773 10.1001 10.0004 10.1001C9.32341 10.1001 8.67154 9.82119 8.17571 9.31933L0 1.01111Z"
                />
              </svg>
            </a>
          </li>
          <li class="share-download">
            <a pp-href="downloadLink" pp-download="downloadLink" target="_blank">
              <svg viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
                <title pp-html="translations.downloadEpisode"></title>
                <path
                  d="M11 1C11 0.447715 10.5523 0 10 0C9.44772 0 9 0.447715 9 1V11.3002L7.75871 9.85453C7.39893 9.4355 6.76759 9.38747 6.34857 9.74725C5.92955 10.107 5.88152 10.7384 6.24129 11.1574L9.24129 14.6514C9.43127 14.8727 9.70837 15 10 15C10.2916 15 10.5687 14.8727 10.7587 14.6514L13.7587 11.1574C14.1185 10.7384 14.0705 10.107 13.6514 9.74725C13.2324 9.38747 12.6011 9.4355 12.2413 9.85453L11 11.3002V1ZM1 18C0.447715 18 0 18.4477 0 19C0 19.5523 0.447715 20 1 20H19C19.5523 20 20 19.5523 20 19C20 18.4477 19.5523 18 19 18H1Z"
                />
              </svg>
            </a>
          </li>
        </ul>
      </div>
    </div>
    """

module.exports = ShareV2
