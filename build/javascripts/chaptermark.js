var PodiChaptermark,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

PodiChaptermark = (function() {
  function PodiChaptermark(data, callback) {
    this.render = __bind(this.render, this);
    this.data = data;
    this.callback = callback;
  }

  PodiChaptermark.prototype.render = function() {
    var template;
    template = Handlebars.compile(this.defaultHtml);
    return $(template(this.data)).on('click', null, this.data, this.callback);
  };

  PodiChaptermark.prototype.defaultHtml = "<li data-start=\"{{start}}\">\n  {{#if image}}\n    <img src=\"{{image}}\" />\n  {{/if}}\n  {{title}}\n</li>";

  return PodiChaptermark;

})();
