Object.extend(Object.extend(Dialog.Iframe.prototype, Dialog.Base.prototype), {
  defaultOptions: Object.extend(Object.extend({}, Dialog.Base.prototype.defaultOptions), {
    resultSrc: '',
    onDismiss: function() {}
  }),

  setMessage: function(dialog_box) {
    var iframe      = document.createElement('iframe');
    var dismiss_div = document.createElement('div');
    var dismiss     = document.createElement('a');
    
    iframe.setAttribute('id', 'result_frame');
    iframe.src = this.options.resultSrc;
    dismiss_div.setAttribute('id', 'dismiss_result');
    dialog_box.appendChild(iframe);
    dialog_box.appendChild(dismiss_div);
    dismiss_div.appendChild(dismiss);
    dismiss.innerHTML = 'Dismiss';
    Event.observe(dismiss, 'click', function() { Dialog.current.dismiss(); return false; });
  },

  dismiss: function() {
    Dialog.current.close();
    Dialog.current.options.onDismiss();
  }
});