var Asset = {}
Asset.Manager = Class.create();
Asset.Manager.prototype = {
  initialize: function() {
    Position.prepare();
    this.am = $('asset-manager');
    Event.observe(this.am, 'click', this.togglePanel.bind(this));
    //Event.observe(this.am, 'mouseout', this.hidePanel.bind(this));
  },
  
  togglePanel: function() {
    if(Element.hasClassName(this.am, 'open')) {
      Element.removeClassName(this.am, 'open');
      this.showPanel();
    } else {
      Element.addClassName(this.am, 'open');
      this.hidePanel();
    }
  },
  
  showPanel: function() {
    var panelHeight = parseFloat(Element.getStyle(this.am, 'height'));
    if(/Konqueror|Safari|KHTML/.test(navigator.userAgent)) {
      var offset = Position.positionedOffset(this.am)[1];
      var top = (('.' + Element.getStyle(this.am, 'top').replace('%', '')) * offset) + "px";
      Element.setStyle(this.am, {top: top});
    } 
    new Effect.Move(this.am, {y: -(panelHeight) + 150, duration: 0.5});
  },
  
  hidePanel: function() {
    var panelHeight = parseFloat(Element.getStyle(this.am, 'height'));
    new Effect.Move(this.am, {y: panelHeight - 120 });
  }
}
