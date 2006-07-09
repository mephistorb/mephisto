ReferencedPageCaching = {
  setPage: function(num) {
    $('page').value = num;
    $('query-form').onsubmit();
  }
}

Ajax.Responders.register({
  onCreate: function() {
    if($('activity') && Ajax.activeRequestCount > 0) $('activity').visualEffect('appear', {duration:0.25});
  },

  onComplete: function() {
    if($('activity') && Ajax.activeRequestCount == 0) $('activity').visualEffect('fade', {duration:0.25});
  }
});