// requires scriptaculous builder class
function $B(elementName) {
  return Builder.node(elementName, arguments[1] || {}, arguments[2] || '');
}

Dialog.Confirm = Class.create();
Object.extend(Object.extend(Dialog.Confirm.prototype, Dialog.Base.prototype), {
  defaultOptions: Object.extend(Object.extend({}, Dialog.Base.prototype.defaultOptions), {
    okayText:        "OK",
    cancelText:      "CANCEL",
    okayImage:       '',
    cancelImage:     '',
    onOkay:   function() { alert('okay!')   },
    onCancel: function() { alert('cancel!') }
  }),

  setContents: function() {
    var okayButton   = $B('a', {className: 'okay', href: '#'},
      (this.options.okayImage == '' ?
        this.options.okayText :
        $B('img', {src: this.options.okayImage, alt: this.options.okayText}))
    );
    var cancelButton = $B('a', {className: 'cancel', href: '#'},
      (this.options.cancelImage == '' ?
        this.options.cancelText :
        $B('img', {src: this.options.cancelImage, alt: this.options.cancelText}))
    );
  
    Event.observe(okayButton,   'click', function() { Dialog.current.close(); Dialog.current.options.onOkay();   return false; });
    Event.observe(cancelButton, 'click', function() { Dialog.current.close(); Dialog.current.options.onCancel(); return false; });

    this.dialogBox.appendChild($B('p', {className: 'buttons'}, [okayButton, cancelButton]));
  }
});