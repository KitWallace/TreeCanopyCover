//globals centre, root

var map;
var position;
var infowindow = null;
var regions;
var debug = true;
var selected_region ;
var marker ;
var display_mode ;
var canopy_bands = [{upper:14,colour:'orange'},{upper:23,colour:'lightgreen'},{upper:100,colour:'green'}];
var msq_bands = [{upper:30,colour:'orange'},{upper:70,colour:'lightgreen'},{upper:200,colour:'green'}];
var dep_bands = [{upper:20,colour:'orange'},{upper:50,colour:'lightgreen'},{upper:100,colour:'green'}];

function numberFormat(x) {
    if (x==0)
       return ""
    else if (x > 0 && x < 1.0e+3)
      return Number(x);
    else if (x < 1.0e+6)
      return (x / 1.0e+3).toFixed(0)  +"K" 
    else if (x < 1.0e+9)
       return (x /1.0e+6 ).toFixed(0) +"M"   
    else 
       return (x /1.0e+9 ).toFixed(0) +"B"   
}
function precise(x) {
  n= Number(x).toPrecision(2)
  return numberFormat(n);
}

function load_regions(url) {
//     alert("load"+url);
     $.ajax({
          url: url,
          //force to handle it as text
          dataType: "text",
          success: function(data) {
                regions = $.parseJSON(data);
                add_polygons();
                color_polygons("TCC");
                region_show(root);  
//                console.log(regions);

           }  
      });
    
}
function band_colour(v,bands) {
   for (var i in bands) {
     var b=bands[i];  
     if(v < b.upper)
        return b.colour
   }
}

function show_band(bands,text) {
    var html=text;
     for (var i in bands) {
        var b=bands[i]; 
        var lower = i==0?0: bands[i-1].upper;
        var range = i==(bands.length -1) ? "above " + lower : "from " + lower + " to " +b.upper;
        html+="<span>&#160;<span style='background-color:"+b.colour+"'>&#160;&#160;&#160;</span>"+range+"&#160;</span>"
     }
    return html;
}
function initialize() { 
  div = document.getElementById("canvas");
  if (div === null) return null;
  map = new google.maps.Map(div,{
      zoom:  12,
      panControl: false,
      zoomControl: true,
      mapTypeControl: true,
      scaleControl: true,
      streetViewControl: false,
      overviewMapControl: false,
      center: centre,
      mapTypeId: 'satellite'
      });
}  

function add_polygons() {
     for (var i in regions.region){
        var  region =regions.region[i];
         if (region.polygon !== undefined)
            add_polygon(region);
     }
}

function add_polygon(region) {
        var path = region.polygon.point;
        var newpath = [];
        path.forEach(function(p){
              newpath.push( new google.maps.LatLng(parseFloat(p.lat),parseFloat(p.lng)));
            });

        var polygon = 
            new google.maps.Polygon({
                paths: newpath,
                strokeColor: '#FFFFFF',
                strokeOpacity: 0.8,
                strokeWeight: 1,
                fillOpacity:0.6,
                map: map
        });
        google.maps.event.addListener(
             polygon,
            'click',
            function () {
                 region_show(region.code);
            });
        region.polygon = polygon;
}

function color_polygons(mode) {
//    alert(display_mode);
     display_mode=mode;
     if (display_mode == "TCC") {
         $('#TCC').css('background-color','lightsalmon');
         $('#m2p').css('background-color','white');
         $('#dep').css('background-color','white');
         $('#legend').html(show_band(canopy_bands,"% canopy cover "))
     }
     else if (display_mode == "m2p") {
         $('#m2p').css('background-color','lightsalmon');
         $('#TCC').css('background-color','white');
         $('#dep').css('background-color','white');
         $('#legend').html(show_band(msq_bands,"Sq m. canopy per person "))
     }
     else if (display_mode == "dep") {
         $('#dep').css('background-color','lightsalmon');
         $('#TCC').css('background-color','white');
         $('#m2p').css('background-color','white');
         $('#legend').html(show_band(dep_bands,"Social Deprivation Score (2015) "))
    }

     for (var i in regions.region){
        var  region =regions.region[i];
        if (region.polygon !== undefined) {
        if (display_mode=="TCC")
             var colour = band_colour(region.ratio*100,canopy_bands);
        else if (display_mode=="m2p")
             var colour = band_colour(region.canopyperperson,msq_bands);
        else if (display_mode=="dep")
             var colour = band_colour(region.deprivation,dep_bands);

        region.polygon.setOptions({fillColor:colour});
        }
     }
}

function show_polygon(polygon) {
     polygon.setOptions({fillOpacity:0.6});
}
function hide_polygon(polygon) {
     polygon.setOptions({fillOpacity:0});
}

function row(label,value,units,highlight) {
    return "<tr><th>"+label+" </th><td>" + value +" "+units+"</td></tr>";
}
function mrow(label,value,units,price) {
    if (price == "")
       amount="";
    else amount= " @ £" +price;
    return "<tr><th>"+label+" </th><td>" + value + units+amount+"</td></tr>";
}

function find_region(code) {
    for(var i in regions.region) {
      var region = regions.region[i];
      if (region.code==code)
         return region;
    }
}

function region_polygons(region){
    var polygons = [];
    if (region.polygon !== undefined)
        polygons.push(region.polygon);
    else
       for(var i in regions.region) {
         var r = regions.region[i];
         if (r.supersite == region.code && r.polygon !== undefined)
            polygons.push(r.polygon);
       } 
    
    return polygons;
}

function region_show(code) {
 //   alert(code);
    if (code === undefined ) return 0;
    region = find_region(code);
//    alert(region);
    if(selected_region !== undefined) 
       region_polygons(selected_region).forEach(function(p) {show_polygon(p);});
    var polygons =  region_polygons(region);
 //   alert(polygons.length);
    polygons.forEach(function(p) {hide_polygon(p);});
    selected_region=region;
    var html = region_div(region);
   $('#info').html(html);
}

function supersite_link(region) {
    var html = "";
    if (region.supersite !== undefined) {
       var r = find_region(region.supersite);
       var p ='"'+r.code+'"';
       html+= "<div><button onclick='region_show("+p+")'>"+ r.name+"</button></div>";
       html+= supersite_link(r);
   }  
   return html;
    
}
function region_div(region) {
// alert(region);
   var html = "<div><h2>"+region.name+"</h2>";
   lower = (region.ratio*100 - 1.96*region.SEPC).toFixed(1);
   upper = (region.ratio*100  + 1.96*region.SEPC).toFixed(1);
 
   html+="<table>";
   html+= row("ONS code",region.code,"");
   html+= row("Sample Ratio",region.CanopySamples + " / "+ region.SampleSize,"");
   html+= row("Tree canopy",(region.ratio*100).toFixed(1),"%");
   html+= row("Standard error", region.SEPC,"%");
   html+= row("95% Confidence Interval", lower+ "% to " + upper +"%","");
   html+= row("Tree canopy (i-Tree Eco)",(region.itreeRatio*100).toFixed(1),"%");
   html+= row("Total Land area",Number(region.hectares).toLocaleString(),"hectares");
   html+= row("Canopy area",region.canopy,"hectares");
   html+= row("Canopy/person", region.canopyperperson,"m^2 [2017]")
   html+= row("Est. number of trees", (region.canopy * 250).toLocaleString(),"trees")
    if(region.category == "Ward") {
       html+="<tr><th>Public trees</th><td>"+region.treecount+"&#160;<a class='external' target='_blank' href='https://bristoltrees.space/Tree/sitecode/"+region.code+"'>Bristoltrees.space</a></td><tr>";
       html+="<tr><th>Deprivation score</th><td>"+region.deprivation+"</td><tr>";    
    }
  for (var i in region.analysis.benefit) {
      var benefit = region.analysis.benefit[i];
      html+=mrow(benefit.html, precise(benefit.tonnes)," tonnes"+ benefit.period, precise(benefit.total));  
   }
   var parents = supersite_link(region);
   if (parents != "") html+= "<tr><th colspan='2'>Part of" + parents +"</th></tr>";
   var children = subsite_links(region);
   if (children != "") html+= "<tr><th colspan='2'>Includes" + children +"</th></tr>";
   html+="</table>";
  
 
    html+="</div>";
   return html;
} 

function subsite_links(region) {
    var html =""
    for(var i in regions.region) {
      var r = regions.region[i];
      if (r.supersite == region.code) {
           var p ='"'+r.code+'"';
           html+= "<div>" + "<button onclick='region_show("+p+")'>"+ r.name+"</button></div>";
      }
    }
    return html;
}


$(document).ready(function() {   
    initialize ();
    var url = "canopy-data.js";
    load_regions(url);
  });
  
  
