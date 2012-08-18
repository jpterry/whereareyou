(function($){
  var self = this;
  this.socket = null;

  this.init_socket = function(){
    self.socket = new WebSocket("ws://192.168.0.112:8080/view");
    self.socket.onopen = function(){
      console.log("Socket has been opened!");
    }

    self.socket.onmessage = function(msg){
      console.log(msg);
      var _tr = "<tr><td>" + msg.data + "</td></tr>";
      $('table#datas tbody').append(_tr);
    }
  }

  $(function(){
    self.init_socket();
  });
}(jQuery));
