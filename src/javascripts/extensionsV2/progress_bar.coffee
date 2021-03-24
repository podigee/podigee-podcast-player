ProgressBar = require('../progress_bar.coffee')

class ProgressBarV2 extends ProgressBar
  template: ->
    """
    <div class="progress-bar #{@progressClassFromAppId()}">
      <button class="progress-bar-time-played time-remaining" pp-show="timeCountdown" title="#{@t('progress_bar.switch_time_mode')}" aria-label="#{@t('progress_bar.switch_time_mode')}">-{ timeLeft }</button>
      <button class="progress-bar-time-played time-played" pp-show="timeCountup" title="#{@t('progress_bar.switch_time_mode')}" aria-label="#{@t('progress_bar.switch_time_mode')}">{ timePlayed }</button>
      <div class="progress-bar-rail">
        <span class="progress-bar-loaded"></span>
        <span class="progress-bar-buffering"></span>
        <span class="progress-bar-played">
          <span class="progress-tooltip">{ timePlayed }</span>
        </span>
      </div>
    </div>
    """

module.exports = ProgressBarV2
