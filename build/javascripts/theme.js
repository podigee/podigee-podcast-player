var PodiTheme,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

PodiTheme = (function() {
  function PodiTheme(render_to, context, html) {
    this.render = __bind(this.render, this);
    this.render_to = $(render_to);
    this.html = html || this.defaultHtml;
    this.context = context;
  }

  PodiTheme.prototype.render = function() {
    var output, template;
    template = Handlebars.compile(this.html);
    output = $(template(this.context));
    this.render_to.replaceWith(output);
    return output;
  };

  PodiTheme.prototype.defaultHtml = "<div class=\"video-player\">\n  <div class=\"info\">\n    <img src=\"{{logo_url}}\" />\n    <div class=\"title\">{{title}}</div>\n    <div class=\"description\">{{subtitle}}</div>\n  </div>\n  <!--<audio id=\"player\" src=\"http://cdn.files.podigee.com/tmp_media/auphonic-example.mp3\" preload=\"metadata\"></audio>-->\n  <audio id=\"player\" src=\"{{playlist.mp3}}\" preload=\"metadata\"></audio>\n  <div class=\"time-scrubber\">\n    <div class=\"time-played\" title=\"Switch display mode\"></div>\n    <div class=\"rail\">\n      <span class=\"time-scrubber-loaded\"></span>\n      <div class=\"time-scrubber-buffering\"></div>\n      <span class=\"time-scrubber-played\"></span>\n    </div>\n  </div>\n\n  <div class=\"controls\">\n    <i class=\"fa fa-backward backward-button\" title=\"Backward 10s\"></i>\n    <i class=\"fa fa-play play-button\" title=\"Play/Pause\"></i>\n    <i class=\"fa fa-forward forward-button\" title=\"Forward 30s\"></i>\n\n    <span class=\"speed-toggle\" title=\"Playback speed\">1x</span>\n  </div>\n\n  <div class=\"buttons\">\n    <i class=\"fa fa-list chaptermarks-button\" title=\"Show chaptermarks\"></i>\n    <i class=\"fa fa-info more-info-button\" title=\"Show more info\"></i>\n  </div>\n  <div class=\"chaptermarks\"></div>\n  <div class=\"more-info\">{{description}}</div>\n</div>";

  return PodiTheme;

})();
