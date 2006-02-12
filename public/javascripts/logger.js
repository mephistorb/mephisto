// Logger v0.2
// Copyright (c) 2005 Justin Palmer (http://encytemedia.com)
// 
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
var Logger = Class.create();
Logger.prototype = {  
  initialize: function(level, options) {
    this.levels = new Array('info', 'debug', 'warn', 'error', 'fatal');
    this.colors = $H({info: '#3cf', warn: '#fc3', error: '#c30', debug: '#3c0', fatal: '#fff'});
    this.messages = new Array();
    this.loaded = false;
    this.level = this.levels.include(level) ? level : "info";
    window.onerror = this.fatal.bind(this);
    Event.observe(window, 'load', this.send.bind(this));
    // Event.observe(window, 'error', this.fatal.bind(this));
  },
  
  info: function(msg) {
    this.log('info', msg, arguments);
  },
  
  debug: function(msg) {
    this.log('debug', msg, arguments);
  },
  
  warn: function(msg) {
    this.log('warn', msg, arguments);
  },
  
  error: function(msg) {
    this.log('error', msg, arguments);
  },
  
  fatal: function(msg, url, line) {
    msg = "Error: " + msg + "\n URL: " + url + "\n LINE: " + line;
    this.log('fatal', msg, arguments);
  },
  
  log: function(level, str, args) {
    if(this.treatAsCode(args)) str = "<pre><code>" + str.escapeHTML() + "</code></pre>";
    
    var color = this.colors[level];
    var chunk = '<li style="color:' + color + ';" class="ll-' + level + '">' + str + '</li>';
    if(!this.loaded) {
      this.messages.push(chunk);
    } else {
      this.messages.push(chunk);
      if(args[2]) return $('info').value = str;
      new Insertion.Bottom('log-panel-list', chunk);
    }
  },
  
  write: function() {
   var messages = this.messages.join(' ');
   new Insertion.Bottom('log-panel-list', messages);
  },
  
  buildPanel: function() {
    this.buildExpander();
    var panel = $('log-panel');
    panel.style.fontFamily = '"Lucida Grande", Helvetica, sans-serif';
    panel.style.position = "fixed";
    panel.style.bottom = "0";
    panel.style.borderTop = "2px solid #555";
    panel.style.left = "0";
    panel.style.textAlign = "left";
    panel.style.fontSize = "80%";
    panel.style.padding = "20px";
    panel.style.height = "400px";
    panel.style.display = "none";
    panel.style.background = "#000";
    panel.style.color = "#fff";
    panel.style.width = "100%";
    panel.style.overflow = "auto";
  },
  
  buildExpander: function() {
    var xpand = Builder.node('a', {id: 'log-xpand', onclick: "Element.toggle('log-panel')"}, 'Console');
    var body = document.getElementsByTagName('body')[0];
    body.appendChild(xpand);
    Element.setStyle(xpand, {
      position: 'absolute',
      right:    '195px',
      top:      '5px',
      color:    '#333',
      fontSize: '80%',
      cursor:   'pointer'
    });
  },
  
  treatAsCode: function(args) {
    if(args.length > 1) return args[1] == true;
    
    return false;
  },
  
  send: function() {
    this.buildPanel();
    this.loaded = true;
    this.write();
    // if (this.messages.length > 0)
     // Element.toggle('log-panel');
  }
  
}

// var logger = new Logger();