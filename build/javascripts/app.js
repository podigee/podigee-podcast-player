var init, me;

init = function(me) {
  var currentPlaybackRate, handleMouseMove, initLoadingAnimation, initScrubber, jumpToPosition, playbackRates, scrubberBufferingElement, scrubberElement, scrubberLoadedElement, scrubberPlayedElement, scrubberRailElement, scrubberWidth, secondsToHHMMSS, switchTimeDisplay, timeElement, timeMode, timeRailFactor, togglePlayState, triggerError, triggerLoaded, triggerLoading, triggerPlaying, updateLoaded, updateScrubber, updateTime;
  timeElement = $('.time-played');
  scrubberElement = $('.time-scrubber');
  scrubberPlayedElement = scrubberElement.find('.time-scrubber-played');
  scrubberLoadedElement = scrubberElement.find('.time-scrubber-loaded');
  scrubberBufferingElement = scrubberElement.find('.time-scrubber-buffering');
  scrubberRailElement = scrubberElement.find('.rail');
  scrubberWidth = function() {
    return scrubberRailElement.width();
  };
  timeMode = 'countup';
  currentPlaybackRate = 1;
  playbackRates = [1.0, 1.5, 2.0];
  initLoadingAnimation = function() {
    var bar, elem, i, line, numberOfLines, _i;
    elem = scrubberElement.find('.time-scrubber-buffering');
    bar = $('<div>').addClass('time-scrubber-buffering-bar');
    line = $('<div>').addClass('time-scrubber-buffering-line');
    numberOfLines = elem.width() / 100 * 3;
    for (i = _i = 0; 0 <= numberOfLines ? _i <= numberOfLines : _i >= numberOfLines; i = 0 <= numberOfLines ? ++_i : --_i) {
      bar.append(line.clone());
    }
    return elem.append(bar);
  };
  initScrubber = function() {
    var newWidth;
    newWidth = scrubberElement.width() - timeElement.width();
    scrubberRailElement.width(newWidth);
    return initLoadingAnimation();
  };
  initScrubber();
  updateTime = function() {
    var prefix, time, timeString;
    time = timeMode === 'countup' ? (prefix = '', me.currentTime) : (prefix = '-', me.duration - me.currentTime);
    timeString = secondsToHHMMSS(time);
    timeElement.text(prefix + timeString);
    return updateScrubber();
  };
  switchTimeDisplay = function() {
    if (timeMode === 'countup') {
      return timeMode = 'countdown';
    } else {
      return timeMode = 'countup';
    }
  };
  secondsToHHMMSS = function(seconds) {
    var hours, minutes;
    hours = Math.floor(seconds / 3600);
    minutes = Math.floor((seconds - (hours * 3600)) / 60);
    seconds = seconds - (hours * 3600) - (minutes * 60);
    seconds = seconds.toFixed(0);
    if (hours < 10) {
      hours = "0" + hours;
    }
    if (minutes < 10) {
      minutes = "0" + minutes;
    }
    if (seconds < 10) {
      seconds = "0" + seconds;
    }
    return "" + hours + ":" + minutes + ":" + seconds;
  };
  timeRailFactor = function() {
    var duration;
    duration = me.duration;
    return scrubberWidth() / duration;
  };
  updateScrubber = function() {
    var newWidth;
    newWidth = me.currentTime * timeRailFactor();
    return scrubberPlayedElement.width(newWidth);
  };
  updateLoaded = function(event) {
    var newStart, newWidth;
    if (me.buffered.length) {
      newStart = me.buffered.start(0) * timeRailFactor();
      newWidth = me.buffered.end(0) * timeRailFactor();
      scrubberLoadedElement.css('margin-left', newStart);
      return scrubberLoadedElement.width(newWidth);
    }
  };
  triggerLoading = function() {
    updateLoaded();
    return scrubberBufferingElement.show();
  };
  triggerPlaying = function() {
    updateLoaded();
    return scrubberBufferingElement.hide();
  };
  triggerLoaded = function() {
    updateLoaded();
    return scrubberBufferingElement.hide();
  };
  triggerError = function() {
    return scrubberBufferingElement.hide();
  };
  $(me).on('timeupdate', updateTime);
  $(me).on('play', triggerPlaying);
  $(me).on('playing', triggerPlaying);
  $(me).on('seeking', triggerLoading);
  $(me).on('seeked', triggerLoaded);
  $(me).on('waiting', triggerLoading);
  $(me).on('loadeddata', triggerLoaded);
  $(me).on('canplay', triggerLoaded);
  $(me).on('error', triggerError);
  togglePlayState = function(elem) {
    $(elem).toggleClass('fa-play');
    return $(elem).toggleClass('fa-pause');
  };
  $('.play').click(function() {
    if (!me.paused) {
      me.pause();
    } else {
      me.play();
    }
    return togglePlayState(this);
  });
  $('.backward').click(function() {
    return me.currentTime = me.currentTime - 10;
  });
  $('.forward').click(function() {
    return me.currentTime = me.currentTime + 30;
  });
  $('.speed').click(function() {
    var nextRate;
    nextRate = playbackRates.indexOf(currentPlaybackRate) + 1;
    if (nextRate >= playbackRates.length) {
      nextRate = 0;
    }
    me.playbackRate = currentPlaybackRate = playbackRates[nextRate];
    return $(this).text("" + currentPlaybackRate + "x");
  });
  $('.time-played').click(function() {
    return switchTimeDisplay();
  });
  jumpToPosition = function(position) {
    var newTime, pixelPerSecond;
    if (me.duration) {
      pixelPerSecond = me.duration / scrubberWidth();
      newTime = pixelPerSecond * position;
      if (newTime !== me.currentTime) {
        return me.currentTime = newTime;
      }
    }
  };
  handleMouseMove = function(event) {
    var position;
    position = event.pageX - $(event.target).offset().left;
    return jumpToPosition(position);
  };
  return $('.rail').on('mousedown', function(event) {
    handleMouseMove(event);
    $(this).on('mousemove', function(event) {
      return handleMouseMove(event);
    });
    return $(this).on('mouseup', function(event) {
      return $(this).off('mousemove');
    });
  });
};

me = new MediaElement('player', {
  success: function(media, elem) {
    return window.init(media);
  }
});
