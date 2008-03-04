/*
  Class, version 2.2
  Copyright (c) 2006, Alex Arnell <alex@twologic.com>
  Licensed under the new BSD License. See end of file for full license terms.
*/
var Class = {
  extend: function(parent, def) {
    if (arguments.length == 1) def = parent, parent = null;
    var func = function() {
      if (!Class.extending) this.initialize.apply(this, arguments);
    };
    if (typeof(parent) == 'function') {
      Class.extending = true;
      func.prototype = new parent();
      delete Class.extending;
    }
    var mixins = [];
    if (def && def.include) {
      if (def.include.reverse) {
        // methods defined in later mixins should override prior
        mixins = mixins.concat(def.include.reverse());
      } else {
        mixins.push(def.include);
      }
      delete def.include; // clean syntax sugar
    }
    if (def) Class.inherit(func.prototype, def);
    for (var i = 0; (mixin = mixins[i]); i++) {
      Class.mixin(func.prototype, mixin);
    }
    return func;
  },
  mixin: function (dest) {
    for (var i = 1; (src = arguments[i]); i++) {
      if (typeof(src) != 'undefined' && src !== null) {
        for (var prop in src) {
          if (!dest[prop] && typeof(src[prop]) == 'function') {
            // only mixin functions, if they don't previously exist
            dest[prop] = src[prop];
          }
        }
      }
    }
    return dest;
  },
  inherit: function(dest, src, fname) {
    if (arguments.length == 3) {
      var ancestor = dest[fname], descendent = src[fname], method = descendent;
      descendent = function() {
        var ref = this.parent; this.parent = ancestor;
        var result = method.apply(this, arguments);
        ref ? this.parent = ref : delete this.parent;
        return result;
      };
      // mask the underlying method
      descendent.valueOf = function() { return method; };
      descendent.toString = function() { return method.toString(); };
      dest[fname] = descendent;
    } else {
      for (var prop in src) {
        if (dest[prop] && typeof(src[prop]) == 'function') {
          Class.inherit(dest, src, prop);
        } else {
          dest[prop] = src[prop];
        }
      }
    }
    return dest;
  },
  // finally remap Class.create for backward compatability
  create: function() {
    return Class.extend.apply(this, arguments);
  }
};
/*
  Redistribution and use in source and binary forms, with or without modification, are
  permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list
    of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this
    list of conditions and the following disclaimer in the documentation and/or other
    materials provided with the distribution.
  * Neither the name of typicalnoise.com nor the names of its contributors may be
    used to endorse or promote products derived from this software without specific prior
    written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
  THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
  OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
  TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


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

Object.extend(Array.prototype, {
  toQueryString: function(name) {
    return this.collect(function(item) { return name + "[]=" + encodeURIComponent(item) }).join('&');
  }
});

var TinyTab = Class.create();
TinyTab.callbacks ={
  'latest-files': function() {
    if($('latest-assets').childNodes.length == 0)
      new Ajax.Request(Mephisto.root + '/admin/assets;latest');
  },
  'search-files': function(q) {
    if(!q) return;
    $('spinner').show();
    new Ajax.Request(Mephisto.root + '/admin/assets;search', {parameters: 'q=' + escape(q)});
  }
};

TinyTab.prototype = {
  initialize: function(element, panels) {
    this.container = $(element);
    this.tabPanelContainer = $(panels);
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
        
        if(TinyTab.callbacks[finding]) TinyTab.callbacks[finding]();
        
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
    article_id   = location.href.match(/\/(edit|upload)\/([0-9]+)/);
    form.action  = Mephisto.root + "/admin/articles/upload"
    if(article_id) form.action += "/" + article_id[2]
    form.submit();
  },
  
  addInput: function() {
    var list = $('filefields'), copyFrom = list.down(), tagsall = $('tagsall');
    var newNode = copyFrom.cloneNode(true), files = list.getElementsByTagName('li');
    var close = document.getElementsByClassName('remove-file', newNode)[0]; 
    Element.remove(document.getElementsByClassName('tagsall', newNode)[0]);
    Event.observe(close, 'click', function(e) { 
      Event.findElement(e, 'li').remove(); 
      if(tagsall.visible() && files.length == 1) tagsall.hide();
    });
    close.show();
    if(!tagsall.visible() && files.length > 0) tagsall.show();
    list.appendChild(newNode);
  },
  
  removeInput: function(input, formId, inputClass) {
    var length = $$('#' + formId + ' .' + inputClass).findAll(function(e) { return e.visible(); }).length;
    if(length == 2) this.showTitle('asset_title');
    $(input).up('dd').visualEffect('drop_out');
    
    return false;
  },
  
  hideTitle: function(titleId) {
    var dd = $(titleId).up('dd');
    var dt = dd.previous('dt');
    [dd, dt].each(Element.hide);
  },
  
  showTitle: function(titleId) {
    var dd = $(titleId).up('dd');
    var dt = dd.previous('dt');
    [dd, dt].each(Element.show);
  }
}


/*-------------------- Flash ------------------------------*/
// Flash is used to manage error messages and notices from 
// Ajax calls.
//
var Flash = {
  // When given an flash message, wrap it in a list 
  // and show it on the screen.  This message will auto-hide 
  // after a specified amount of milliseconds
  show: function(flashType, message) {
    new Effect.ScrollTo('flash-' + flashType);
    $('flash-' + flashType).innerHTML = '';
    if(message.toString().match(/<li/)) message = "<ul>" + message + '</ul>'
    $('flash-' + flashType).innerHTML = message;
    new Effect.Appear('flash-' + flashType, {duration: 0.3});
    setTimeout(Flash['fade' + flashType[0].toUpperCase() + flashType.slice(1, flashType.length)].bind(this), 5000)
  },
  
  errors: function(message) {
    this.show('errors', message);
  },

  // Notice-level messages.  See Messenger.error for full details.
  notice: function(message) {
    this.show('notice', message);
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
    if(isDraft) ['publish-date-lbl', 'publish-date'].each(Element.hide);
    else ['publish-date-lbl', 'publish-date'].each(Element.show);
  },

  getAvailableComments: function() {
    return $$('ul.commentlist li').reject(function(div) { return !(div.visible() && !div.hasClassName('disabled') && div.id.match(/^comment-/)); }).collect(function(div) { return div.id.match(/comment-(\d+)/)[1] });
  },

  attachAsset: function(assetId) {
    var articleId = location.href.match(/\/([0-9]+)\/(edit|upload)/)[1];
    var attached  = $('attached-widget-' + assetId);
    if(attached) return;
    new Ajax.Request('/admin/articles/attach/' + articleId + '/' + assetId);
    $$('.widget').each(function(asset) { if(assetId == asset.getAttribute('id').match(/-(\d+)$/)[1]) asset.addClassName('selected-widget'); });
  },

  labelAsset: function(assetId) {
    var articleId = location.href.match(/\/([0-9]+)\/(edit|upload)/)[1];
    var attached  = $('attached-widget-' + assetId);
    var label     = $('attached-widget-version-' + assetId);
    new Ajax.Request('/admin/articles/label/' + articleId + '/' + assetId + '?label=' + escape(label.value));
    if(attached) return;
  },

  detachAsset: function(assetId) {
    var articleId = location.href.match(/\/([0-9]+)\/(edit|upload)/)[1];
    var attached  = $('attached-widget-' + assetId);
    if(!attached) return;
    new Ajax.Request('/admin/articles/detach/' + articleId + '/' + assetId);
    new Effect.DropOut(attached, {afterFinish: function() { attached.remove(); }});
    $$('.widget').each(function(asset) { if(assetId == asset.getAttribute('id').match(/-(\d+)$/)[1]) asset.removeClassName('selected-widget'); });
  },

  getRevision: function() {
    var rev = $F(this)
    var url = Mephisto.root + '/admin/articles/' + location.href.match(/\/([0-9]+)\/edit/)[1] + "/edit";
		if(rev != '0') url += "?version=" + rev;
    location.href = url;
  }
}

Comments = {
  filter: function() {
    location.href = "?filter=" + $F(this).toLowerCase();
  }
}

var UserForm = {
  toggle: function(chk) {
    $('user-' + chk.getAttribute('value') + '-progress').show();
    new Ajax.Request(Mephisto.root + '/admin/users/' + (chk.checked ? 'enable' : 'destroy') + '/' + chk.getAttribute('value'));
  },
  toggleAdmin: function(chk) {
    $('user-' + chk.getAttribute('value') + '-progress').show();
    new Ajax.Request(Mephisto.root + '/admin/users/admin/' + chk.getAttribute('value'));
  }
}

var SectionForm = {
  toggleSettings: function() {
    Element.toggle('blog-options');
  },

  sortable: null,
  toggleSortable: function(link, section_id, container_id) {
    if($(container_id).className == 'sortable') {
      Sortable.destroy(container_id);
      $(container_id).className = '';
      link.innerHTML = 'Reorder ' + container_id;
      link.className = 'reorder';
      this.saveSortable(section_id, container_id);
    } else {
      this.sortable = Sortable.create(container_id, {handle:'handle'});
      $(container_id).className = 'sortable';
      link.className = 'reordering';
      link.innerHTML = 'Done Reordering'
    }
  },

  saveSortable: function(section_id, container_id) {
    var query = $$('#'+container_id+' li').inject([], function(qu, li) {
      qu.push('sorted_ids[]=' + li.getAttribute('id').substr(container_id.length));
      return qu;
    }).join('&')
    new Ajax.Request(Mephisto.root + '/admin/sections/order/' + section_id, {asynchronous:true, evalScripts:true, parameters:query});
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
  
  search: function(page) {
    $('spinner').show();
    $('page').value = page || '1';
    new Ajax.Request(this.form.action, {
      asynchronous: true, 
      evalScripts:  true, 
      parameters:   Form.serialize(this.form),
      method: 'get'
    }); 
    return false;
  }
}


/*
 * Implement a custom Event Observer.  Makes it easeir to do 
 * OSX Spotlight style searching where specific elements are 
 * shown based on the previous selection.
 */
 
Abstract.SmartEventObserver = Class.extend(Abstract.EventObserver, {
  onElementEvent: function(event) {
    var value = this.getValue();
    if (this.lastValue != value) {
      this.callback(Event.element(event), value, event);
      this.lastValue = value;
    }
  }
});

var SmartForm = {};
SmartForm.EventObserver = Class.extend(Abstract.SmartEventObserver, {
  getValue: function() {
    return Form.serialize(this.element);
  }
});

var SmartSearch = Class.create();
SmartSearch.prototype = {
  initialize: function(form, conditions, triggersSubmit) {
    this.element = $(form);
    this.conditions = $A(conditions);
    this.triggersSubmit = $(triggersSubmit);
    if(!this.element) return;
    
    new SmartForm.EventObserver(this.element, this.onChange.bind(this));
  },
  
  onChange: function(element, event) {
    if(element == this.triggersSubmit) {
      this.element.submit();
      return false;
    }
    
    this.conditions.each(function(condition) {
      if(condition.keys.include($F(element))) {
        $A(condition.show).each(function(e) { $(e).show(); });
        $A(condition.hide).each(function(e) { $(e).hide(); });
      }
    }.bind(this));
    return false;
  }
}


ToolBox = Class.create();
ToolBox.current = null;
ToolBox.prototype = {      
  initialize: function(element) {       
    this.toolbox = $(element);
    if(!this.toolbox) return;
    this.timeout = null;
    this.tools = this.findTools();
    
    Event.observe(this.toolbox, 'mouseover', this.onHover.bindAsEventListener(this), true);
    Event.observe(this.toolbox, 'mouseout', this.onBlur.bindAsEventListener(this), true);
    Event.observe(this.tools, 'mouseover', this.onHover.bindAsEventListener(this));
    Event.observe(this.tools, 'mouseout', this.onBlur.bindAsEventListener(this));
  },
  
  show: function() {
    if(this.timeout) { 
      clearTimeout(this.timeout); 
      this.timeout = null;
    }    
    
    if(ToolBox.current) {
      ToolBox.current.hideTools();      
    }
    
    if(this.tools) { 
      Element.show(this.tools); 
      ToolBox.current = this;
    }    
  },

  onHover: function(event) {
    this.show();
  },

  onBlur: function(event) {
    this.considerHidingTools();
  },

  considerHidingTools: function() {
    if(this.timeout) { clearTimeout(this.timeout); }
    this.timeout = setTimeout(this.hideTools.bind(this), 500);
  },

  hideTools: function() {
    clearTimeout(this.timeout);
    this.timeout = null;
    Element.hide(this.tools);          
  },

  findTools: function() { 
    var tools = document.getElementsByClassName('tools', this.toolbox)[0];
    if(!tools) { throw "You called new ToolBox() on an element which has no class=\"tools\" child element"; }
    return tools;
  }
}

var Mephisto = { root: '' };

Effect.DefaultOptions.duration = 0.25;
Event.addBehavior({
  '#filesearch':     function() { window.spotlight = new Spotlight('filesearchform', 'filesearch'); },
  '#comments-view':  function() { Event.observe(this, 'change', Comments.filter.bind(this)); },
  '#article-draft':  function() { Event.observe(this, 'change', ArticleForm.saveDraft.bind(this)); },
  '#revisionnum':    function() { Event.observe(this, 'change', ArticleForm.getRevision.bind(this)); },
  '#reset_password': function() { this.hide(); },
  '#reset_password_link:click,#reset_password_cancel:click': function() { Effect.toggle('reset_password', 'blind'); },
  '#asset-add-file:click': function() { return Asset.addInput(); },
  '#sec-options-trigger:click': function() { $('sec-options').toggle(); },
  '#disabled_users_trigger:click': function() { $('disabled_users').toggle(); },
  '#tagsall:click': function() { 
    var inputs = $('new_asset').getInputs('text');
    var tags = $F(inputs.first()).split(',');
    tags = tags.collect(function(t) { return t.strip(); });
    inputs.each(function(e, index) {
      if(index > 0) {
        var localtags = $F(e).split(',').findAll(function(t) { return t.length > 0 });
        localtags = localtags.collect(function(t) { return t.strip(); });
        localtags.push(tags);
        e.value = localtags.flatten().uniq().join(', ');
      }
    }
  )},
  '#article-search': function() {
    new SmartSearch('article-search', [
      {keys: ['section'],               show: ['sectionlist'],  hide: ['manualsearch', 'searchsubmit']},
      {keys: ['title', 'body', 'tags'], show: ['manualsearch'], hide: ['sectionlist', 'searchsubmit']},
      {keys: ['draft'],                 show: ['searchsubmit'], hide: ['manualsearch', 'sectionlist']}
    ], 'sectionlist')
  },

  '#searchsubmit:click': function() { 
    $('published').value = '0';
    $('article-search').submit();
  },

  'li.widget:mouseover': function() {
    var attach = $('attach-' + this.getAttribute('id'));
    var detach = $('detach-' + this.getAttribute('id'));
    if(attach) attach.show();
    if(detach) detach.show();
  },
  
  'li.widget:mouseout': function() {
    var attach = $('attach-' + this.getAttribute('id'));
    var detach = $('detach-' + this.getAttribute('id'));
    if(attach) attach.hide();
    if(detach) detach.hide();
  },
  
  '.attach-widget:click': function() {
    ArticleForm.attachAsset(this.getAttribute('id').match(/-(\d+)$/)[1]);
    return false;
  },
  
  '.label-widget:click': function() {
    ArticleForm.labelAsset(this.getAttribute('id').match(/-(\d+)$/)[1]);
    this.innerHTML = 'Saving...'
    return false;
  },
  
  '.detach-widget:click': function() {
    ArticleForm.detachAsset(this.getAttribute('id').match(/-(\d+)$/)[1]);
    return false;
  },

  'a.theme_dialog:click': function() {
    var img = this.down('img');
    var pieces = img.src.split('/');
    new Dialog.Rjs();
    new Ajax.Request(Mephisto.root + '/admin/themes/show/' + pieces[pieces.length-1]);
  }
  
  //'.theme': function() {
  //  new ToolBox(this);
  //}
});

Event.onReady(function() {
  new DropMenu('select');
  TinyTab.filetabs = new TinyTab('filetabs', 'tabpanels');

  ['notice', 'errors'].each(function(flashType) {
    var el = $('flash-' + flashType);
    if(el.innerHTML != '') Flash.show(flashType, el.innerHTML);
  })
  
});

