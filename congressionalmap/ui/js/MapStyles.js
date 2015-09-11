		var stylesHome = [ 
			{ "featureType": "landscape","stylers": [{ "color": "#e5e5e1" }]},
			{ "featureType": "poi", "stylers": [ { "visibility": "off" } ] },
			{ "featureType": "transit", "stylers": [ { "visibility": "simplified" } ] },
			{ "featureType": "administrative.country", "elementType": "labels.text", "stylers": [ { "visibility": "off" } ] },
			{ "featureType": "administrative.country", "elementType": "geometry.stroke", "stylers": [ { "weight": 2 }, { "color": "#90b4c9" } ] },
			{ "featureType": "administrative.neighborhood", "stylers": [ { "visibility": "off" } ] },
			{ "featureType": "water", "elementType": "geometry", "stylers": [ { "visibility": "simplified" }, { "color": "#b4cbd9" } ] },
			{ "featureType": "administrative.province", "elementType": "geometry.stroke", "stylers": [ { "color": "#90b4c9" } ] },
			{ "featureType": "administrative", "elementType": "labels.text.fill", "stylers": [ { "color": "#082c62" }, { "weight": 8 } ] },
			{ "featureType": "road.highway", "elementType": "geometry", "stylers": [ { "visibility": "simplified" } ] },
			{ "featureType": "road.arterial", "stylers": [ { "visibility": "off" } ] },
			{ "featureType": "road.local", "stylers": [ { "visibility": "off" } ] },{ "featureType": "administrative.locality" },
			{ "featureType": "road.highway", "elementType": "labels.icon", "stylers": [ { "visibility": "off" } ] },
			{ "featureType": "administrative", "elementType": "geometry.fill", "stylers": [ { "color": "#e6e4df" } ] },
			{ "featureType": "water","stylers": [{ "color": "#E9EFF3" },{ "visibility": "on" }]}
			];
			
		var stylesInner = [ 
			{ "featureType": "landscape","stylers": [{ "color": "#e5e5e1" }]},
			{ "featureType": "poi", "stylers": [ { "visibility": "off" } ] },
			{ "featureType": "transit", "stylers": [ { "visibility": "simplified" } ] },
			{ "featureType": "administrative.country", "elementType": "labels.text", "stylers": [ { "visibility": "off" } ] },
			{ "featureType": "administrative.country", "elementType": "geometry.stroke", "stylers": [ { "weight": 2 }, { "color": "#90b4c9" } ] },
			{ "featureType": "administrative.neighborhood", "stylers": [ { "visibility": "off" } ] },
			{ "featureType": "water", "elementType": "geometry", "stylers": [ { "visibility": "simplified" }, { "color": "#b4ccda" } ] },
			{ "featureType": "administrative.province", "elementType": "geometry.stroke", "stylers": [ { "color": "#90b4c9" } ] },
			{ "featureType": "administrative", "elementType": "labels.text.fill", "stylers": [ { "color": "#082c62" }, { "weight": 8 } ] },
			{ "featureType": "road.highway", "elementType": "geometry", "stylers": [ { "visibility": "simplified" } ] },
			{ "featureType": "road.arterial", "stylers": [ { "visibility": "off" } ] },
			{ "featureType": "road.local", "stylers": [ { "visibility": "off" } ] },{ "featureType": "administrative.locality" },
			{ "featureType": "road.highway", "elementType": "labels.icon", "stylers": [ { "visibility": "simplified" }, { "lightness": 50 } ] },
			{ "featureType": "administrative", "elementType": "geometry.fill", "stylers": [ { "color": "#e6e4df" } ] }
			];	
			
		var mStyleBasic = [
			{ polygonOptions: { fillColor: '#537090', fillOpacity: .10 } }
			];
			
		var mStyleThemed = [
			{ polygonOptions: { fillColor: '#537090', fillOpacity: .50 } },
			{ where: 'AMT_SUPPORTED < 75000000', polygonOptions: { fillColor: '#6896b0' } }, 
			{ where: 'AMT_SUPPORTED < 50000000', polygonOptions: { fillColor: '#a8becb' } }, 
			{ where: 'AMT_SUPPORTED < 25000000', polygonOptions: { fillColor: '#e8e6e7' } }, 
			{ where: 'AMT_SUPPORTED < 10', polygonOptions: { fillOpacity: 0 } }
			];
			
		var mStyleHomepage = [
			{ polygonOptions: { fillColor: '#537090', fillOpacity: .50 } },
			{ where: 'SalesSupported < 75000000', polygonOptions: { fillColor: '#6896b0' } }, 
			{ where: 'SalesSupported < 50000000', polygonOptions: { fillColor: '#a8becb' } }, 
			{ where: 'SalesSupported < 25000000', polygonOptions: { fillColor: '#e8e6e7' } }, 
			{ where: 'SalesSupported < 10', polygonOptions: { fillOpacity: 0 } }
			];