var PodiEmbed,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

PodiEmbed = (function() {
  function PodiEmbed() {
    this.receiveMessage = __bind(this.receiveMessage, this);
    this.init();
  }

  PodiEmbed.prototype.init = function() {
    var elems;
    elems = document.getElementsByClassName('podi-embed');
    this.elem = elems[elems.length - 1];
    this.url = this.elem.dataset.source;
    this.buildIframe();
    this.setupListeners();
    return this.replaceElem();
  };

  PodiEmbed.prototype.buildIframe = function() {
    this.iframe = document.createElement('iframe');
    this.iframe.scrolling = 'no';
    this.iframe.src = this.url;
    this.iframe.style.border = '0';
    this.iframe.style.overflowY = 'hidden';
    this.iframe.style.transition = 'height 100ms linear';
    this.iframe.height = '173px';
    this.iframe.width = '100%';
    return this.iframe;
  };

  PodiEmbed.prototype.setupListeners = function() {
    return window.addEventListener("message", this.receiveMessage, false);
  };

  PodiEmbed.prototype.receiveMessage = function(event) {
    var newHeight;
    newHeight = event.data.split(':')[1];
    return this.iframe.height = "" + newHeight + "px";
  };

  PodiEmbed.prototype.replaceElem = function() {
    return this.elem.parentNode.replaceChild(this.iframe, this.elem);
  };

  return PodiEmbed;

})();

new PodiEmbed();
