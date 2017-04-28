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

    $.urlParam = function(name){
        var results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
        if (results==null){
           return null;
        }
        else{
           return results[1] || 0;
        }
    }

    var path = "panneaus/get_nearest_pannel?lat="+lat+"&long="+long;
    if (typeof $.urlParam('ville') != 'undefined'){
      path += "&ville="+$.urlParam('ville');
    }
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
    }).done(function(panneaus) {
      //console.log(panneaus);

      var closest_panneau = panneaus[0]
      $("#closest_panneau").html(closest_panneau.name);
      $("#closest_panneau").attr("lat",closest_panneau.lat);
      $("#closest_panneau").attr("long",closest_panneau.long);
      $("#closest_panneau").attr("id_panneaux",closest_panneau.id);
      create_map(panneaus);
    });;
}

function check_this_baby(is_ok){
  //recupere le paneau le plus proche
  var lat = $("#closest_panneau").attr("lat");
  var long = $("#closest_panneau").attr("long"); 
  var id_panneaux = $("#closest_panneau").attr("id_panneaux"); 
  var datas ={"lat":lat,"long":long,"id_panneaux":id_panneaux,"is_ok":is_ok};
  //console.log(datas);
  var path = "/panneaus?lat="+lat+"&long="+long+"&id_panneaux="+id_panneaux+"&is_ok="+is_ok
  window.location.href = path;
      
}


function create_map(panneaus){
    map = new OpenLayers.Map("mapdiv");
    map.addLayer(new OpenLayers.Layer.OSM());

    var zoom=16;
    var markers = new OpenLayers.Layer.Markers( "Markers" );
    map.addLayer(markers);

    var size = new OpenLayers.Size(21,21);
    var offset = new OpenLayers.Pixel(-(size.w/2), -size.h);

    for (var i = panneaus.length - 1; i >= 0; i--) {
      var panneau = panneaus[i];
      var marker_info_closest_panneau = get_marker_info(panneau);
      console.log(panneau);

      if (panneau.is_ok == true){
        var icon = new OpenLayers.Icon('/mavoix-ok.png',size,offset);
      }  else {
        var icon = new OpenLayers.Icon('/mavoix-no.png',size,offset);
      }
      markers.addMarker(new OpenLayers.Marker(marker_info_closest_panneau,icon)); 
    
    }
    
    map.setCenter (marker_info_closest_panneau, zoom);
}

function get_marker_info(panneau){
    var marker_info = new OpenLayers.LonLat( panneau.lat ,panneau.long )
          .transform(
            new OpenLayers.Projection("EPSG:4326"), // transform from WGS 1984
            map.getProjectionObject() // to Spherical Mercator Projection
          );
    return marker_info;
}



