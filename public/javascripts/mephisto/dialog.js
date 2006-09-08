// Returns array with x,y page scroll values.
// Core code from - quirksmode.org
Position.getPageScroll = function() {
  if(self.pageYOffset)
    return self.pageYOffset;
  if(document.documentElement && document.documentElement.scrollTop) // Explorer 6 Strict
    return document.documentElement.scrollTop;
  if(document.body) // all other Explorers
    return document.body.scrollTop;
}

// Returns array with page width, height and window width, height
// Core code from - quirksmode.org
// Edit for Firefox by pHaez
Position.getPageSize = function() {
  var xScroll, yScroll;

  if (window.innerHeight && window.scrollMaxY) {  
    xScroll = document.body.scrollWidth;
    yScroll = window.innerHeight + window.scrollMaxY;
  } else if (document.body.scrollHeight > document.body.offsetHeight){ // all but Explorer Mac
    xScroll = document.body.scrollWidth;
    yScroll = document.body.scrollHeight;
  } else { // Explorer Mac...would also work in Explorer 6 Strict, Mozilla and Safari
    xScroll = document.body.offsetWidth;
    yScroll = document.body.offsetHeight;
  }

  var windowWidth, windowHeight;
  if (self.innerHeight) { // all except Explorer
    windowWidth = self.innerWidth;
    windowHeight = self.innerHeight;
  } else if (document.documentElement && document.documentElement.clientHeight) { // Explorer 6 Strict Mode
    windowWidth = document.documentElement.clientWidth;
    windowHeight = document.documentElement.clientHeight;
  } else if (document.body) { // other Explorers
    windowWidth = document.body.clientWidth;
    windowHeight = document.body.clientHeight;
  } 

  // for small pages with total height less then height of the viewport
  pageHeight = Math.max(windowHeight, yScroll);

  // for small pages with total width less then width of the viewport
  pageWidth = Math.max(windowWidth, xScroll);

  return { page: { width: pageWidth, height: pageHeight }, window: { width: windowWidth, height: windowHeight } };
}

var Dialog = {
  clear_observers: function() {
    if (!Dialog.resizeObserver) return;    
    Event.stopObserving(window, 'resize', Dialog.resizeObserver);
    Event.stopObserving(window, 'scroll', Dialog.resizeObserver);
    Dialog.resizeObserver = null;
    Dialog.current        = null;
  },

  close: function() {
    this.clear_observers();
    ['dialog', 'dialog_box'].each(function(d) { if($(d)) Element.remove(d); });
  },
  
  Base:    Class.create(),
  Confirm: Class.create()
};

Dialog.Base.prototype = {
  defaultOptions: {
    dialogClass:     '',
    message:         '',
    messageTemplate: "<div>#{message}</div>"
  },

  initialize: function(options) {
    this.options = Object.extend(Object.extend({}, this.defaultOptions), options);
    this.create();
  },

  setupDialog: function() {
    dialog     = document.createElement('div');
    dialog_box = document.createElement('div');
    dialog.setAttribute('id', 'dialog');
    dialog_box.setAttribute('id', 'dialog_box');
    Element.setStyle(dialog,     {zIndex: 100});
    Element.setStyle(dialog_box, {zIndex: 101, display:'none'});
    [dialog, dialog_box].each(function(d) { d.className = this.options.dialogClass; }.bind(this));
    this.setMessage(dialog_box);
  },

  setMessage: function(dialog_box) {
    var tmpl             = new Template(this.options.messageTemplate);
    dialog_box.innerHTML = tmpl.evaluate({message: this.options.message});
  },

  create: function() {
    this.setupDialog();
    document.body.appendChild(dialog);
    document.body.appendChild(dialog_box);
    this.afterCreate();
  },
  
  afterCreate: function() {
    this.layout();
    Dialog.resizeObserver = this.layout.bind(this);
    Event.observe(window, 'resize', Dialog.resizeObserver);
    Event.observe(window, 'scroll', Dialog.resizeObserver);

    new Effect.Fade(dialog, {from: 0.1, to: 0.4, duration:0.15});
    new Effect.Appear(dialog_box, {duration:0.4});
    Dialog.current = this;
  },

  layout: function() {
    var pg_dimensions = Position.getPageSize();
    var el_dimensions = Element.getDimensions('dialog_box');
    var scrollY       = Position.getPageScroll();
    
    Element.setStyle('dialog', {
      position:'absolute', top:0, left:0,
      width: pg_dimensions.window.width  + 'px',
      height:pg_dimensions.window.height + 'px'
    });

    Element.setStyle('dialog_box', {
      position:'absolute',
      top:  ((pg_dimensions.window.height - el_dimensions.height) / 2) + scrollY + 'px',
      left: ((pg_dimensions.page.width    - el_dimensions.width)  / 2) + 'px'
    })
  },

  close: function() {
    new Effect.Fade('dialog_box', {duration: 0.2, afterFinish: function() {
      if(Dialog.current.options.onClose) Dialog.current.options.onClose();
      Dialog.close();
    }});
  }
};

Object.extend(Object.extend(Dialog.Confirm.prototype, Dialog.Base.prototype), {
  defaultOptions: Object.extend(Object.extend({}, Dialog.Base.prototype.defaultOptions), {
    okayText:        "OK",
    cancelText:      "CANCEL",
    okayImage:       '',
    cancelImage:     '',
    onOkay:   function() {},
    onCancel: function() {}
  }),
  
  beforeSetupDialog: Dialog.Base.prototype.setupDialog,
  setupDialog: function() {
    this.beforeSetupDialog();
    dialog_box.appendChild(this.create_buttons());
  },

  onOkay: function() {
    Dialog.current.options.onOkay();
  },
  
  onCancel: function() {
    Dialog.current.close();
    Dialog.current.options.onCancel();
  },

  create_buttons: function() {
    var buttons             = document.createElement('p');
    buttons.className       = 'buttons';

    var okay_button         = document.createElement('a');
    Event.observe(okay_button, 'click', function() { Dialog.current.onOkay(); });
    okay_button.className   = 'okay';
    okay_button.setAttribute('href', '#');
    if(this.options.okayImage == '') {
      okay_button.innerHTML = this.options.okayText;
    } else {
      var okay_image        = document.createElement('img');
      okay_image.src        = this.options.okayImage;
      okay_image.setAttribute('alt', this.options.okayText);
      okay_button.appendChild(okay_image);
    }
    
    var cancel_button       = document.createElement('a');
    Event.observe(cancel_button, 'click', function() { Dialog.current.onCancel(); });
    cancel_button.className   = 'cancel';
    cancel_button.setAttribute('href', '#');
    if(this.options.cancelImage == '') {
      cancel_button.innerHTML = this.options.cancelText;
    } else {
      var cancel_image      = document.createElement('img');
      cancel_image.src      = this.options.cancelImage;
      cancel_image.setAttribute('alt', this.options.cancelText);
      cancel_button.appendChild(cancel_image);
    }
    
    buttons.appendChild(okay_button);
    buttons.appendChild(cancel_button);
    return buttons;
  }
});