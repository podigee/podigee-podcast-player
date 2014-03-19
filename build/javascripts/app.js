var PodiPlay,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

PodiPlay = (function() {
  function PodiPlay(elemClass, options, data) {
    this.elemClass = elemClass;
    this.sendHeightChange = __bind(this.sendHeightChange, this);
    this.initMoreInfo = __bind(this.initMoreInfo, this);
    this.initChaptermarks = __bind(this.initChaptermarks, this);
    this.chapterClickCallback = __bind(this.chapterClickCallback, this);
    this.jumpForward = __bind(this.jumpForward, this);
    this.jumpBackward = __bind(this.jumpBackward, this);
    this.setPlaySpeed = __bind(this.setPlaySpeed, this);
    this.changePlaySpeed = __bind(this.changePlaySpeed, this);
    this.adjustPlaySpeed = __bind(this.adjustPlaySpeed, this);
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
    this.initChromeCastSupport = __bind(this.initChromeCastSupport, this);
    this.initAudioPlayer = __bind(this.initAudioPlayer, this);
    this.renderTheme = __bind(this.renderTheme, this);
    this.setOptions(options);
    this.data = data;
    this.renderTheme();
    this.initAudioPlayer();
  }

  PodiPlay.prototype.defaultOptions = {
    currentPlaybackRate: 1,
    playbackRates: [1.0, 1.5, 2.0],
    timeMode: 'countup',
    backwardSeconds: 10,
    forwardSeconds: 30,
    showChaptermarks: false,
    showMoreInfo: false
  };

  PodiPlay.prototype.setOptions = function(options) {
    return this.options = $.extend(true, this.defaultOptions, options);
  };

  PodiPlay.prototype.renderTheme = function() {
    return this.elem = new PodiTheme(this.elemClass, this.data).render();
  };

  PodiPlay.prototype.initAudioPlayer = function() {
    var audioElem;
    audioElem = this.elem.find('audio')[0];
    return new MediaElement(audioElem, {
      success: (function(_this) {
        return function(media, elem) {
          return _this.init(media, elem);
        };
      })(this)
    });
  };

  PodiPlay.prototype.init = function(player, elem) {
    var that;
    this.player = player;
    that = this;
    this.findElements();
    this.initScrubber();
    this.bindButtons();
    this.bindPlayerEvents();
    this.initChaptermarks();
    this.initMoreInfo();
    return this.initChromeCastSupport();
  };

  PodiPlay.prototype.initChromeCastSupport = function() {
    return window.__onGCastApiAvailable = (function(_this) {
      return function(loaded, errorInfo) {
        if (loaded) {
          return _this.chromecast = new PodiCast(_this);
        } else {
          return console.log(errorInfo);
        }
      };
    })(this);
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
    this.speedElement = this.elem.find('.speed-toggle');
    this.chaptermarkButtonElement = this.elem.find('.chaptermarks-button');
    this.chaptermarkElement = this.elem.find('.chaptermarks');
    this.moreInfoButtonElement = this.elem.find('.more-info-button');
    return this.moreInfoElement = this.elem.find('.more-info');
  };

  PodiPlay.prototype.scrubberWidth = function() {
    return this.scrubberRailElement.width();
  };

  PodiPlay.prototype.initScrubber = function() {
    var newWidth;
    newWidth = this.scrubberElement.width() - this.timeElement.width();
    this.scrubberRailElement.width(newWidth);
    this.initLoadingAnimation();
    return window.onresize = (function(_this) {
      return function() {
        return _this.initScrubber();
      };
    })(this);
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
    this.options.timeMode = this.options.timeMode === 'countup' ? 'countdown' : 'countup';
    return this.updateTime();
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

  PodiPlay.prototype.hhmmssToSeconds = function(string) {
    var hours, minutes, parts, result, seconds;
    parts = string.split(':');
    seconds = parseInt(parts[2], 10);
    minutes = parseInt(parts[1], 10);
    hours = parseInt(parts[0], 10);
    return result = seconds + minutes * 60 + hours * 60 * 60;
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
    time = this.options.timeMode === 'countup' ? (prefix = '', this.player.currentTime) : (prefix = '-', this.player.duration - this.player.currentTime);
    timeString = this.secondsToHHMMSS(time);
    this.timeElement.text(prefix + timeString);
    this.updateScrubber();
    return this.adjustPlaySpeed(timeString);
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

  PodiPlay.prototype.tempPlayBackSpeed = null;

  PodiPlay.prototype.adjustPlaySpeed = function(timeString) {
    var currentTime, data, item;
    currentTime = this.player.currentTime;
    data = production_data.statistics.music_speech;
    item = $.grep(data, function(item, index) {
      return item.start.indexOf(timeString) !== -1;
    });
    if (item.length) {
      if (item[0].label === 'music') {
        if (this.options.currentPlaybackRate !== 1.0) {
          this.tempPlayBackSpeed = this.options.currentPlaybackRate;
          return this.setPlaySpeed(1.0);
        }
      } else {
        if (this.tempPlayBackSpeed) {
          this.setPlaySpeed(this.tempPlayBackSpeed);
          return this.tempPlayBackSpeed = null;
        }
      }
    }
  };

  PodiPlay.prototype.changePlaySpeed = function() {
    var nextRateIndex;
    nextRateIndex = this.options.playbackRates.indexOf(this.options.currentPlaybackRate) + 1;
    if (nextRateIndex >= this.options.playbackRates.length) {
      nextRateIndex = 0;
    }
    return this.setPlaySpeed(this.options.playbackRates[nextRateIndex]);
  };

  PodiPlay.prototype.setPlaySpeed = function(speed) {
    this.player.playbackRate = this.options.currentPlaybackRate = speed;
    return this.speedElement.text("" + this.options.currentPlaybackRate + "x");
  };

  PodiPlay.prototype.jumpBackward = function(seconds) {
    seconds = seconds || this.options.backwardSeconds;
    return this.player.currentTime = this.player.currentTime - seconds;
  };

  PodiPlay.prototype.jumpForward = function(seconds) {
    seconds = seconds || this.options.forwardSeconds;
    return this.player.currentTime = this.player.currentTime + seconds;
  };

  PodiPlay.prototype.bindButtons = function() {
    this.playPauseElement.click((function(_this) {
      return function() {
        if (_this.chromecast) {
          if (_this.chromecast.paused()) {
            _this.chromecast.play();
          } else {
            _this.chromecast.pause();
          }
        } else {
          if (_this.player.paused) {
            _this.player.play();
          } else {
            _this.player.pause();
          }
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

  PodiPlay.prototype.chapterClickCallback = function(event) {
    var time;
    time = event.data.start;
    return this.player.currentTime = this.hhmmssToSeconds(time);
  };

  PodiPlay.prototype.initChaptermarks = function() {
    var html;
    html = $('<ul>');
    this.data.chaptermarks.forEach((function(_this) {
      return function(item, index, array) {
        var chaptermark;
        chaptermark = new PodiChaptermark(item, _this.chapterClickCallback).render();
        return html.append(chaptermark);
      };
    })(this));
    this.chaptermarkElement.append(html);
    if (this.options.showChaptermarks) {
      this.chaptermarkElement.show();
    } else {
      this.chaptermarkElement.hide();
    }
    return this.chaptermarkButtonElement.on('click', (function(_this) {
      return function() {
        return _this.chaptermarkElement.slideToggle(400, _this.sendHeightChange);
      };
    })(this));
  };

  PodiPlay.prototype.initMoreInfo = function() {
    if (this.options.showInfo) {
      this.moreInfoElement.show();
    } else {
      this.moreInfoElement.hide();
    }
    return this.moreInfoButtonElement.on('click', (function(_this) {
      return function() {
        return _this.moreInfoElement.slideToggle(400, _this.sendHeightChange);
      };
    })(this));
  };

  PodiPlay.prototype.sendHeightChange = function() {
    var height;
    height = this.elem.height() + 2 * parseInt(this.elem.css('padding-top'), 10);
    return window.parent.postMessage("resize:" + height, '*');
  };

  return PodiPlay;

})();
