var PodiPlay, player,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

PodiPlay = (function() {
  function PodiPlay(elemClass) {
    var audioElem, that;
    this.elemClass = elemClass;
    this.jumpForward = __bind(this.jumpForward, this);
    this.jumpBackward = __bind(this.jumpBackward, this);
    this.changePlaySpeed = __bind(this.changePlaySpeed, this);
    this.handleMouseMove = __bind(this.handleMouseMove, this);
    this.jumpToPosition = __bind(this.jumpToPosition, this);
    this.triggerError = __bind(this.triggerError, this);
    this.triggerLoaded = __bind(this.triggerLoaded, this);
    this.triggerPlaying = __bind(this.triggerPlaying, this);
    this.triggerLoading = __bind(this.triggerLoading, this);
    this.updateLoaded = __bind(this.updateLoaded, this);
    this.updateScrubber = __bind(this.updateScrubber, this);
    this.updateTime = __bind(this.updateTime, this);
    this.timeRailFactor = __bind(this.timeRailFactor, this);
    this.switchTimeDisplay = __bind(this.switchTimeDisplay, this);
    this.togglePlayState = __bind(this.togglePlayState, this);
    this.scrubberWidth = __bind(this.scrubberWidth, this);
    this.elem = $(this.elemClass);
    audioElem = $(this.elemClass).find('audio')[0];
    that = this;
    new MediaElement(audioElem, {
      success: function(media, elem) {
        return that.init(media, elem);
      }
    });
  }

  PodiPlay.prototype.currentPlaybackRate = 1;

  PodiPlay.prototype.playbackRates = [1.0, 1.5, 2.0];

  PodiPlay.prototype.timeMode = 'countup';

  PodiPlay.prototype.backwardSeconds = 10;

  PodiPlay.prototype.forwardSeconds = 30;

  PodiPlay.prototype.init = function(player, elem) {
    var that;
    this.player = player;
    that = this;
    this.findElements();
    this.initScrubber();
    this.bindButtons();
    return this.bindPlayerEvents();
  };

  PodiPlay.prototype.findElements = function() {
    this.scrubberElement = this.elem.find('.time-scrubber');
    this.timeElement = this.elem.find('.time-played');
    this.scrubberRailElement = this.scrubberElement.find('.rail');
    this.scrubberPlayedElement = this.scrubberElement.find('.time-scrubber-played');
    this.scrubberLoadedElement = this.scrubberElement.find('.time-scrubber-loaded');
    this.scrubberBufferingElement = this.scrubberElement.find('.time-scrubber-buffering');
    this.playPauseElement = this.elem.find('.play-button');
    this.backwardElement = this.elem.find('.backward-button');
    this.forwardElement = this.elem.find('.forward-button');
    return this.speedElement = this.elem.find('.speed-toggle');
  };

  PodiPlay.prototype.scrubberWidth = function() {
    return this.scrubberRailElement.width();
  };

  PodiPlay.prototype.initScrubber = function() {
    var newWidth;
    newWidth = this.scrubberElement.width() - this.timeElement.width();
    this.scrubberRailElement.width(newWidth);
    return this.initLoadingAnimation();
  };

  PodiPlay.prototype.initLoadingAnimation = function() {
    var bar, elem, i, line, numberOfLines, _i;
    elem = this.scrubberElement.find('.time-scrubber-buffering');
    bar = $('<div>').addClass('time-scrubber-buffering-bar');
    line = $('<div>').addClass('time-scrubber-buffering-line');
    numberOfLines = elem.width() / 100 * 3;
    for (i = _i = 0; 0 <= numberOfLines ? _i <= numberOfLines : _i >= numberOfLines; i = 0 <= numberOfLines ? ++_i : --_i) {
      bar.append(line.clone());
    }
    return elem.append(bar);
  };

  PodiPlay.prototype.togglePlayState = function(elem) {
    this.playPauseElement.toggleClass('fa-play');
    return this.playPauseElement.toggleClass('fa-pause');
  };

  PodiPlay.prototype.switchTimeDisplay = function() {
    return this.timeMode = this.timeMode === 'countup' ? 'countdown' : 'countup';
  };

  PodiPlay.prototype.timeRailFactor = function() {
    var duration;
    duration = this.player.duration;
    return this.scrubberWidth() / duration;
  };

  PodiPlay.prototype.secondsToHHMMSS = function(seconds) {
    var hours, minutes;
    hours = Math.floor(seconds / 3600);
    minutes = Math.floor((seconds - (hours * 3600)) / 60);
    seconds = seconds - (hours * 3600) - (minutes * 60);
    seconds = seconds.toFixed(0);
    hours = this.padNumber(hours);
    minutes = this.padNumber(minutes);
    seconds = this.padNumber(seconds);
    return "" + hours + ":" + minutes + ":" + seconds;
  };

  PodiPlay.prototype.padNumber = function(number) {
    if (number < 10) {
      return "0" + number;
    } else {
      return number;
    }
  };

  PodiPlay.prototype.updateTime = function() {
    var prefix, time, timeString;
    time = this.timeMode === 'countup' ? (prefix = '', this.player.currentTime) : (prefix = '-', this.player.duration - this.player.currentTime);
    timeString = this.secondsToHHMMSS(time);
    this.timeElement.text(prefix + timeString);
    return this.updateScrubber();
  };

  PodiPlay.prototype.updateScrubber = function() {
    var newWidth;
    newWidth = this.player.currentTime * this.timeRailFactor();
    return this.scrubberPlayedElement.width(newWidth);
  };

  PodiPlay.prototype.updateLoaded = function(event) {
    var newStart, newWidth;
    if (this.player.buffered.length) {
      newStart = this.player.buffered.start(0) * this.timeRailFactor();
      newWidth = this.player.buffered.end(0) * this.timeRailFactor();
      this.scrubberLoadedElement.css('margin-left', newStart);
      return this.scrubberLoadedElement.width(newWidth);
    }
  };

  PodiPlay.prototype.triggerLoading = function() {
    this.updateLoaded();
    return this.scrubberBufferingElement.show();
  };

  PodiPlay.prototype.triggerPlaying = function() {
    this.updateLoaded();
    return this.scrubberBufferingElement.hide();
  };

  PodiPlay.prototype.triggerLoaded = function() {
    this.updateLoaded();
    return this.scrubberBufferingElement.hide();
  };

  PodiPlay.prototype.triggerError = function() {
    return this.scrubberBufferingElement.hide();
  };

  PodiPlay.prototype.jumpToPosition = function(position) {
    var newTime, pixelPerSecond;
    if (this.player.duration) {
      pixelPerSecond = this.player.duration / this.scrubberWidth();
      newTime = pixelPerSecond * position;
      if (newTime !== this.player.currentTime) {
        return this.player.currentTime = newTime;
      }
    }
  };

  PodiPlay.prototype.handleMouseMove = function(event) {
    var position;
    position = event.pageX - $(event.target).offset().left;
    return this.jumpToPosition(position);
  };

  PodiPlay.prototype.changePlaySpeed = function() {
    var nextRate;
    nextRate = this.playbackRates.indexOf(this.currentPlaybackRate) + 1;
    if (nextRate >= this.playbackRates.length) {
      nextRate = 0;
    }
    this.player.playbackRate = this.currentPlaybackRate = this.playbackRates[nextRate];
    return $(event.target).text("" + this.currentPlaybackRate + "x");
  };

  PodiPlay.prototype.jumpBackward = function(seconds) {
    seconds = seconds || this.backwardSeconds;
    return this.player.currentTime = this.player.currentTime - seconds;
  };

  PodiPlay.prototype.jumpForward = function(seconds) {
    seconds = seconds || this.forwardSeconds;
    return this.player.currentTime = this.player.currentTime + seconds;
  };

  PodiPlay.prototype.bindButtons = function() {
    this.playPauseElement.click((function(_this) {
      return function() {
        if (_this.player.paused) {
          _this.player.play();
        } else {
          _this.player.pause();
        }
        return _this.togglePlayState(_this);
      };
    })(this));
    this.backwardElement.click((function(_this) {
      return function() {
        return _this.jumpBackward();
      };
    })(this));
    this.forwardElement.click((function(_this) {
      return function() {
        return _this.jumpForward();
      };
    })(this));
    this.speedElement.click((function(_this) {
      return function(event) {
        return _this.changePlaySpeed();
      };
    })(this));
    this.timeElement.click((function(_this) {
      return function() {
        return _this.switchTimeDisplay();
      };
    })(this));
    return $('.rail').on('mousedown', (function(_this) {
      return function(event) {
        _this.handleMouseMove(event);
        $(_this).on('mousemove', function(event) {
          return _this.handleMouseMove(event);
        });
        return $(_this).on('mouseup', function(event) {
          $(_this).off('mousemove');
          return $(_this).off('mouseup');
        });
      };
    })(this));
  };

  PodiPlay.prototype.bindPlayerEvents = function() {
    $(this.player).on('timeupdate', this.updateTime);
    $(this.player).on('play', this.triggerPlaying);
    $(this.player).on('playing', this.triggerPlaying);
    $(this.player).on('seeking', this.triggerLoading);
    $(this.player).on('seeked', this.triggerLoaded);
    $(this.player).on('waiting', this.triggerLoading);
    $(this.player).on('loadeddata', this.triggerLoaded);
    $(this.player).on('canplay', this.triggerLoaded);
    return $(this.player).on('error', this.triggerError);
  };

  return PodiPlay;

})();

player = new PodiPlay('.video-player');
