(function($){
  var self = this;
  this.socket = null;

  this.init_socket = function(){
    self.socket = new WebSocket("ws://localhost:8080/view?stream_id="+window.loc_stream_id);
    self.socket.onopen = function(){
      console.log("Socket has been opened!");
    }

    self.socket.onmessage = function(msg){
      console.log(msg);
      console.log(msg.data);
      msg_obj = JSON.parse(msg.data);
      console.log(msg_obj);
      self.init_map(msg_obj.coords.latitude, msg_obj.coords.longitude);

      var _tr = "<tr><td>" + msg_obj.data.coords.latitude + ", " + msg_obj.data.coords.latitude + "</td></tr>";
      $('table#datas tbody').append(_tr);

    }
  }

  this.init_map = function(lat, lng){
      var mapOptions = {
        center: new google.maps.LatLng(lat, lng),
        zoom: 8,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      };
      var map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);
  }

  this.init_modal = function(){
    $("#linkModal").reveal();
  }

  $(function(){
    self.init_socket();
    self.init_modal();
  });
}(jQuery));
