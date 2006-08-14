// TODO:  Fix buggles
var DropMenu = Class.create();
DropMenu.prototype = {
  initialize: function(element) {
    this.menu = $(element);
    if(!this.menu) return;
    this.trigger = document.getElementsByClassName('trigger', this.menu)[0];
    this.options = $('optgroup');
    this.focused = false;
    
    Event.observe(this.trigger, 'click', this.onTriggerClick.bindAsEventListener(this));
    Event.observe(this.menu, 'mouseover', this.onMenuFocus.bindAsEventListener(this));
    Event.observe(this.menu, 'mouseout', this.onMenuBlur.bindAsEventListener(this));
  },
  
  onTriggerClick: function(event) {
    Event.stop(event);
    Event.element(event).onclick = function() { return false; } //For Safari
    clearTimeout(this.timeout);
    this.options.setStyle({opacity: 1});
    Element.toggle(this.options);
    
    if(this.options.visible())
      Element.addClassName(this.trigger, 'down');
    else
     Element.removeClassName(this.trigger, 'down');
  },
  
  onMenuFocus: function() {
    this.focused = true;
  },
  
  onMenuBlur: function() {
    this.focused = false;
    this.timeout = setTimeout(this.fadeMenu.bind(this), 400);
  },
  
  fadeMenu: function() {
    if(!this.focused) {
      Element.removeClassName(this.trigger, 'down');
      new Effect.Fade(this.options, {duration: 0.2});
    }
  }
}

var TinyTab = Class.create();
TinyTab.prototype = {
  initialize: function(element) {
    this.container = $(element);
    if(!this.container) return;
    
    this.cachedElement;
    this.setup();
  },
  
  setup: function() {
    var links = document.getElementsByClassName('stabs', this.container)[0]
    links.cleanWhitespace();
    this.tabLinks = $A(links.childNodes);
    this.tabPanels = document.getElementsByClassName('tabpanel', this.container);
    
    this.tabLinks.each(function(link) {
      Event.observe(link, 'click', function(event) {
        var element = Event.element(event);
        var finding = element.getAttribute('href').split('#')[1];
        this.tabPanels.each(function(element) { Element.hide(element) });
        
        if(this.cachedElement) {
          this.cachedElement.removeClassName('selected');
        } else {
          this.tabLinks[0].firstChild.removeClassName('selected');
        }
        
        element.addClassName('selected');
        $(finding).show();
        Event.stop(event);
        element.onclick = function() { return false; } //Safari bug
        this.cachedElement = element;
      
      }.bindAsEventListener(this));
    }.bind(this));
  }
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
    new Effect.ScrollTo('flash-notice');
    $('flash-errors').innerHTML = '';
    $('flash-errors').innerHTML = "<ul>" + message + "</ul>";
    new Effect.Appear('flash-errors', {duration: 0.3});
    setTimeout(Flash.fadeError.bind(this), 5000);
  },

  // Notice-level messages.  See Messenger.error for full details.
  notice: function(message) {
    new Effect.ScrollTo('flash-notice');
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

var ArticleForm = {
  saveDraft: function() {
    var isDraft = $F(this);
    if(isDraft) Element.hide('publish-date-lbl', 'publish-date');
    else Element.show('publish-date-lbl', 'publish-date');
  }
}

var UserForm = {
  toggle: function(chk) {
    $('user-' + chk.getAttribute('value') + '-progress').show();
    new Ajax.Request('/admin/users/' + (chk.checked ? 'enable' : 'destroy') + '/' + chk.getAttribute('value'));
  }
}

var SectionForm = {
  toggleSettings: function() {
    Element.toggle('blog-options');
  },

  sortable: null,
  toggleSortable: function(link) {
    if($('pages').className == 'sortable') {
      Sortable.destroy('pages');
      $('pages').className = '';
      link.innerHTML = 'Reorder pages'
      link.className = 'reorder';
      document.getElementsByClassName('handle', 'pages').each(function(img) {
        img.src = "/images/icons/arrow3_e.gif";
      });
      this.saveSortable();
    } else {
      this.sortable = Sortable.create('pages', {handle:'handle'});
      $('pages').className = 'sortable';
      document.getElementsByClassName('handle', 'pages').each(function(img) {
        img.src = "/images/icons/reorder.gif";
      });
      link.className = 'reordering';
      link.innerHTML = 'Done Reordering'
    }
  },

  saveSortable: function() {
    var query = $$('#pages li').inject([], function(qu, li) {
      qu.push('article_ids[]=' + li.getAttribute('id').substr(5));
      return qu;
    }).join('&')
    new Ajax.Request('/admin/sections/order/' + Navigate.currentId(), {asynchronous:true, evalScripts:true, parameters:query});
  }
}

var Spotlight = Class.create();
Spotlight.prototype = {
  initialize: function(form, searchbox) {
    var options, types, attributes = [];
    this.form = $(form);
    var search = $(searchbox);
    Event.observe(searchbox, 'click', function(e) { Event.element(e).value = '' });
    search.setAttribute('autocomplete', 'off');
    
    new Form.Element.Observer(searchbox, 1,  this.search.bind(this));
    
    types = $A($('type').getElementsByTagName('LI'));
    attributes = $A($('attributes').getElementsByTagName('LI'));
    attributes = attributes.reject(function(e) { return e.id.length < 1 });
    attributes.push(types);
    attributes = attributes.flatten();
    console.log(attributes);
    attributes.each(function(attr) {
      Event.observe(attr, 'click', this.onClick.bindAsEventListener(this));
    }.bind(this));
  },
  
  onClick: function(event) {
    var element = Event.element(event), check;
    if(element.tagName != 'LI') element = Event.findElement(event, 'LI');
    var check = ($(element.id + '-check'));
    
    if(Element.hasClassName(element, 'pressed')) {
      Element.removeClassName(element, 'pressed');
      check.removeAttribute('checked');
    } else {
      Element.addClassName(element, 'pressed');
      check.setAttribute('checked', 'checked');
    }
    
    this.search();
  },
  
  search: function() {
    new Ajax.Request(this.form.action, {
      asynchronous: true, 
      evalScripts:  true, 
      parameters:   Form.serialize(this.form)
    }); 
    return false;
  }
}

Event.observe(window, 'load', function() {
  new DropMenu('select');
  new TinyTab('filetabs');
  if($('filesearch')) new Spotlight('filesearchform', 'filesearch');
  
  // TODO: IE doesn't fire onchange for checkbox
  var commentsView   = $('comments-view');
  var articleDraft   = $('article-draft');
  if(commentsView)   Event.observe(commentsView,   'change', ArticleForm.viewComments.bind(commentsView));
  if(articleDraft)   Event.observe(articleDraft,   'change', ArticleForm.saveDraft.bind(articleDraft));
});

