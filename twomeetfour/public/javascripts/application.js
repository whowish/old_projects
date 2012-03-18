/**
 * @author admin
 */

var mainLibrary = {};
mainLibrary.geocoder = null;

mainLibrary.logFailedAjax = function(path, req, status, e) {
	
	var urlData = "";
	if (req.url != undefined) urlData = 'url='+req.url+', ';
	
	_gaq.push(['_trackEvent', 'Failed', path,  urlData + 'req.status='+req.status+', e='+e+'\nresponseText='+req.responseText]);

}

mainLibrary.getAddress = function(lat, lng, successCallback, failCallback) {

	if (mainLibrary.geocoder == null)
		mainLibrary.geocoder = new google.maps.Geocoder();

	mainLibrary.geocoder.geocode( { 
									'latLng': new google.maps.LatLng(lat, lng)
									},
									function(results, status) {
										
										if (status == google.maps.GeocoderStatus.OK) {
											successCallback(results[0].address_components[0].long_name);
										} else {
											failCallback();
										}
									});
}







