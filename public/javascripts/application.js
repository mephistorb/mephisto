Object.extend(Form, {
  default_text: {
    clear: function(input, remove_class) {
      input = $(input);
      if(input.value == input.defaultValue) {
        input.value = '';
        if(arguments.length > 1)
          Element.removeClassName(input, remove_class);
      }
      Event.observe(input, 'blur', function(){ Form.default_text.reset(input, remove_class) });
    },

    reset: function(input, add_class) {
      if(input.value=='') {
        input.value = input.defaultValue;
        if(arguments.length > 1)
          Element.addClassName(input, add_class);
      }
    }
  },

  clear_default_text: function(input, remove_class) {
    Form.default_text.clear(input, remove_class);
  },

  disable_buttons: function(form_id) {
    var form = $(form_id);
    $A(form.getElementsByTagName('input')).each(function(input) {
      if(input.getAttribute('type') == 'submit') {
        input.blur();
        input.disabled = true;
      }
    });
  
    form.old_onsubmit = form.onsubmit;
    form.onsubmit     = function() { return false; }
  },

  enable_buttons: function(form_id) {
    var form = $(form_id);
    $A(form.getElementsByTagName('input')).each(function(input) {
      if(input.getAttribute('type') == 'submit') {
        input.disabled = false;
      }
    });
    form.onsubmit     = form.old_onsubmit;
    form.old_onsubmit = null;
  },

  saving: function(form_name) {
    Form.disable_buttons(form_name + '_form');
    Element.show(form_name + '_spinner');
    Element.hide(form_name + '_cancel');
  },

  saved: function(form_name) {
    Form.enable_buttons(form_name + '_form');
    Element.hide(form_name + '_spinner');
    Element.show(form_name + '_cancel');
  }
})

var Navigate = {
  _id: null,
  currentId: function() {
    if(this._id == null)
      this._id = $A($A(location.href.split('/')).last().split('#')).first();
    return this._id;
  },

  to_template: function(select) {
    this.to_url(select, "/admin/templates/edit/");
  },

  to_paged_section: function(select) {
    this.to_url(select, "/admin/pages/edit?id=");
  },

  to_url: function(select, url) {
    var value = select.options[select.selectedIndex].value;
    if(value) location.href = url + value;
  }
};

Object.extend(Array.prototype, {
  toQueryString: function(name) {
    return this.collect(function(item) { return name + "[]=" + encodeURIComponent(item) }).join('&');
  }
});

var ArticleForm = {
  show: function() {
    new Effect.BlindDown('article_form', {duration: 0.25});
    new Effect.Appear('article_form_hide', {duration: 0.25});
    Element.hide('article_form_show');
  },
  
  hide: function() {
    new Effect.BlindUp('article_form', {duration: 0.25});
    new Effect.Appear('article_form_show', {duration: 0.25});
    Element.hide('article_form_hide');
  },

  toggleSection: function(section_id) {
    var section_li = $('article_section_ids_' + section_id)
    if(Element.hasClassName(section_li, 'selected'))
      this.removeSection(section_id, section_li)
    else
      this.addSection(section_id, section_li)
  },

  addSection: function(section_id, section_li) {
    Element.addClassName(section_li, 'selected')
    
    var hdn = document.createElement('input')
    hdn.setAttribute('type', 'hidden')
    hdn.setAttribute('id', 'article_section_ids_value_' + section_id)
    hdn.setAttribute('name', 'article[section_ids][]')
    hdn.setAttribute('value', section_id)
    section_li.appendChild(hdn)
  },

  removeSection: function(section_id, section_li) {
    Element.removeClassName(section_li, 'selected')
    
    $A(section_li.getElementsByTagName('input')).each(function(input) {
      section_li.removeChild(input)
    })
  },

  getAvailableComments: function() {
    return $$('#main li').select(function(div) { return div.visible() && div.id.match(/^comment-/); }).collect(function(div) { return div.id.match(/comment-(\d+)/)[1] });
  },
  
  viewComments: function() {
    location.href = "?filter=" + $F(this).toLowerCase();
  },
  
  saveDraft: function() {
    var isDraft = $F(this);
    $$('#article-optional .publish-date select').each(function(sel) { sel.disabled = isDraft; });
  }
}

var SectionForm = {
  toggle_settings: function() {
    Element.toggle('blog-options')
    Element.toggle('paged-options')
  },

  sortable: null,
  toggleSortable: function(link) {
    if($('pages').className == 'sortable') {
      Sortable.destroy('pages');
      $('pages').className = '';
      link.innerHTML = 'Reorder'
      this.saveSortable();
    } else {
      this.sortable = Sortable.create('pages', {handle:'handle'});
      $('pages').className = 'sortable';
      link.innerHTML = 'Stop Reordering'
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

Event.observe(window, 'load', function() {
  new DropMenu('select');
  new TinyTab('filetabs');
  
  var commentsView = $('comments-view');
  var articleDraft = $('article-draft');
  if(commentsView) Event.observe(commentsView, 'change', ArticleForm.viewComments.bind(commentsView));
  if(articleDraft) Event.observe(articleDraft, 'change', ArticleForm.saveDraft.bind(articleDraft));
});