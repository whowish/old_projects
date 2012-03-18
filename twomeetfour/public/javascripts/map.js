// Preload images
var ALL_PIN_IMAGE = "/images/pin/allPin.png";

/*
 * Shadows
 */
var shadows = {	"HOUSE": new google.maps.MarkerImage(ALL_PIN_IMAGE,
													new google.maps.Size(38, 20),
													new google.maps.Point(160, 0 + (32 - 20)),
													new google.maps.Point(12, 20)),
				"SINGLE_ROOM": new google.maps.MarkerImage(ALL_PIN_IMAGE,
															new google.maps.Size(28, 22),
															new google.maps.Point(160, 32 + (32 - 22)),
															new google.maps.Point(8, 22)),
				"COMPLEX_ROOM": new google.maps.MarkerImage(ALL_PIN_IMAGE,
															new google.maps.Size(28, 22),
															new google.maps.Point(160,32 + (32 - 22)),
															new google.maps.Point(8, 22))
				};


var internetShadows = { 	"HOUSE": new google.maps.MarkerImage(ALL_PIN_IMAGE,
															new google.maps.Size(50, 24),
															new google.maps.Point(192, 32 + (32 - 24)),
															new google.maps.Point(12, 24)),
						"SINGLE_ROOM": new google.maps.MarkerImage(ALL_PIN_IMAGE,
																	new google.maps.Size(40, 20),
																	new google.maps.Point(192, 64 + (32 - 20)),
																	new google.maps.Point(8, 20)),
						"COMPLEX_ROOM": new google.maps.MarkerImage(ALL_PIN_IMAGE,
															new google.maps.Size(40, 20),
															new google.maps.Point(192, 64 + (32 - 20)),
															new google.maps.Point(8, 20))
						};
															

var iconMap = {	"HOUSE": { "": [0,0],
							"furniture": [32,0],
							"internet": [64,0],
							"furniture_internet": [96,0]
						},
				"SINGLE_ROOM": { 	"": [0,32],
									"furniture": [32,32],
									"internet": [64,32],
									"furniture_internet": [96,32]
								},
				"COMPLEX_ROOM": { 	"": [0,64],
									"furniture": [32,64],
									"internet": [64,64],
									"furniture_internet": [96,64]
								}
				};
				
var icons = [];

var paddingLevels = [[128,96],[0,96],[0,0]];

for (var i=0;i<paddingLevels.length;i++) {
	
	var pads = paddingLevels[i];
	
	var iconLevel = {};
	for(var type in iconMap) {
		
		iconLevel[type] = {};
		for (var feature in iconMap[type]) {
			var point = iconMap[type][feature];
			var shadow = (feature==""||feature=="furniture")?shadows[type]:internetShadows[type];
			
			iconLevel[type][feature] = {icon: new google.maps.MarkerImage(ALL_PIN_IMAGE,
																			new google.maps.Size(32,32),
																			new google.maps.Point(point[0]+pads[0],point[1]+pads[1])),
										shadow: shadow
										};
		
		}
	}
	
	icons.push(iconLevel);
}


var mapHandler = {};
mapHandler.geocoder = null;
mapHandler.currentMode = "normal";
mapHandler.map = null;
mapHandler.currentLocation = null;
mapHandler.currentBound = new google.maps.LatLngBounds(new google.maps.LatLng(0,0),
															new google.maps.LatLng(0,0)
															);;
mapHandler.add_marker = null;
		
mapHandler.markerLimit = ($.browser.mobile)? 40:100;	
mapHandler.markers = [];	
mapHandler.inverseIndicesOfMarkers = {};

mapHandler.queryLocationTimerObj = null;

mapHandler.currentAjaxRequest = null;

mapHandler.abortAjaxRequest = function() {
	$("#filter_button").removeClass("loading");
	if (mapHandler.currentAjaxRequest != null) {
		try {
			mapHandler.currentAjaxRequest.abort();
		} catch (e) {}
	}
}


mapHandler.clearQueryTimer = function() {
	
	if (mapHandler.queryLocationTimerObj != null)
		clearTimeout(mapHandler.queryLocationTimerObj);
}


mapHandler.setQueryTimer = function(timeout) {
	
	if (timeout == undefined) timeout = 5 * 60000;
	
	mapHandler.clearQueryTimer();
	mapHandler.queryLocationTimerObj = setTimeout("mapHandler.queryLocation(true);", timeout);
}


mapHandler.hideMarkers = function() {
	for (var i = 0; i < mapHandler.markers.length; i++) {
		mapHandler.markers[i].setVisible(false);
	}
}


mapHandler.showMarkers = function() {
	for (var i = 0; i < mapHandler.markers.length; i++) {
		if (mapHandler.markers[i].data != null) {
			mapHandler.markers[i].setVisible(true);
		}
	}
}


mapHandler.updateMarkerAppearance = function(marker, data, forceDrop) {

	var previousIcon = marker.getIcon();
					
	var features = [];
	if (data.has_furniture == true) {
		features.push("furniture");
	} 

	if (data.has_internet == true) {
		features.push("internet");
	}
	
	features = features.join("_");
	
	marker.setIcon(icons[data.level][data.type][features].icon);
	marker.setShadow(icons[data.level][data.type][features].shadow);
	
	if (forceDrop == true || previousIcon != marker.getIcon()) {
		marker.setAnimation(google.maps.Animation.DROP);
	}
	
}

mapHandler.currentQueryFilter = {};
mapHandler.queryLocation = function(force) {
	
	if (mapHandler.currentMode != "normal") return;
	
	//var original_bound = mapHandler.padding(mapHandler.map.getBounds(), 0.05);
	var originalBound = mapHandler.map.getBounds();
	
	var bound  = new google.maps.LatLngBounds(new google.maps.LatLng(mapHandler.sanitizePosition(originalBound.getSouthWest().lat()), 
																	 mapHandler.sanitizePosition(originalBound.getSouthWest().lng())
																	),
												new google.maps.LatLng(mapHandler.sanitizePosition(originalBound.getNorthEast().lat()), 
																		mapHandler.sanitizePosition(originalBound.getNorthEast().lng())
																		)
											);
											
	var filter = mapHandler.getFilterData();

	if (mapHandler.isQueryConditionEqual({	bound: bound, 
											filter: filter
										},
										{	bound: mapHandler.currentBound,
											filter: mapHandler.currentQueryFilter
										}) 
		&& force != true) {
		return; // We do not query as the position is not changed
	}

	mapHandler.clearQueryTimer();
	
	var northEast = bound.getNorthEast();
	var southWest = bound.getSouthWest();
	
	mapHandler.currentBound = new google.maps.LatLngBounds(new google.maps.LatLng(mapHandler.sanitizePosition(southWest.lat()), 
																					mapHandler.sanitizePosition(southWest.lng())
																					),
																new google.maps.LatLng(mapHandler.sanitizePosition(northEast.lat()), 
																						mapHandler.sanitizePosition(northEast.lng())
																						)
															);
															
	mapHandler.currentQueryFilter = filter;

	var gaqData = 'furniture,internet,type,price';
	_gaq.push(['_trackEvent', 'Map', "Query", gaqData]);
	
	mapHandler.abortAjaxRequest();
	$("#filter_button").addClass("loading");
	mapHandler.currentAjaxRequest = $.ajax({
			type: "GET",
			url: '/post',
			cache: false,
			data: {
				ne_lat: mapHandler.sanitizePosition(northEast.lat()),
				ne_lng: mapHandler.sanitizePosition(northEast.lng()),
				sw_lat: mapHandler.sanitizePosition(southWest.lat()),
				sw_lng: mapHandler.sanitizePosition(southWest.lng()),
				limit: mapHandler.markerLimit,
				type: filter.type,
				has_furniture: filter.hasFurniture,
				has_internet: filter.hasInternet,
				min_price: filter.minPrice,
				max_price: filter.maxPrice
			},
			success: function(data){
				
				if (mapHandler.currentMode != "normal") return;
				
				if (data.ok != true) return;
				
				if (!mapHandler.isQueryConditionEqual({	bound: bound, 
														filter: filter
													},
													{	bound: mapHandler.currentBound,
														filter: mapHandler.currentQueryFilter
													})) return; 
				
				var newMarkers = [];
				var emptyMarkers = [];
				var newInverseIndices = {};
				
				// Move what is shown and still shown in the next batch
				for (var i = 0; i < data.results.length; i++) {
					var marker = mapHandler.inverseIndicesOfMarkers[data.results[i].id];
					
					if (marker != null) {
						newMarkers.push(marker);
						newInverseIndices[data.results[i].id] = marker;
						
						mapHandler.updateMarkerAppearance(marker, data.results[i]);
					}
				}
				
				// delete old batch
				for (var i=0;i<mapHandler.markerLimit;i++) {
					
					if (mapHandler.markers[i].data == null) {
						emptyMarkers.push(mapHandler.markers[i]);
						continue;
					}
					
					var id = mapHandler.markers[i].data.id;
					
					if (newInverseIndices[id] == null) {
						mapHandler.markers[i].setVisible(false);
						
						if (mapHandler.markers[i].clickEvent != null) {
							google.maps.event.removeListener(mapHandler.markers[i].clickEvent);
						}
						
						mapHandler.markers[i].clickEvent = null;
						mapHandler.markers[i].data = null;
						
						emptyMarkers.push(mapHandler.markers[i]);
					}
				}
				
				
				for (var i = 0; i < data.results.length; i++) {
					
					if (newInverseIndices[data.results[i].id] != null) continue;
					
					var marker = emptyMarkers.pop();
					
					marker.setPosition(new google.maps.LatLng(data.results[i].location[0], data.results[i].location[1]));
					mapHandler.updateMarkerAppearance(marker, data.results[i], true);
					
					if (marker.clickEvent != null) {
						google.maps.event.removeListener(marker.clickEvent);
					}
					
					marker.setVisible(true);

					marker.data = data.results[i];
					marker.click_event = google.maps.event.addListener(marker, 'click', function() {
							
																					var self = this;
																					self.setAnimation(google.maps.Animation.BOUNCE);
																							
																					setTimeout(function() {
																						self.setAnimation(null);
																					},1500);
																					
																					mapHandler.view(self.data);
																					//mapHandler.map.panTo(self.getPosition());
																					
																				});
																				
					newInverseIndices[data.results[i].id] = marker;
					
				}
				
				mapHandler.inverseIndicesOfMarkers = newInverseIndices;
				
				if (mapHandler.currentMode != "normal") mapHandler.hideMarkers();

				mapHandler.setQueryTimer();
				
				$("#filter_button").removeClass("loading");
			},
			error: function(req, status, e){
				if (req.status == 0) return;
				_gaq.push(['_trackEvent', 'Map', 'QueryFailed', '']);
				mapHandler.setQueryTimer(60000);
				$("#filter_button").removeClass("loading");
			}
		});
}


mapHandler.isQueryConditionEqual = function(before, current) {
	
	if (current.bound == null) return false;
	
	return (mapHandler.considerEqual(before.bound.getNorthEast().lat(), current.bound.getNorthEast().lat())
			&& mapHandler.considerEqual(before.bound.getNorthEast().lng(), current.bound.getNorthEast().lng())
			&& mapHandler.considerEqual(before.bound.getSouthWest().lat(), current.bound.getSouthWest().lat())
			&& mapHandler.considerEqual(before.bound.getSouthWest().lng(), current.bound.getSouthWest().lng())
			&& (before.filter.type == current.filter.type)
			&& (before.filter.hasFurniture == current.filter.hasFurniture)
			&& (before.filter.hasInternet == current.filter.hasInternet)
			&& (before.filter.minPrice == current.filter.minPrice)
			&& (before.filter.maxPrice == current.filter.maxPrice));
}

// mapHandler.padding = function(bound, portion) {
// 	
	// return bound;
// 	
	// var northEast = bound.getNorthEast();
	// var southWest = bound.getSouthWest();
// 	
	// var paddingWidth = Math.abs(northEast.lat() - southWest.lat()) * portion;
	// var paddingHeight = Math.abs(northEast.lng() - southWest.lng()) * portion;
// 
	// var ret = new google.maps.LatLngBounds(new google.maps.LatLng(mapHandler.sanitizePosition(southWest.lat() + paddingWidth),
																 // mapHandler.sanitizePosition(southWest.lng() - paddingHeight)),
										// new google.maps.LatLng(mapHandler.sanitizePosition(northEast.lat() - paddingWidth), 
																// mapHandler.sanitizePosition(northEast.lng() + paddingHeight)));
// 
	// return ret;
// }


mapHandler.sanitizePosition = function(unit) {
	var PRECISION = 10000;
    var ret = Math.round(unit * PRECISION)/PRECISION;
	return ret;
}



mapHandler.considerEqual = function(a, b) {
	var diff = a - b;
	return (-0.001 < diff && diff < 0.001);
}


mapHandler.setUserGeolocation = function(map) {
	
	var zoom = ($.browser.mobile)?14:12;
	if(navigator.geolocation) {

		navigator.geolocation.getCurrentPosition(function(position) {
			var loc = new google.maps.LatLng(position.coords.latitude,position.coords.longitude);
			map.setCenter(loc);
			map.setZoom(zoom);
		}, function() {});

	} else if (google.gears) {
		
		var geo = google.gears.factory.create('beta.geolocation');
		geo.getCurrentPosition(function(position) {
		  var loc = new google.maps.LatLng(position.latitude,position.longitude);
		  map.setCenter(loc);
		  map.setZoom(zoom);
		}, function() {});
		
	}

}
		
mapHandler.initialize = function(zoom, lat, lng) {
			
	mapHandler.geocoder = new google.maps.Geocoder();

	var latlng = new google.maps.LatLng(13.723377, 100.476151);
	var myOptions = {
	  zoom: zoom,
	  center: latlng,
	  mapTypeId: google.maps.MapTypeId.ROADMAP,
	  streetViewControl: true,
	  scaleControl: false
	};
	
	mapHandler.map = new google.maps.Map(document.getElementById("map"), myOptions);
	
	if (lat == undefined || lng == undefined) {
		//mapHandler.setUserGeolocation(mapHandler.map);
	} else {
		mapHandler.map.setCenter(new google.maps.LatLng(lat, lng));
	}

	mapHandler.currentLocation = mapHandler.map.getCenter();
	mapHandler.initializeIcons();
	

	google.maps.event.addListenerOnce(mapHandler.map, 'idle', function(){
		mapHandler.queryLocation(true);
	});
	
	google.maps.event.addListener(mapHandler.map, 'click', function(event) {
		mapHandler.map.panTo(event.latLng);
	});

		
	google.maps.event.addListener(mapHandler.map, 'bounds_changed', function(){
		
		var point = mapHandler.map.getCenter();
		mapHandler.currentLocation = new google.maps.LatLng(point.lat(), point.lng());
		
		var localLocation = new google.maps.LatLng(mapHandler.currentLocation.lat(), mapHandler.currentLocation.lng());
		
		setTimeout(function() {
			
			if (!mapHandler.considerEqual(localLocation.lat(), mapHandler.currentLocation.lat())) return;
			if (!mapHandler.considerEqual(localLocation.lng(), mapHandler.currentLocation.lng())) return;
			
			mapHandler.queryLocation();
		}, 2000);
		
	});

}
	
	
mapHandler.initializeIcons = function() {

	if (mapHandler.markers.length < mapHandler.markerLimit) {
		for(var i=mapHandler.markers.length;i<mapHandler.markerLimit;i++) {

			var marker = new google.maps.Marker({
												map: mapHandler.map,
												visible: false,
												icon: null,
												shadow: null
												});
			marker.data = null;
			marker.clickEvent = null;
			mapHandler.markers.push(marker);

		}
	}
	
	// add icon
	var shadow = new google.maps.MarkerImage(ALL_PIN_IMAGE,
											new google.maps.Size(32, 18),
								      		new google.maps.Point(224,14),
								      		new google.maps.Point(6, 18));
													
	var icon = new google.maps.MarkerImage(ALL_PIN_IMAGE,
											new google.maps.Size(32, 32),
								      		new google.maps.Point(128,0));
								      		
	mapHandler.addMarker = new google.maps.Marker({
														map: mapHandler.map,
														icon: icon,
														shadow: shadow,
														shape: {coords:[0,0,0,0],type:'rect'},
														clickable: false,
														zIndex: 2
													});
	mapHandler.addMarker.bindTo('position', mapHandler.map, 'center'); 
	mapHandler.addMarker.setVisible(false);
}
	

mapHandler.searchFor = function(keyword) {
	
	$("#search_address").addClass('searching');
	$('#search_address').blur();
	
	var bangkokBounds = new google.maps.LatLngBounds(new google.maps.LatLng(13.791660210971326, 99.57502905273441),
														new google.maps.LatLng(14.24467250352153, 101.45094458007816)
														);

	_gaq.push(['_trackEvent', 'Map', 'Search', 'Try']);
	mapHandler.geocoder.geocode( { 
									'address': keyword + " ไทย",
									'region':'TH',
									'bounds': bangkokBounds
									},
									function(results, status) {
										$("#search_address").removeClass('searching');
										if (status != google.maps.GeocoderStatus.OK) return;
										
										_gaq.push(['_trackEvent', 'Map', 'Search', 'Succeeded']);
										
										mapHandler.map.panTo(results[0].geometry.location);
										mapHandler.map.setZoom(16);
									});

}


mapHandler.view = function(post) {
	
	mapHandler.currentMode = "view";
	
	var url = "/post/!/" + post.id

	$("#dialog").dialog({ title: "รายละเอียด" });
	$('#dialog_content').html("<span class='dialogLoading'></span>");
	$('#dialog').dialog('open');
	
	$( "#dialog" ).unbind( "dialogclose");
	$( "#dialog" ).bind( "dialogclose", function(event, ui) {
		mapHandler.toNormalMode();
		$( "#dialog" ).unbind("dialogclose");
	});


	mapHandler.abortAjaxRequest();
	mapHandler.currentAjaxRequest = $.ajax({
											type: "GET",
											url: url,
											success: function(html){
												
												if (mapHandler.currentMode != "view") return;
												$('#dialog_content').html(html);
												
											},
											error: function(req, status, e){
												if (req.status == 0) return;
												req.url = url;
												mainLibrary.logFailedAjax('/post/view', req, status, e);
												
												$('#dialog_content').html("<span class='loadError'></span>");
											}
										});
	
}


mapHandler.openEditPage = function(postId) {

	mapHandler.currentMode = "edit";

	var url = "/post/edit_form/" + postId;
	
	$("#dialog").dialog({ title: "แก้ไข" });
	$('#dialog_content').html("<span class='dialogLoading'></span>");
	$('#dialog').dialog('open');
	
	$( "#dialog" ).unbind( "dialogclose");
	$( "#dialog" ).bind( "dialogclose", function(event, ui) {
		mapHandler.toNormalMode(true);
		$( "#dialog" ).unbind("dialogclose");
	});
	
	
	mapHandler.abortAjaxRequest();
	mapHandler.currentAjaxRequest = $.ajax({
											type: "GET",
											url: url,
											cache: false,
											success: function(html){
												
												if (mapHandler.currentMode != "edit") return;
												$('#dialog_content').html(html);
												
											},
											error: function(req, status, e){
												if (req.status == 0) return;
												req.url = url;
												mainLibrary.logFailedAjax('/post/edit_form', req, status, e);
												
												$('#dialog_content').html("<span class='loadError'></span>");
											}
										});

}

mapHandler.toAddMode = function() {
	
	mapHandler.currentMode = "begin_add";
	
	mapHandler.addMarker.setVisible(true);
	mapHandler.addMarker.setAnimation(google.maps.Animation.DROP);
	
	$('#add_menu').show();
	$('#main_menu').hide();
	$('#search_menu').hide();
	
	mapHandler.hideMarkers();
	
}

mapHandler.openAddPage = function(lat, lng) {

	mapHandler.currentMode = "add";

	if (lat == undefined || lng == undefined) {
		var point = mapHandler.map.getCenter();
		lat = point.lat();
		lng = point.lng();
	}
	
	var url = "/post/create_form/" + mapHandler.sanitizePosition(lat) + "/" + mapHandler.sanitizePosition(lng);
	
	$("#dialog").dialog({ title: "ลงประกาศ" });
	$('#dialog_content').html("<span class='dialogLoading'></span>");
	$('#dialog').dialog('open');
	
	$( "#dialog" ).unbind( "dialogclose");
	$( "#dialog" ).bind( "dialogclose", function(event, ui) {
		mapHandler.toNormalMode(true);
		$( "#dialog" ).unbind("dialogclose");
	});
	
	mapHandler.abortAjaxRequest();
	mapHandler.currentAjaxRequest = $.ajax({
											type: "GET",
											url: url,
											success: function(html){
												
												if (mapHandler.currentMode != "add") return;
												$('#dialog_content').html(html);
											},
											error: function(req, status, e){
												if (req.status == 0) return;
												req.url = url;
												mainLibrary.logFailedAjax('/post/create_form', req, status, e);
												
												$('#dialog_content').html("<span class='loadError'></span>");
											}
										});

}

mapHandler.openInfoPage = function() {

	mapHandler.currentMode = "help";
	var url = "/help";

	$("#dialog").dialog({ title: "ข้อมูลทั่วไป" });
	$('#dialog_content').html("<span class='dialogLoading'></span>");
	$('#dialog').dialog('open');
	
	$( "#dialog" ).unbind( "dialogclose");
	$( "#dialog" ).bind( "dialogclose", function(event, ui) {
		mapHandler.toNormalMode();
		$( "#dialog" ).unbind("dialogclose");
	});
	
	mapHandler.abortAjaxRequest();
	mapHandler.currentAjaxRequest = $.ajax({
												type: "GET",
												url: url,
												success: function(html){
													
													if (mapHandler.currentMode != "help") return;
													$('#dialog_content').html(html);
												},
												error: function(req, status, e){
													if (req.status == 0) return;
													req.url = url;
													mainLibrary.logFailedAjax('/help', req, status, e);
													
													$('#dialog_content').html("<span class='loadError'></span>");
												}
											});
	
}

mapHandler.toNormalMode = function(force) {
	
	mapHandler.currentMode = "normal";
	mapHandler.addMarker.setVisible(false);
	
	$('#add_menu').hide();
	$('#search_menu').hide();
	$('#main_menu').show();

	mapHandler.showMarkers();
	mapHandler.queryLocation(force);
	
}


mapHandler.toSearchMode = function() {
	
	//mapHandler.current_mode = "search";
	_gaq.push(['_trackEvent', 'Map', 'Search', 'ToSearchBox']);
	
	$('#add_menu').hide();
	$('#main_menu').hide();
	$('#search_menu').show();
	
	$('#search_address').val("");
	$('#search_address').focus();
	
}

mapHandler.toggleFilterPanel = function() {
	
	if ($('#filter_button').hasClass('opened')) {
		
		$('#filter_button').removeClass('opened');
		$('#filter_panel').hide();
		$('#filter_panel_overlay').hide();
		
		mapHandler.cleanFilter();
		mapHandler.queryLocation();
		
		mapHandler.setFilterButton();
		
	} else { 
		$('#filter_button').addClass('opened');
		$('#filter_panel').show();
		$('#filter_panel_overlay').show();
	}

}

mapHandler.setFilterButton = function() {

	klasses = ['house',
				'single_room',
				'complex_room',
				
				'house_price',
				'single_room_price',
				'complex_room_price',

				'house_furniture',
				'single_room_furniture',
				'complex_room_furniture',

				'house_furniture_price',
				'single_room_furniture_price',
				'complex_room_furniture_price',

				'house_single_room',
				'house_complex_room',
				'single_room_complex_room',

				'house_single_room_price',
				'house_complex_room_price',
				'single_room_complex_room_price',

				'house_single_room_furniture',
				'house_complex_room_furniture',
				'single_room_complex_room_furniture',

				'house_single_room_furniture_price',
				'house_complex_room_furniture_price',
				'single_room_complex_room_furniture_price',

				'house_single_room_complex_room',
				'house_single_room_complex_room_price',
				'house_single_room_complex_room_furniture',
				'house_single_room_complex_room_furniture_price'];


	for (var i=0;i<klasses.length;i++) 
		$('#filter_button').removeClass(klasses[i]);

	
	var data = mapHandler.getFilterData();
	
	var newKlass = [];
	newKlass.push(data.type.replace(/,/g,"_").toLowerCase());
	
	if (data.hasFurniture == "yes" || data.hasInternet == "yes") {
		newKlass.push("furniture");
	}

	if (data.minPrice != "" || data.maxPrice != "") {
		newKlass.push("price");
	}
	
	$('#filter_button').addClass(newKlass.join('_'));
}

function is_select_filter(obj) {
	return $(obj).hasClass('selected');
}

function select_filter(obj) {
	$(obj).removeClass('selected');
	$(obj).addClass('selected');
}

function deselect_filter(obj) {
	$(obj).removeClass('selected');
	$(obj).addClass('selected');
}

function toggle_filter(obj) {
	if (is_select_filter(obj)) {
		$(obj).removeClass('selected');
	} else {
		$(obj).addClass('selected');
	}
}

mapHandler.cleanFilter = function() {
	
	$('#filter_min_price').val($.trim($('#filter_min_price').val()));
	$('#filter_max_price').val($.trim($('#filter_max_price').val()));
	
	var minPrice = 0;
	var maxPrice = 0;
	
	if ($('#filter_min_price').val().match(/[0-9]+/)) {
		minPrice = parseInt($('#filter_min_price').val());
	} else {
		$('#filter_min_price').val('');
	}
	
	if ($('#filter_max_price').val().match(/[0-9]+/)) {
		maxPrice = parseInt($('#filter_max_price').val());
		
		if (maxPrice < minPrice) {
			$('#filter_max_price').val('' + (minPrice + 1000));
		}
		
	} else {
		$('#filter_max_price').val('');
	}
	
	// nothing is selected
	if (!is_select_filter($('#filter_type_house'))
		&& !is_select_filter($('#filter_type_single_room'))
		&& !is_select_filter($('#filter_type_complex_room'))) {
			
		mapHandler.toggleFilterTypeHouse();
		mapHandler.toggleFilterTypeSingleRoom();
		mapHandler.toggleFilterTypeComplexRoom();
		
	}
	
}

mapHandler.getFilterData = function() {
	var type = [];
	
	if (is_select_filter($('#filter_type_house'))) {
		type.push("HOUSE");
	} 

	if (is_select_filter($('#filter_type_single_room'))) {
		type.push("SINGLE_ROOM");
	}

	if (is_select_filter($('#filter_type_complex_room'))) {
		type.push("COMPLEX_ROOM");
	}
	
	return { type: type.join(","),
			 hasFurniture: (is_select_filter($('#filter_has_furniture'))?"yes":""),
			 hasInternet: (is_select_filter($('#filter_has_internet'))?"yes":""),
			 minPrice: 	$('#filter_min_price').val(),
			 maxPrice:  $('#filter_max_price').val()
			};
	
}


mapHandler.toggleFilterTypeHouse = function() {
	toggle_filter($('#filter_type_house'));
}

mapHandler.toggleFilterTypeSingleRoom = function() {
	toggle_filter($('#filter_type_single_room'));
}

mapHandler.toggleFilterTypeComplexRoom = function() {
	toggle_filter($('#filter_type_complex_room'));
}

mapHandler.toggleFilterHasFurniture = function() {
	toggle_filter($('#filter_has_furniture'));
}

mapHandler.toggleFilterHasInternet = function() {
	toggle_filter($('#filter_has_internet'));
}

mapHandler.clearFilterPrice = function() {
	$('#filter_min_price').val('');
	$('#filter_max_price').val('');
}
