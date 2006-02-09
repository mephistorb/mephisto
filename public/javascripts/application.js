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

  to_paged_category: function(select) {
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

  toggleCategory: function(category_id) {
    var category_li = $('article_category_ids_' + category_id)
    if(Element.hasClassName(category_li, 'selected'))
      this.removeCategory(category_id, category_li)
    else
      this.addCategory(category_id, category_li)
  },

  addCategory: function(category_id, category_li) {
    Element.addClassName(category_li, 'selected')
    
    var hdn = document.createElement('input')
    hdn.setAttribute('type', 'hidden')
    hdn.setAttribute('id', 'article_category_ids_value_' + category_id)
    hdn.setAttribute('name', 'article[category_ids][]')
    hdn.setAttribute('value', category_id)
    category_li.appendChild(hdn)
  },

  removeCategory: function(category_id, category_li) {
    Element.removeClassName(category_li, 'selected')
    
    $A(category_li.getElementsByTagName('input')).each(function(input) {
      category_li.removeChild(input)
    })
  }
}

var CategoryForm = {
  toggle_for_category: function(category) {
    new Element.toggle('category_' + category + '_name', 'category_' + category + '_form');
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
    new Effect.SlideDown('template_form', {duration:0.4})
  },
  
  hide: function(callback) {
    Form.reset("template_form")
    new Effect.SlideUp('template_form', {duration:0.4, afterFinish: function() {
      Element.show('template_saved')
      callback()
    }})
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