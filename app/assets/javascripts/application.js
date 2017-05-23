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

// switch to gmap
//https://developers.google.com/maps/documentation/javascript/markers?hl=fr

$(function(){ $(document).foundation(); });

var map;
var zoom=16;
var spec_update;
var is_update_running = false;
var markers;


function init_geoloc(new_spec_update){      
  function maPosition(position) {
    var lat = position.coords.latitude;
    var long = position.coords.longitude;
    spec_update = new_spec_update;
    if (typeof spec_update != 'undefined'){
      var is_ok = spec_update.is_ok
      var id_panneaux = spec_update.id_panneaux
    } 

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

  //var iOS = !!navigator.platform && /iPad|iPhone|iPod/.test(navigator.platform);
  //if (iOS){
  //  var current_url = window.location.href.replace("panneaus","panneaus_gm")
  //  window.location.replace(current_url);
  //}

  if(navigator.geolocation){
    navigator.geolocation.getCurrentPosition(maPosition);
  } else {
    $("H1").html("! Activer la Geoloc !");
    loadGiff(false);
  }

}


function change_panneaus_info(spec_update) {
  loadGiff(true);
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
      loadGiff(false);
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
        $("#"+spec_update.id_panneaux).html("Bon état");
      } else {
        markers_last.setUrl('mavoix-no.png');  
        $("#"+spec_update.id_panneaux).html("A recoller");
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

function loadGiff(hideit){

    $body = $("body");
    if (hideit == true){
        $body.addClass("loading");
    } else {
        $body.removeClass("loading");
    }
}

function add_circo(){
  new OpenLayers.Layer.Vector({
      title: 'added Layer',
      source: new OpenLayers.source.GeoJSON({
         projection : 'EPSG:4326',
         url: '/circonscriptions-legislatives.geojson'
      })
  })
}

////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
////////////////////// GOOGLE MAP //////////////////////
////////////////////////////////////////////////////////
////////////////////////////////////////////////////////

function initGoogleMap(new_spec_update) {

  function geoPosition(position){

    var lat = position.coords.latitude;
    var long = position.coords.longitude;

    spec_update = new_spec_update;
    if (typeof spec_update != 'undefined'){
      var is_ok = spec_update.is_ok;
      var id_panneaux = spec_update.id_panneaux;
    }

    // get parameter from url
    $.urlParam = function(name){
        var results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
        if (results==null){
           return null;
        }
        else{
           return results[1] || 0;
        }
    }
    // prepare url for nearest pannel
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

    // get date from engine
    $.ajax({
        url: path,
        type: "get",
        data: ""
    }).done(function(panneaus) {
      //console.log(panneaus);

      var closest_panneau = panneaus[0]
      $("#closest_panneau").html(closest_panneau.name);
      $("#closest_panneau").attr("lat",closest_panneau.lat);
      $("#closest_panneau").attr("long",closest_panneau.long);
      $("#closest_panneau").attr("id_panneaux",closest_panneau.id);
      if (typeof map == 'undefined'){
        console.log("create map");
        create_google_map(panneaus);
      } else {
        console.log("update map");
        update_google_map(panneaus);
      }

      var myposition = new google.maps.Marker({
        position: {lat: lat, lng: long},
        map: map,
      }); 

      loadGiff(false);
    });
  }

  // check if geoloc is here
  if(navigator.geolocation){
    navigator.geolocation.getCurrentPosition(geoPosition);
  } else {
    $("H1").html("! Activer la Geoloc !");
    $("#cmd").hide();
    var geoPosition= {"coords":{"latitude":45.9605536,"longitude":5.5013198999999995}};
    geoPosition(geoPosition);
  }
}

function create_google_map(panneaus){
  map = new google.maps.Map(document.getElementById('mapdiv'), {
    zoom: zoom
  });

  add_google_map_panneaus(panneaus);

}    


function update_google_map(panneaus){
  if (is_update_running == false){
    is_update_running = true;
    var markers_last = gm_marker[gm_marker.length-1];
    if (typeof spec_update != 'undefined'){
      if (spec_update.is_ok == true){
        markers_last.setIcon('/mavoix-ok.png');  
        $("#"+spec_update.id_panneaux).html("Bon état");
      } else {
        markers_last.setIcon('/mavoix-no.png');  
        $("#"+spec_update.id_panneaux).html("A recoller");
      }   
    }
    is_update_running = false;
  }
}


function add_google_map_panneaus(panneaus){


  for (var i = panneaus.length - 1; i >= 0; i--) {
    var panneau = panneaus[i];
    if (panneau.is_ok == true){
      var icon = '/mavoix-ok.png';
    }  else {
      var icon = '/mavoix-no.png';
    }

    data = "<a href='/panneaus/"+panneau.id+"/edit_state'>"+panneau.name+"</a>";

    var marker = new google.maps.Marker({
      position: {lat: panneau.long, lng: panneau.lat},
      map: map,
      icon: icon,
      data: data
    }); 

    // add info    
    marker.addListener('click', function() {
      var infowindow = new google.maps.InfoWindow({
        content: this.data,
        maxWidth: 200
      });    
      infowindow.open(map, this);
    });


    // record marker

    gm_marker.push(marker) ; 
  }  
  var closest_panneau = panneaus[0];
  map.setCenter({lat: closest_panneau.long, lng: closest_panneau.lat}); 
  //map.setCenter (marker_info_closest_panneau, zoom);

}

function change_panneaus_info_google_map(spec_update) {
  loadGiff(true);
  spec_update['id_panneaux'] = $("#closest_panneau").attr("id_panneaux");
  initGoogleMap(spec_update);
}

function show_circo(){
  // add circo
  map.data.loadGeoJson('circo.geojson');
  map.data.setStyle(function(feature) {
      var color = 'yellow';
      return /** @type {google.maps.Data.StyleOptions} */({
        fillOpacity:0,
        strokeColor: color,
        strokeWeight: 4
      });
  });
  $("#show_circo").hide();
}
