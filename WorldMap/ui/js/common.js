function constructNewCoordinates(polygon){
	var newCoordinates = [];
	var coordinates = polygon['coordinates'][0];
	for (var i in coordinates) {				
		lon = coordinates[i][0];
		lat = coordinates[i][1];				
		newCoordinates.push(new google.maps.LatLng(coordinates[i][1], coordinates[i][0]));			
	}
	return newCoordinates;
}	