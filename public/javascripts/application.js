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
  toggle_settings: function() {
    Element.toggle('blog-options')
    Element.toggle('paged-options')
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

Event.observe(window, 'load', function() {
  new DropMenu('select');
  new TinyTab('filetabs');
  
  // TODO: IE doesn't fire onchange for checkbox
  var commentsView   = $('comments-view');
  var articleDraft   = $('article-draft');
  if(commentsView)   Event.observe(commentsView,   'change', ArticleForm.viewComments.bind(commentsView));
  if(articleDraft)   Event.observe(articleDraft,   'change', ArticleForm.saveDraft.bind(articleDraft));
});