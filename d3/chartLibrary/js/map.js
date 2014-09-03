
var disputed_data;
function getMapData(){	
	
	var map = L.map('map',{zoomControl:false,scrollWheelZoom:false}).setView([20, 20], 1).setZoom(2,0);

	L.tileLayer('http://{s}.tile.cloudmade.com/{key}/22677/256/{z}/{x}/{y}.png', {
		attribution: 'Map data &copy; 2011 OpenStreetMap contributors, Imagery &copy; 2012 CloudMade',
		key: 'BC9A493B41014CAABB98F0471D759707'
	}).addTo(map);
	

	$.ajax({
		type: "GET",
		url: "/PirateToInsight/rest/disputews/disputeData"		
		}).done(function( msg ) {			
			disputed_data=$.parseJSON(msg);
				L.geoJson(disputed_data, {
					style: function (feature) {
						return feature.properties && feature.properties.style;
					},
//					onEachFeature: onEachFeature,
					onEachFeature:eventForMaps,
					pointToLayer: function (feature, latlng) {
						return L.marker(latlng);
					}
				}).addTo(map);
				
//				 setMapView(map);
		    });
}
function redrawMap(data){
	var parent=$("#map").parent();
	$("#map").remove();
	$("<div>", { id: 'map' }).appendTo($(parent));
	var map = L.map('map',{zoomControl:false,scrollWheelZoom:false}).setView([20, 20], 1).setZoom(2,1);

	L.tileLayer('http://{s}.tile.cloudmade.com/{key}/22677/256/{z}/{x}/{y}.png', {
		attribution: 'Map data &copy; 2011 OpenStreetMap contributors, Imagery &copy; 2012 CloudMade',
		key: 'BC9A493B41014CAABB98F0471D759707'
	}).addTo(map);
	

	L.geoJson(data, {
		
		style: function (feature) {
			return feature.properties && feature.properties.style;
		},

		onEachFeature:eventForMaps,
		
		pointToLayer: function (feature, latlng) {
			return L.marker(latlng);
		}
	}).addTo(map);
}
function eventForMaps(feature,layer) {
	var properties=feature.properties;
	var popupContent = "<div>";	
	if (feature.properties && feature.properties.popupContent) {
	popupContent += feature.properties.popupContent;
	}
	popupContent += "</div>";
	layer.bindPopup(popupContent);
	
    layer.on("mouseover", function (e) {
    	layer.openPopup();
    });
    layer.on("mousemove", function(e){	  	
    	layer.openPopup();
    });
    layer.on("mouseout", function (e) {
    	layer.closePopup();
    });    
    layer.on("click", function (e) {
    	createBreadcrumbs(properties.popupContent,feature.id);
//    	$("#disputeDashboardDetails").find("#upperDiv").find("#infoHeaderDiv").find("div.graphHeadings").html(properties.popupContent);
        createDisputeDashboard(feature.id);
    });
}


function onEachFeature(feature, layer) {
	var popupContent = "<p>Dispute:" +
			feature.geometry.type + "</p>";

	if (feature.properties && feature.properties.popupContent) {
		popupContent += feature.properties.popupContent;
	}

	layer.bindPopup(popupContent);	
	
}