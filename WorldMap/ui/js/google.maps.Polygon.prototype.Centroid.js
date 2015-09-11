google.maps.Polygon.prototype.Centroid = function() {
var p = this;
var b = this.Bounds();
var c = new google.maps.LatLng((b.getSouthWest().lat()+b.getNorthEast().lat())/2,(b.getSouthWest().lng()+b.getNorthEast().lng())/2);
if (!p.Contains(c)){
    var fc = c; //False Centroid
    var percentages = [0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9]; //We'll check every 10% down each ray and see if we're inside our polygon
    var rays = [
        new google.maps.Polyline({path:[fc,new google.maps.LatLng(b.getNorthEast().lat(),fc.lng())]}),
        new google.maps.Polyline({path:[fc,new google.maps.LatLng(fc.lat(),b.getNorthEast().lng())]}),
        new google.maps.Polyline({path:[fc,new google.maps.LatLng(b.getSouthWest().lat(),fc.lng())]}),
        new google.maps.Polyline({path:[fc,new google.maps.LatLng(fc.lat(),b.getSouthWest().lng())]}),
        new google.maps.Polyline({path:[fc,b.getNorthEast()]}),
        new google.maps.Polyline({path:[fc,new google.maps.LatLng(b.getSouthWest().lat(),b.getNorthEast().lng())]}),
        new google.maps.Polyline({path:[fc,b.getSouthWest()]}),
        new google.maps.Polyline({path:[fc,new google.maps.LatLng(b.getNorthEast().lat(),b.getSouthWest().lng())]})
    ];
    var lp;
    for (var i=0;i<percentages.length;i++){
        var percent = percentages[i];
        for (var j=0;j<rays.length;j++){
            var ray = rays[j];
            var tp = ray.GetPointAtDistance(percent*ray.Distance()); //Test Point i% down the ray
            if (p.Contains(tp)){
                lp = tp; //It worked, store it
                break;
            }
        }
        if (lp){
            c = lp;
            break;
        }
    }
}
return c;}