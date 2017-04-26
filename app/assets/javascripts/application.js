// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require foundation
//= require turbolinks
//= require_tree .

$(function(){ $(document).foundation(); });



function init_geoloc(){      
  function maPosition(position) {
    var lat = position.coords.latitude;
    var long = position.coords.longitude;
    //var infopos = "Position déterminée :\n";
    //infopos += "Altitude : "+position.coords.altitude +"\n";
    var path = "panneaus/get_nearest_pannel?lat="+lat+"&long="+long;
    console.log(path);
    var closest_panneau = globalAjaxCall("get",path,"");       
  }

  if(navigator.geolocation){
    navigator.geolocation.getCurrentPosition(maPosition);
  } else {
    console;log("geoloc not ok");
  }

}

function globalAjaxCall(http_method, url, data){
    $.ajax({
        url: url,
        type: http_method,
        data: data
    }).done(function(data) {
      console.log(data);
      //var closest_panneau = JSON.parse(data);
      var closest_panneau = data
      $("#closest_panneau").html("<p>"+closest_panneau.name+" à "+ closest_panneau.distance +"</p>");
      $("#closest_panneau").attr("lat",closest_panneau.lat);
      $("#closest_panneau").attr("long",closest_panneau.long);
      $("#closest_panneau").attr("id_panneaux",closest_panneau.id_panneaux);
    });;
}

function check_this_baby(is_ok){
  //recupere le paneau le plus proche
  var lat = $("#closest_panneau").attr("lat");
  var long = $("#closest_panneau").attr("long"); 
  var id_panneaux = $("#closest_panneau").attr("id_panneaux"); 
  var datas ={"lat":lat,"long":long,"id_panneaux":id_panneaux,"is_ok":is_ok};

  console.log(datas);

  $.ajax({
        url: "panneaus/check_this_baby",
        type: "get",
        data: datas
    })       
}
