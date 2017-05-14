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

var map;
var zoom=16;
var spec_update;
var is_update_running = false;
var markers ;


function init_geoloc(new_spec_update){      
  function maPosition(position) {
    var lat = position.coords.latitude;
    var long = position.coords.longitude;
    if (typeof spec_update != 'undefined'){
      var is_ok = spec_update.is_ok
      var id_panneaux = spec_update.id_panneaux
    }
    spec_update = new_spec_update
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

    if (typeof is_ok != 'undefined'){
      path += "&is_ok="+is_ok;
    }
    if (typeof id_panneaux != 'undefined'){
      path += "&id_panneaux="+id_panneaux;
    }

    globalAjaxCall("get",path,"");       
  }

  if(navigator.geolocation){
    navigator.geolocation.getCurrentPosition(maPosition);
  } else {
    console;log("geoloc not ok");
  }

}


function change_panneaus_info(spec_update) {
  spec_update['id_panneaux'] = $("#closest_panneau").attr("id_panneaux");
  init_geoloc(spec_update);
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
      if (typeof map == 'undefined'){
        console.log("create map");
        create_map(panneaus);
      } else {
        console.log("update map");
        update_map(panneaus);
      }
    });
    return {"ok":"dd"}
}

function create_map(panneaus){
    map = new OpenLayers.Map("mapdiv");
    add_panneaus(panneaus);
}

function update_map(panneaus){
  if (is_update_running == false){
    is_update_running = true;
    markers_last = markers.markers[markers.markers.length-1]
    if (typeof spec_update != 'undefined'){
      if (spec_update.is_ok == true){
        markers_last.setUrl('mavoix-ok.png');  
      } else {
        markers_last.setUrl('mavoix-no.png');  
      }   
    }
    is_update_running = false;
  }
}


function update_map_center(position){
    var lat = position.coords.latitude;
    var long = position.coords.longitude;
    var new_position = new OpenLayers.LonLat( long,lat )
        .transform(
          new OpenLayers.Projection("EPSG:4326"), // transform from WGS 1984
          map.getProjectionObject() // to Spherical Mercator Projection
        );
    map.setCenter (new_position, 16);
  
}

//////// LIBRAIRIE ////////

function get_marker_info(panneau){
    var marker_info = new OpenLayers.LonLat( panneau.lat ,panneau.long )
          .transform(
            new OpenLayers.Projection("EPSG:4326"), // transform from WGS 1984
            map.getProjectionObject() // to Spherical Mercator Projection
          );
    return marker_info;
}

function add_panneaus(panneaus){
  map.addLayer(new OpenLayers.Layer.OSM());
  markers = new OpenLayers.Layer.Markers( "Markers" );
  map.addLayer(markers);  
  for (var i = panneaus.length - 1; i >= 0; i--) {
    var panneau = panneaus[i];
    var marker_info_closest_panneau = get_marker_info(panneau);

    var size = new OpenLayers.Size(21,21);
    var offset = new OpenLayers.Pixel(-(size.w/2), -size.h);

    if (panneau.is_ok == true){
      var icon = new OpenLayers.Icon('/mavoix-ok.png',size,offset);
    }  else {
      var icon = new OpenLayers.Icon('/mavoix-no.png',size,offset);
    }
    markers.addMarker(new OpenLayers.Marker(marker_info_closest_panneau,icon)); 
  }  
  map.setCenter (marker_info_closest_panneau, zoom);
}



