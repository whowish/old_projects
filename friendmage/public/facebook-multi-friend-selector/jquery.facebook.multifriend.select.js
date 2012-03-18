// Copyright 2010 Mike Brevoort http://mike.brevoort.com @mbrevoort
// 
// v1.0 jquery-facebook-multi-friend-selector
// 
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
   
(function($) { 
    var JFMFS = function(element, options) {
        var elem = $(element),
            obj = this,
            uninitializedImagefriendElements = [], // for images that are initialized
            keyUpTimer,
            friends_per_row = 0,
            friend_height_px = 0,
            first_element_offset_px;
            
        var settings = $.extend({
            max_selected: -1,
            max_selected_message: "{0} of {1} selected",
			pre_selected_friends: [],
			exclude_friends: [],
			friend_fields: "id,name",
			sorter: function(a, b) {
                var x = a.name.toLowerCase();
                var y = b.name.toLowerCase();
                return ((x < y) ? -1 : ((x > y) ? 1 : 0));
            },
			labels: {
				selected: "Selected",
				filter_default: "Start typing a name",
				filter_title: "&nbsp; Who will join?:",
				all: "All",
				max_selected_message: "{0} of {1} selected"
			},
			width:740,
			height:358
        }, options || {});
		
		this.settings = settings;
		
        var lastSelected;  // used when shift-click is performed to know where to start from to select multiple elements
                
        var arrayToObjectGraph = function(a) {
			  var o = {};
			  for(var i=0, l=a.length; i<l; i++){
			    o[a[i]]=true;
			  }
			  return o;
		};
		
        // ----------+----------+----------+----------+----------+----------+----------+
        // Initialization of container
        // ----------+----------+----------+----------+----------+----------+----------+
		
		view_by_letters = ""
		
		blocks = "ABC,DEF,GHI,JKL,MNO,PQR,STU,VWXYZ".split(',')
		for (var i=0;i<blocks.length;i++)
		{
			view_by_letters += '<a href="#" class="white margin-left-1" style="font-weight:normal;" onclick="$.show_friends(\''+blocks[i].split("").join(",")+'\',true);return false;">'+blocks[i]+'</a>'
		}
		
        elem.html(
            "<div id='jfmfs-friend-selector' style='width:"+settings.width+"px !important;height:"+settings.height+"px !important;'>" +
            "    <div id='jfmfs-inner-header'>" +
			"		<span style='float:left'>" +
            "        <span class='jfmfs-title'>" + settings.labels.filter_title + " </span><input type='text' id='jfmfs-friend-filter-text' value=''/>" +
        	"		</span>" +
			"		<span style='float:left;margin-top:2px;margin-left:5px;'>" +
			"        <a class='active' id='jfmfs-thumb-view-icon' href='#'></a>" +
            "        <a id='jfmfs-list-view-icon' href='#'></a>" +
			"		</span>"+
			"        <a class='filter-link selected' id='jfmfs-filter-all' href='#'>" + settings.labels.all + "</a>" +
            "        <a class='filter-link' id='jfmfs-filter-selected' href='#'>" + settings.labels.selected + " (<span id='jfmfs-selected-count'>0</span>)</a>" +
            ((settings.max_selected > 0) ? "<div id='jfmfs-max-selected-wrapper'></div>" : "") +
            "    </div>" +
			"	 <div id='jfmfs-inner-header' style='height:15px;line-height:15px;background-color:#666666;font-size:11px;font-weight:normal;'>" +
			"     &nbsp; View by letters: " + view_by_letters + 
			"    </div>" +
            "    <div id='jfmfs-friend-container'></div>" +
            "</div>" 
        );
		
		var is_list_view = function()
		{
			return $('#jfmfs-list-view-icon').hasClass('active');
		}
        
        var friend_container = $("#jfmfs-friend-container"),
            container = $("#jfmfs-friend-selector"),
			excluded_friends_graph = arrayToObjectGraph(settings.exclude_friends),
            all_friends,
			selected_friends = {};
        
			for (var i=0;i<settings.pre_selected_friends.length;i++)
			{
				var id = settings.pre_selected_friends[i].id;
				selected_friends[id] = settings.pre_selected_friends[i];
			}
        
        // ----------+----------+----------+----------+----------+----------+----------+
        // Public functions
        // ----------+----------+----------+----------+----------+----------+----------+
        
        this.getSelectedIds = function() {
            var ids = [];
			
			for (var i in selected_friends)
			{
				ids.push(i);
			}
           
            return ids;
        };
        
        this.getSelectedIdsAndNames = function() {
            var selected = [];
			for (var i in selected_friends)
			{
				selected.push( {id: i, name: selected_friends[i].name});
			}
           
            return selected;
        };
        
        this.clearSelected = function () {
			selected_friends = {}
            all_friends.removeClass("selected");
        };
        
        // ----------+----------+----------+----------+----------+----------+----------+
        // Private functions
        // ----------+----------+----------+----------+----------+----------+----------+
        
        var init = function() {
            all_friends = $(".jfmfs-friend", elem);
            
            // calculate friends per row
			try {
				first_element_offset_px = all_friends.first().offset().top;
				for (var i = 0, l = all_friends.length; i < l; i++) {
					if ($(all_friends[i]).offset().top === first_element_offset_px) {
						friends_per_row++;
					}
					else {
						friend_height_px = $(all_friends[i]).offset().top - first_element_offset_px;
						break;
					}
				}
			} catch (e)  {}
            
            // handle when a friend is clicked for selection
            elem.delegate(".jfmfs-friend", 'click', function(event) {
            
                // if the element is being selected, test if the max number of items have
                // already been selected, if so, just return
                if(!$(this).hasClass("selected") && 
                    maxSelectedEnabled() &&
                    $(".jfmfs-friend.selected").size() >= settings.max_selected &&
                    settings.max_selected != 1) {
                        return;
                    }
                    
                // if the max is 1 then unselect the current and select the new    
                if(settings.max_selected == 1) {
                    elem.find(".selected").removeClass("selected");                    
                }
				
				var facebook_id = $(this).attr("id");
				var name = $(this).find(".facebook_name").text();
				
				if (facebook_id in selected_friends) delete selected_friends[facebook_id];
				else selected_friends[facebook_id] = {id: facebook_id, name: name};
                   
				if (facebook_id in selected_friends) $(this).addClass("selected");
				else $(this).removeClass("selected");
                
                $(this).removeClass("hover");
                
                // support shift-click operations to select multiple items at a time
                if( $(this).hasClass("selected")) {
                    if ( !lastSelected ) {
                        lastSelected = $(this);
                    } 
                    else {                        
                        if( event.shiftKey ) {
                            var selIndex = $(this).index();
                            var lastIndex = lastSelected.index();
                            var end = Math.max(selIndex,lastIndex);
                            var start = Math.min(selIndex,lastIndex);
                            for(var i=start; i<=end; i++) {
                                var aFriend = $( all_friends[i] );
                                if(!aFriend.hasClass("hide-non-selected") && !aFriend.hasClass("hide-filtered")) {
                                    if( maxSelectedEnabled() && $(".jfmfs-friend.selected").size() < settings.max_selected ) {
                                        $( all_friends[i] ).addClass("selected");                                        
                                    }
                                }
                            }
                        }
                    }
                }
                
                // keep track of last selected, this is used for the shift-select functionality
                lastSelected = $(this);
                
                // update the count of the total number selected
                updateSelectedCount();

                if( maxSelectedEnabled() ) {
                    updateMaxSelectedMessage();
                }
                elem.trigger("jfmfs.selection.changed", [obj.getSelectedIdsAndNames()]);
            });
			
			$("#jfmfs-thumb-view-icon").click(function(event) {
				event.preventDefault();
				$("#jfmfs-list-view-icon").removeClass("active");
                $(this).addClass("active");	

				str = "";
				for (var i=0;i<sortedFriendData.length;i++)
					str += render_jfmfs_block(sortedFriendData[i]);

				friend_container.html(str);
			
					
			});
			
			$("#jfmfs-list-view-icon").click(function(event) {
				event.preventDefault();
				$("#jfmfs-thumb-view-icon").removeClass("active");
                $(this).addClass("active");
				
				str = "";
				for (var i=0;i<sortedFriendData.length;i++)
					str += render_jfmfs_block(sortedFriendData[i]);

				friend_container.html(str);
			
				
			});

            // filter by selected, hide all non-selected
            $("#jfmfs-filter-selected").click(function(event) {
				event.preventDefault();
                //all_friends.not(".selected").addClass("hide-non-selected");
				
				str = "";
				sortedFriendData = []
				for (var facebook_id in selected_friends)
				{
					str += render_jfmfs_block({id:facebook_id,name:selected_friends[facebook_id].name});
                	sortedFriendData.push({id:facebook_id,name:selected_friends[facebook_id].name});
				}
				
				friend_container.html(str);
				
				$("#jfmfs-filter-all").removeClass("selected");
                $(this).addClass("selected");
            });

            // remove filter, show all
            $("#jfmfs-filter-all").click(function(event) {
				event.preventDefault();
	
				getFriendAjaxically($('#jfmfs-friend-filter-text').val());
				
                $("#jfmfs-filter-selected").removeClass("selected");
                $(this).addClass("selected");
            });

            // hover effect on friends
            elem.find(".jfmfs-friend:not(.selected)").live(
                'hover', function (ev) {
                    if (ev.type == 'mouseover') {
                        $(this).addClass("hover");
                    }
                    if (ev.type == 'mouseout') {
                        $(this).removeClass("hover");
                    }
                });

            // filter as you type 
            elem.find("#jfmfs-friend-filter-text")
                .keyup( function() {
                    var filter = $(this).val();
                    clearTimeout(keyUpTimer);
                    keyUpTimer = setTimeout( function() {
						getFriendAjaxically(filter);

                        showImagesInViewPort();                        
                    }, 400);
                })
                .default_text(settings.labels.filter_default,true)

            // hover states on the buttons        
            elem.find(".jfmfs-button").hover(
                function(){ $(this).addClass("jfmfs-button-hover");} , 
                function(){ $(this).removeClass("jfmfs-button-hover");}
            );

			
			var getFriendAjaxically = function(q,by_letter){
				
				var current_q = q;
				friend_container.html("<div style='width:200px;margin-left:"+((settings.width-100)/2)+"px;margin-top:"+((settings.height-100)/2)+"px;'><img src='/images/button_loader.gif'>Loading ...</span>");
				
				url = '/friend/search';
				if (by_letter == true) url = '/friend/view'
				
				$.ajax({
					type: "POST",
					url: url,
					cache: false,
					data: {
						q:q
					},
					success: function(data){
						if (q != current_q) return;
						
						try {
							sortedFriendData = data;
							str = "";
							for (var i=0;i<data.length;i++)
							{
								str += render_jfmfs_block(data[i]);
							}
							
							if (q == "")
								str += "<span style='width:"+(settings.width-100)+"px;color:#666666;display:block;float:left;margin-left:10px;margin-top:10px;'>* Only some friends are randomly shown. Please search to find more friends.</span>";
							
							friend_container.html(str);
						} 
						catch (e) {
							
						}
						
					},
					error: function(req, status, e){
					}
				});
			}
			
			$.show_friends = getFriendAjaxically;      
            
            // manages lazy loading of images
            var getViewportHeight = function() {
                var height = window.innerHeight; // Safari, Opera
                var mode = document.compatMode;

                if ( (mode || !$.support.boxModel) ) { // IE, Gecko
                    height = (mode == 'CSS1Compat') ?
                    document.documentElement.clientHeight : // Standards
                    document.body.clientHeight; // Quirks
                }

                return height;
            };
            
            var showImagesInViewPort = function() {
//                var container_height_px = friend_container.innerHeight(),
//                    scroll_top_px = friend_container.scrollTop(),
//                    container_offset_px = friend_container.offset().top,
//                    $el, top_px,
//                    elementVisitedCount = 0,
//                    foundVisible = false,
//                    allVisibleFriends = $(".jfmfs-friend:not(.hide-filtered )");
//
//                $.each(allVisibleFriends, function(i, $el){
//                    elementVisitedCount++;
//                    if($el !== null) {
//                        $el = $(allVisibleFriends[i]);
//                        top_px = (first_element_offset_px + (friend_height_px * Math.ceil(elementVisitedCount/friends_per_row))) - scroll_top_px - container_offset_px; 
//						if (top_px + friend_height_px >= -10 && 
//                            top_px - friend_height_px < container_height_px) {  // give some extra padding for broser differences
//                                $el.data('inview', true);
//                                $el.trigger('inview', [ true ]);
//                                foundVisible = true;
//                        } 
//                        else {                            
//                            if(foundVisible) {
//                                return false;
//                            }
//                        }                            
//                    }              
//                });
            };

			var updateSelectedCount = function() {
				var count = 0;
				for (var i in selected_friends) count++;
				$("#jfmfs-selected-count").html( count+"" );
			};

            friend_container.bind('scroll', $.debounce( 250, showImagesInViewPort ));

            updateMaxSelectedMessage();                      
            showImagesInViewPort();
			updateSelectedCount();
            elem.trigger("jfmfs.friendload.finished");
        };
		
		var render_jfmfs_block = function(data_unit) {
			str = ""
			selected = ""
			if (data_unit.id in selected_friends) selected = "selected";
			
			
			remark =(data_unit.id in excluded_friends_graph)?"(already invited)": "";
			
			if (is_list_view()) {
				normalClass =(data_unit.id in excluded_friends_graph)?"jfmfs-friend-list-unit-disabled": "jfmfs-friend list-unit";
				str = "<div title='"+data_unit.name+"' class='"+normalClass+" " + selected + "' style='height:20px;' id='" + data_unit.id + "'><span class='facebook_name'>" + data_unit.name + "</span> " + remark + "</div>";
			}
			else {
				normalClass =(data_unit.id in excluded_friends_graph)?"jfmfs-friend-disabled": "jfmfs-friend";
				img = "<img src='http://graph.facebook.com/" + data_unit.id + "/picture'/>";
				str = "<div title='"+data_unit.name+"' class='" + normalClass + " " + selected + " ' id='" + data_unit.id + "'>" + img + "<div class='friend-name'><span class='facebook_name'>" + data_unit.name + "</span> " + remark + "</div></div>";
			}
			
			return str;
		}

        var selectedCount = function() {
            return $(".jfmfs-friend.selected").size();
        };

        var maxSelectedEnabled = function () {
            return settings.max_selected > 0;
        };
        
        var updateMaxSelectedMessage = function() {
            var message = settings.labels.max_selected_message.replace("{0}", selectedCount()).replace("{1}", settings.max_selected);
            $("#jfmfs-max-selected-wrapper").html( message );
        };
			
        var sortedFriendData = settings.data.sort(settings.sorter),
            preselectedFriends = {},
            buffer = [],
		    selectedClass = "";
			
			
        $.each(sortedFriendData, function(i, friend) {
            buffer.push(render_jfmfs_block(friend));            
        });
        friend_container.append(buffer.join("")+"<span style='width:"+(settings.width-100)+"px;color:#666666;display:block;float:left;margin-left:10px;margin-top:10px;'>* Only some friends are randomly shown. Please search to find more friends.</span>");
        
        uninitializedImagefriendElements = $(".jfmfs-friend", elem);            
        uninitializedImagefriendElements.bind('inview', function (event, visible) {
            if( $(this).attr('src') === undefined) {
                $("img", $(this)).attr("src", "//graph.facebook.com/" + this.id + "/picture");
            }
            $(this).unbind('inview');
        });

        init();
        
    };
    

    
    $.fn.jfmfs = function(options) {
        return this.each(function() {
            var element = $(this);
            
            // Return early if this element already has a plugin instance
            if (element.data('jfmfs')) { return; }
            
            // pass options to plugin constructor
            var jfmfs = new JFMFS(this, options);
            
            // Store plugin object in this element's data
            element.data('jfmfs', jfmfs);
            
        });
    };
    
    // todo, make this more ambiguous
    jQuery.expr[':'].Contains = function(a, i, m) { 
        return jQuery(a).text().toUpperCase().indexOf(m[3].toUpperCase()) >= 0; 
    };
        

})(jQuery);

if($.debounce === undefined) {
    /*
     * jQuery throttle / debounce - v1.1 - 3/7/2010
     * http://benalman.com/projects/jquery-throttle-debounce-plugin/
     * 
     * Copyright (c) 2010 "Cowboy" Ben Alman
     * Dual licensed under the MIT and GPL licenses.
     * http://benalman.com/about/license/
     */
    (function(b,c){var $=b.jQuery||b.Cowboy||(b.Cowboy={}),a;$.throttle=a=function(e,f,j,i){var h,d=0;if(typeof f!=="boolean"){i=j;j=f;f=c}function g(){var o=this,m=+new Date()-d,n=arguments;function l(){d=+new Date();j.apply(o,n)}function k(){h=c}if(i&&!h){l()}h&&clearTimeout(h);if(i===c&&m>e){l()}else{if(f!==true){h=setTimeout(i?k:l,i===c?e-m:e)}}}if($.guid){g.guid=j.guid=j.guid||$.guid++}return g};$.debounce=function(d,e,f){return f===c?a(d,e,false):a(d,f,e!==false)}})(this);
}
