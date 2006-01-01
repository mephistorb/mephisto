Form.clear_default_text = function(input, remove_class) {
  if(input.value == input.defaultValue) {
    input.value = '';
    if(arguments.length > 1)
      Element.removeClassName(input, remove_class);
  }
}

var Template = {
  navigate_to: function(select) {
    var template = select.options[select.selectedIndex].value;
    if(template) location.href = "/admin/templates/edit/" + template;
  }
};

Ajax.Responders.register({
  // log the beginning of the requests
  onCreate: function(request, transport) {
    new Insertion.Bottom('debug', '<p><strong>[' + new Date().toString() + '] accessing ' + request.url + '</strong></p>')
  },
  
  // log the completion of the requests
  onComplete: function(request, transport) {
    new Insertion.Bottom('debug', 
      '<p><strong>http status: ' + transport.status + '</strong></p>' +
      '<pre>' + transport.responseText.escapeHTML() + '</pre>')
  }
});