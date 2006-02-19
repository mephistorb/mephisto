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

  to_paged_section: function(select) {
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
  }
}

var SectionForm = {
  toggle_settings: function() {
    Element.toggle('blog-options')
    Element.toggle('paged-options')
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