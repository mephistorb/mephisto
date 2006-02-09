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
  to_template: function(select) {
    this.to_url(select, "/admin/templates/edit/");
  },

  to_paged_tag: function(select) {
    this.to_url(select, "/admin/pages/edit?id=");
  },

  to_url: function(select, url) {
    var value = select.options[select.selectedIndex].value;
    if(value) location.href = url + value;
  }
};

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

  toggleTag: function(tag_id) {
    var tag_li = $('article_tag_ids_' + tag_id)
    if(Element.hasClassName(tag_li, 'selected'))
      this.removeTag(tag_id, tag_li)
    else
      this.addTag(tag_id, tag_li)
  },

  addTag: function(tag_id, tag_li) {
    Element.addClassName(tag_li, 'selected')
    
    var hdn = document.createElement('input')
    hdn.setAttribute('type', 'hidden')
    hdn.setAttribute('id', 'article_tag_ids_value_' + tag_id)
    hdn.setAttribute('name', 'article[tag_ids][]')
    hdn.setAttribute('value', tag_id)
    tag_li.appendChild(hdn)
  },

  removeTag: function(tag_id, tag_li) {
    Element.removeClassName(tag_li, 'selected')
    
    $A(tag_li.getElementsByTagName('input')).each(function(input) {
      tag_li.removeChild(input)
    })
  }
}

var TagForm = {
  toggle_for_tag: function(tag) {
    new Element.toggle('tag_' + tag + '_name', 'tag_' + tag + '_form');
  }
}

var TemplateForm = {
  loadingDuringSave: function() {
    Form.saving('template');
  },
  
  completedSave: function() {
    Form.saved('template')
    this.hide(function() { new Effect.Highlight('template_saved') })
  },

  show: function() {
    Element.hide('template_saved')
    new Effect.BlindDown('template_form', {duration:0.4})
  },
  
  hide: function(callback) {
    Form.reset("template_form")
    Element.hide('template_form')
    new Effect.BlindDown('template_saved', {duration:0.4, afterFinish: callback})
  }
}

//Ajax.Responders.register({
//  // log the beginning of the requests
//  onCreate: function(request, transport) {
//    new Insertion.Bottom('debug', '<p><strong>[' + new Date().toString() + '] accessing ' + request.url + '</strong></p>')
//  },
//  
//  // log the completion of the requests
//  onComplete: function(request, transport) {
//    new Insertion.Bottom('debug', 
//      '<p><strong>http status: ' + transport.status + '</strong></p>' +
//      '<pre>' + transport.responseText.escapeHTML() + '</pre>')
//  }
//});