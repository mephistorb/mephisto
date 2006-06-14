// TODO:  Fix buggles
var DropMenu = Class.create();
DropMenu.prototype = {
  initialize: function(element) {
    this.menu = $(element);
    this.trigger = document.getElementsByClassName('trigger', this.menu)[0];
    this.options = $('optgroup');
    this.focused = false;
    
    Event.observe(this.trigger, 'click', this.onTriggerClick.bindAsEventListener(this));
    Event.observe(this.menu, 'mouseover', this.onMenuFocus.bindAsEventListener(this));
    Event.observe(this.menu, 'mouseout', this.onMenuBlur.bindAsEventListener(this));
  },
  
  onTriggerClick: function() {
    clearTimeout(this.timeout);
    this.options.setStyle({opacity: 1});
    Element.toggle(this.options);
  },
  
  onMenuFocus: function() {
    this.focused = true;
  },
  
  onMenuBlur: function() {
    this.focused = false;
    this.timeout = setTimeout(this.fadeMenu.bind(this), 400);
  },
  
  fadeMenu: function() {
    if(!this.focused)
      new Effect.Fade(this.options, {duration: 0.2});
  }
}

// @name      The Fade Anything Technique
// @namespace http://www.axentric.com/aside/fat/
// @version   1.0-RC1
// @author    Adam Michela

var Fat = {
  make_hex : function (r,g,b) 
  {
    r = r.toString(16); if (r.length == 1) r = '0' + r;
    g = g.toString(16); if (g.length == 1) g = '0' + g;
    b = b.toString(16); if (b.length == 1) b = '0' + b;
    return "#" + r + g + b;
  },
  fade_element : function (id, fps, duration, from, to) 
  {
    if (!fps) fps = 30;
    if (!duration) duration = 3000;
    if (!from || from=="#") from = "#FFFF33";
    if (!to) to = this.get_bgcolor(id);
    
    var frames = Math.round(fps * (duration / 1000));
    var interval = duration / frames;
    var delay = interval;
    var frame = 0;
    
    if (from.length < 7) from += from.substr(1,3);
    if (to.length < 7) to += to.substr(1,3);
    
    var rf = parseInt(from.substr(1,2),16);
    var gf = parseInt(from.substr(3,2),16);
    var bf = parseInt(from.substr(5,2),16);
    var rt = parseInt(to.substr(1,2),16);
    var gt = parseInt(to.substr(3,2),16);
    var bt = parseInt(to.substr(5,2),16);
    
    var r,g,b,h;
    while (frame < frames)
    {
      r = Math.floor(rf * ((frames-frame)/frames) + rt * (frame/frames));
      g = Math.floor(gf * ((frames-frame)/frames) + gt * (frame/frames));
      b = Math.floor(bf * ((frames-frame)/frames) + bt * (frame/frames));
      h = this.make_hex(r,g,b);
    
      setTimeout("Fat.set_bgcolor('"+id+"','"+h+"')", delay);

      frame++;
      delay = interval * frame; 
    }
    setTimeout("Fat.set_bgcolor('"+id+"','"+to+"')", delay);
    setTimeout("document.getElementById('"+id+"').style.background = 'none';", delay+1);
  },
  set_bgcolor : function (id, c)
  {
    var o = document.getElementById(id);
    o.style.backgroundColor = c;
  },
  get_bgcolor : function (id)
  {
    var o = document.getElementById(id);
    while(o)
    {
      var c;
      if (window.getComputedStyle) c = window.getComputedStyle(o,null).getPropertyValue("background-color");
      if (o.currentStyle) c = o.currentStyle.backgroundColor;
      if ((c != "" && c != "transparent") || o.tagName == "BODY") { break; }
      o = o.parentNode;
    }
    if (c == undefined || c == "" || c == "transparent") c = "#FFFFFF";
    var rgb = c.match(/rgb\s*\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*\)/);
    if (rgb) c = this.make_hex(parseInt(rgb[1]),parseInt(rgb[2]),parseInt(rgb[3]));
    return c;
  }
}

function highlight_comment() {
  var h = location.hash;
  var c = h ? h.substr(1) : '';
  if(document.getElementById(c)) Fat.fade_element(c, 20, 1500);
}

window.onload = function() {
  highlight_comment();
}



Asset = {
  upload: function(form) {
    form = $(form);
    form.action = "attach_asset"
    form.submit();
  }
}



/*-------------------- Flash ------------------------------*/
// Flash is used to manage error messages and notices from 
// Ajax calls.
//
var Flash = {
  // When given an error message, wrap it in a list 
  // and show it on the screen.  This message will auto-hide 
  // after a specified amount of miliseconds
  error: function(message) {
    $('flash-errors').innerHTML = '';
    $('flash-errors').innerHTML = "<ul>" + message + "</ul>";
    new Effect.Appear('flash-errors', {duration: 0.3});
    setTimeout(Flash.fadeError.bind(this), 5000);
  },

  // Notice-level messages.  See Messenger.error for full details.
  notice: function(message) {
    $('flash-notice').innerHTML = '';
    $('flash-notice').innerHTML = "<li>" + message + "</li>";
    new Effect.Appear('flash-notice', {duration: 0.3});
    setTimeout(Flash.fadeNotice.bind(this), 5000);
  },
  
  // Responsible for fading notices level messages in the dom    
  fadeNotice: function() {
    new Effect.Fade('flash-notice', {duration: 0.3});
  },
  
  // Responsible for fading error messages in the DOM
  fadeError: function() {
    new Effect.Fade('flash-errors', {duration: 0.3});
  }
}

Event.observe(window, 'load', function() {
  new DropMenu('select');
});

