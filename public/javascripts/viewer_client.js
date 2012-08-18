(function($){
  var self = this;
  this.socket = null;

  this.init_socket = function(){
    self.socket = new WebSocket("ws://192.168.0.112:8080/view?stream_id="+window.loc_stream_id);
    self.socket.onopen = function(){
      console.log("Socket has been opened!");
    }

    self.socket.onmessage = function(msg){
      console.log(msg);
      var _tr = "<tr><td>" + msg.data + "</td></tr>";
      $('table#datas tbody').append(_tr);
    }
  }

  this.init_modal = function(){
    $("#linkModal").reveal();
  }

  $(function(){
    self.init_socket();
    self.init_modal();
  });
}(jQuery));
