(function($){
  var self = this;
  this.socket = null;

  this.on_geo_error = function(eh){
    console.log(eh.message);
  }

  this.on_geo_success = function(position){
    console.log(position);
    var msg = {
      streamId: window.loc_stream_id,
      streamSig: "123123123123",
      coords: position.coords
    };

    var msg_str = JSON.stringify(msg);

    var _tr = "<tr><td>" + msg_str + "</td></tr>";
    $('table#datas tbody').append(_tr);

    self.socket.send(msg_str);
  }

  function begin_trace(){
    if(navigator.geolocation) {
      navigator.geolocation.watchPosition(this.on_geo_success, this.on_geo_error);
    } else {
      console.log("No supporty");
    }
  }

  this.init_socket = function(){
    var hostname = window.location.hostname;
    self.socket = new WebSocket("ws://"+hostname+":8080/send?stream_id="+window.loc_stream_id);
    self.socket.onopen = function(){
      console.log("Socket has been opened!");
      begin_trace();
    }

    self.socket.onmessage = function(msg){
      console.log(msg);
    }
  }

  $(function(){
    self.init_socket();
  });
}(jQuery));
