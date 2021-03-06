(function($){
  var self = this;
  this.socket = null;

  this.init_socket = function(){
    var hostname = window.location.hostname;
    self.socket = new WebSocket("ws://" + hostname + ":8080/view?stream_id="+window.loc_stream_id);
    self.socket.onopen = function(){
      console.log("Socket has been opened!");
    };

    self.socket.onmessage = function(msg){
      console.log(msg);
      console.log(msg.data);
      msg_obj = JSON.parse(msg.data);
      console.log(msg_obj);
      self.init_map(msg_obj.coords.latitude, msg_obj.coords.longitude);
      $("#linkModal").trigger('reveal:close');
    }
  }

  this.init_map = function(lat, lng){
    var mapOptions = {
      center: new google.maps.LatLng(lat, lng),
      zoom: 17,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    var map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);

    var marker = new google.maps.Marker({
      position: new google.maps.LatLng(lat, lng),
      map: map,
      title:"I'm Here!"
    });
  }

  this.init_modal = function(){
    //When you click the share link, select all of it
    $('#linkModal input').live("click", function(){
      $(this).select();
    });

    $("#linkModal").reveal();
  };

  $(function(){
    self.init_socket();
    self.init_modal();
  });
}(jQuery));
