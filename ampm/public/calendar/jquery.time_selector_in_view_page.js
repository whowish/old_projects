/**
 * @author admin
 */
(function($) {
	
	$.fn.extend({
		time_selector_get_selected_time: function() {
			
			var selected_date;
			
			if (this[0].calendar_panel == null) selected_date = {}
			else selected_date = this[0].calendar_panel.selected_date
			
			var elem = this[0];
			var result = [];
			
			for (var i in elem.selected_time)
			{
				var date_id = i.substring(0,10);
				var hour = i.substring(11);
				
				if (this[0].calendar_panel == null || selected_date[date_id] != undefined)
					result.push(date_id + " " + hour + ":00:00")
			}
			return result;
		},
		time_selector_reset: function() {
			
			return this.each(function() {
				for (var i in this.selected_time)
				{
					delete this.selected_time[i];
					$('#' + this.id + '-' + i).removeClass('time_unit_deselected');
					$('#' + this.id + '-' + i).removeClass('time_unit_selected');
				}
			});
		},
		time_selector_remove_friend: function(friend_id) {
			
			return this.each(function() {
				
			});
		},
		time_selector: function(more_options) {
			var options = {selected_time: [],
							shown_date:[],
							friend_list_panel:null,
							calendar_panel:null,
							disable_event:false,
							friends_data:[],
							scope_date:[]
						}
			
			$.extend(options,more_options );
			
			
			
			return this.each(function() {
				$(this).addClass('timeline');
			
				$(this).mouseleave(function(){
					$(this).time_selector_stop_select();
				})
				this.friend_list_panel = options.friend_list_panel;
				this.calendar_panel = options.calendar_panel;
				this.disable_event = options.disable_event;
				this.in_the_process_of_selection = false;
				
				this.shown_date = {};
				this.selected_time = {};
				this.start_date_time = null;
				this.end_date_time = null;
				this.last_end_date_time = null;
				
				this.min_time = 23;
				this.max_time = 0;
				this.scope_date = {};
				for (var i=0;i<options.scope_date.length;i++)
				{
					var hour = options.scope_date[i].substring(11,13);
					if (this.min_time > hour) this.min_time = hour;
					if (this.max_time < hour) this.max_time = hour;
					
					this.scope_date[options.scope_date[i]] = true;
				}
				
				this.hash_date_unit_of_friends = {}
				this.hash_friends_to_date_unit = {}
				for (var i=0;i<options.friends_data.length;i++)
				{
					if (!(options.friends_data[i].time in this.hash_date_unit_of_friends))
						this.hash_date_unit_of_friends[options.friends_data[i].time] = []
						
					this.hash_date_unit_of_friends[options.friends_data[i].time].push(options.friends_data[i].friend);
					
					if (!(options.friends_data[i].friend in this.hash_friends_to_date_unit))
						this.hash_friends_to_date_unit[options.friends_data[i].friend] = []
					
					// change format
					this.hash_friends_to_date_unit[options.friends_data[i].friend].push(options.friends_data[i].time.substring(0,10)+"-"+options.friends_data[i].time.substring(11,13));
				}
				
				for (var i = 0; i < options.selected_time.length; i++)
					this.selected_time[options.selected_time[i]] = true;
				
				for (var i = 0; i < options.shown_date.length; i++)
					this.shown_date[options.shown_date[i]] = true;
					
				s = '<span class="time_viewer">\
                    	<span class="span-5 height-5 light_medium_gray_bg">\
                    		<span class="span-5 font16 black bold_font lineheight-14px margin-top-4px">\
                     			&nbsp;\
	                    	</span>\
	                    </span>\
						<span class="depth_box depth-white height-5 ">\
                        </span>';
				
				for (var i=this.min_time;i<=this.max_time;i++)
				{
					var highlight_class = "pm_time_view"
					if (i >= 8 && i <= 18) highlight_class = "am_time_view"
					
					s += '<span class="time_unit_no_hover '+highlight_class+'">\
                          	'+ $.add_zero(i) +' : 00\
                          </span>';
				}
						
				s += '</span>';
				
				$(this).html(s+'<span class="timeline_bottom"></span>');

				for (var i in this.selected_time)
				{
					$(this).time_selector_add_date(i.substring(0,10));
				}
				
				for (var i in this.shown_date) {
					$(this).time_selector_add_date(i);
				}
				
				
				
			});
		},
		time_selector_add_date: function(date) {
			return this.each(function() {
				
				if ($('#'+this.id+'-'+date).length > 0) return;
				
				var date_obj = $.parse_date(date);
				s = '<span class="time_viewer" id="'+this.id+'-'+date+'" style="display:none;cursor:pointer;">';
				s += '<span onmouseup="$(\'#'+this.id+'\').time_selector_select_whole_day(\''+date+'\');" \
						class="span-5 height-5 timeline_day_'+date_obj.getDay()+'">\
                        <span class="span-5 font16 black bold_font lineheight-14px margin-top-4px">\
                           <span class="span-5 font11">'+$.days_of_week[date_obj.getDay()]+'</span>\
                           <span class="span-5 font10">'+$.name_of_month[date_obj.getMonth()].substring(0,3)+'</span>\
                           <span class="span-5 font16">'+date_obj.getDate()+'</span>\
                        </span>\
                     </span>\
                    <span class="depth_box depth-day-'+date_obj.getDay()+' height-5">\
                    </span>';
				
				for (var i=this.min_time;i<=this.max_time;i++){
					var unit_date_time = date + " "+$.add_zero(i);
					var date_time_id = date + "-"+$.add_zero(i);
					
					var selected_class = "";
					if (this.selected_time[date_time_id] == true)
						selected_class = "time_unit_selected"
						
					var event_str = "";
					
					var highlight_class = "pm_time_view"
					if (i >= 8 && i <= 18) highlight_class = "am_time_view"
					
					var content = "";
					var normalized_date = date + " "+$.add_zero(i)+":00:00";
					
					if (this.hash_date_unit_of_friends[normalized_date])
					{
						content = '<span class="friends_icon"></span> ' + this.hash_date_unit_of_friends[date + " "+$.add_zero(i)+":00:00"].length;
					}
					
					var time_unit_class = "time_unit_no_hover"
					if (this.disable_event == false && (normalized_date in this.scope_date))
					{
						time_unit_class = "time_unit"
						
						event_str = ' onmousedown="$(\'#'+this.id+'\').time_selector_start_select(\''+unit_date_time+'\');"'+
						 ' onmouseup="$(\'#'+this.id+'\').time_selector_stop_select();"'+
						 ' onmouseover="$(\'#'+this.id+'\').time_selector_mouse_enter(\''+unit_date_time+'\');"'
					}
					
					s += '<span id="'+this.id+'-'+date_time_id+'"" class="'+time_unit_class+' '+highlight_class+' '+selected_class+'"'+
					 	 event_str +
						 '>'+content+'</span>';
				}
				
				s += '</span>'
				
				
				var cols = $(this).children('.time_viewer');
				var inserted = false;
				for (var i=0;i<cols.length;i++)
				{
					var col_date = cols[i].id.substring((this.id+'-').length);
					
					if ($.compare_date(date,col_date) < 0)
					{
						$(cols[i]).before(s);
						
						inserted = true;
						break;
					}
				}
				
				if (!inserted) {
					$(this).children('.timeline_bottom').before(s);
				}
				
				$.disable_selection($('#'+this.id+'-'+date)[0]);
				var children = $('#'+this.id+'-'+date).find("*");
				for (var i=0;i<children.length;i++)
				{
					$.disable_selection(children[i]);
				}
				
				$('#'+this.id+'-'+date).fadeIn()
				
				if (this.friend_list_panel != null)
					$(this.friend_list_panel).show_friend_time($(this).time_selector_get_selected_time());
				
				var height = (50 + (this.max_time - this.min_time + 1)*20 + 1) + 20;
				$(this).parent().css('height',height+'px')
				$(this).css('height',height+'px')
			});
		},
		time_selector_remove_date: function(date) {
			return this.each(function() {
				var temp_obj = $('#'+this.id+'-'+date)[0];
				
				// change id
				temp_obj.id = temp_obj.id + (new Date).toUTCString();
				$(temp_obj).fadeOut(function() {
					$(this).remove();
				});
				
				if (this.friend_list_panel != null)
					$(this.friend_list_panel).show_friend_time($(this).time_selector_get_selected_time());
				
			});
		},
		time_selector_select_friend: function(friend_id) {
			return this.each(function(){
				
				$(this).time_selector_reset()
				
				var date = [];
				
				if (friend_id in this.hash_friends_to_date_unit)
					date = this.hash_friends_to_date_unit[friend_id];
				
				$(this).time_selector_manually_select(date);
			});
		},
		time_selector_manually_select: function(date) {

			return this.each(function(){
				for (var i=0;i<date.length;i++)
				{
					//if (!(date[i] in this.scope_date)) continue;
					
					//console.info(i)
					if (this.selected_time[date[i]] == undefined)
					{
						this.selected_time[date[i]] = true;
						$('#' + this.id + '-' + date[i]).addClass('time_unit_selected');
					}
					else
					{
						delete this.selected_time[date[i]];
						$('#' + this.id + '-' + date[i]).removeClass('time_unit_deselected');
						$('#' + this.id + '-' + date[i]).removeClass('time_unit_selected');
					}
				}
				
				if (this.friend_list_panel != null)
					$(this.friend_list_panel).show_friend_time($(this).time_selector_get_selected_time());
			});
		},
		time_selector_select_whole_day: function(date){
		
			return this.each(function(){
				
				to_add_date = []
				
				var all_day_is_selected = true;
				
				for (var i=0;i<24;i++)
				{
					var date_id = date+"-"+$.add_zero(i);
					var normalized_date_id = date + " " + $.add_zero(i)+":00:00";
					
					
					if (normalized_date_id in this.scope_date)
					{
						if (this.selected_time[date_id] == undefined)
						{
							to_add_date.push(date_id);
							all_day_is_selected = false;
						}
					}
					
					
				}
				
				if (all_day_is_selected)
				{
					for (var i = 0; i < 24; i++) {
						var date_id = date+"-"+$.add_zero(i);
						var normalized_date_id = date + " " + $.add_zero(i)+":00:00";
						
						if (normalized_date_id in this.scope_date) {
							to_add_date.push(date_id);
						}
					}
				}
				
				$(this).time_selector_manually_select(to_add_date);
			});
		},
		time_selector_select: function(start_date_time,end_date_time){
		
			return this.each(function(){
			
				var date = [];
				//console.info(this.selected_time)
				for (var i in this.current_highlight)
				{
					date.push(i);
				}
				
				$(this).time_selector_manually_select(date);
			});
		},
		
		time_selector_start_select: function(date_time){
			return this.each(function(){
				
				if (this.in_the_process_of_selection == true) return;
				
				this.in_the_process_of_selection = true;
				this.start_date_time = date_time;
				this.end_date_time = date_time;
				
				$(this).time_selector_highlight();
			});
		},
		
		time_selector_stop_select: function(date_time){
			return this.each(function(){
				
				if (this.in_the_process_of_selection == false) return;
				
				this.in_the_process_of_selection = false;
				
				if (date_time != undefined) this.end_date_time = date_time;
				this.last_end_date_time = null;
				
				$(this).time_selector_select(this.start_date_time,this.end_date_time);
			});
		},
		
		time_selector_mouse_enter: function(date_time){
			
			return this.each(function(){
				//console.info(this.in_the_process_of_selection+"")
				if (!this.in_the_process_of_selection) return;
				
				this.end_date_time = date_time;
				
				$(this).time_selector_highlight();
			});
		},
		
		time_selector_highlight: function(){
			
			return this.each(function(){
				var a = this.start_date_time.substring(0,10);
				var b = this.end_date_time.substring(0,10);
				var current_highlight = {};
				
				if (this.current_highlight == undefined) this.current_highlight = {};
				
				var start_date = a;
				var end_date = b;
				if ($.compare_date(a,b) > 0)
				{
					start_date = b;
					end_date = a;
				}
				
				a = parseInt(this.start_date_time.substring(11),10)
				b = parseInt(this.end_date_time.substring(11),10)
				
				var start_time = (a<b)?a:b;
				var end_time = (a>b)?a:b;
				
				//console.info(start_date + " " + start_time + " " + end_date + " " +end_time)
				
				var cols = $(this).children('.time_viewer');
				for (var i=1;i<cols.length;i++)
				{
					var col_date = cols[i].id.substring((this.id+'-').length);
					//console.info(col_date)
					if (!($.compare_date(start_date,col_date) > 0)
						&& !($.compare_date(col_date,end_date) > 0 ))
					{
						for (var j=start_time;j<=end_time;j++)
						{
							var normalized_date_id = col_date + " " + $.add_zero(j)+":00:00";
							
							if (!(normalized_date_id in this.scope_date)) continue;
							
							var date_time_id = col_date + "-" + $.add_zero(j);
							current_highlight[date_time_id] = true;
							
							if (this.current_highlight[date_time_id]) {
								delete this.current_highlight[date_time_id]
							}
							
							//console.info('#' + this.id + '-' + col_date + "-" + $.add_zero(j))
							if (this.selected_time[date_time_id] == true) {
								$('#' + this.id + '-' + date_time_id).removeClass('time_unit_selected');
								$('#' + this.id + '-' + date_time_id).addClass('time_unit_deselected');
							}
							else {
								$('#' + this.id + '-' + date_time_id).addClass('time_unit_selected');
							}
						}
					}
					
				}
				
				// delete old
				for (i in this.current_highlight)
				{
					if (this.selected_time[i] == true) {
						$('#' + this.id + '-' + i).removeClass('time_unit_deselected');
						$('#' + this.id + '-' + i).addClass('time_unit_selected');
					}
					else {
						$('#' + this.id + '-' + i).removeClass('time_unit_selected');
					}
				}
				
				this.current_highlight = current_highlight;
			
			});
		}
	});
	
	$.compare_date = function(a,b) {
		var ta = a.split('-');
		var tb = b.split('-');
		
		var ya = parseInt(ta[0],10);
		var yb = parseInt(tb[0],10);
		
		var ma = parseInt(ta[1],10);
		var mb = parseInt(tb[1],10);
		
		var da = parseInt(ta[2],10);
		var db = parseInt(tb[2],10);
		
		if (ya != yb) return (ya-yb);
		if (ma != mb) return (ma-mb);
		if (da != db) return (da-db);
		
	}

	$.disable_selection = function (target){
		if (typeof target.onselectstart!="undefined") //IE route
			target.onselectstart=function(){return false}
		else if (typeof target.style.MozUserSelect!="undefined") //Firefox route
			target.style.MozUserSelect="none"
		else //All other route (ie: Opera)
			target.onmousedown=function(){return false}
		//target.style.cursor = "default"
	}
	
	$.adjust_month = function(date_str,diff){
		var tokens = date_str.split('-');
		
		var year = parseInt(tokens[0],10);
		var month = parseInt(tokens[1],10);
		
		month = month +diff;
		
		if (month == -1) {
			month = 12;
			year--;
		} else if (month == 12) {
			month = 1;
			year++;
		}
		
		return year +"-"+$.add_zero(month)+"-"+tokens[2];
	}
	
	$.get_year = function(date_obj)
	{
		var y = date_obj.getYear();
		
		return (y < 2000)? (y+1900):y;
	}
	
	$.parse_date = function (date_str) {
		var tokens = date_str.split('-');
		
		return new Date(parseInt(tokens[0],10),parseInt(tokens[1],10)-1,parseInt(tokens[2],10));
	}
	
	$.name_of_month = ["January","February","March","April","May","June","July","August","September","October","November","December"]
	
	$.days_of_week = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
	$.number_of_days = function(year,month) {
		
		if (month == -1) {
			year--;
			month = 11;
		} else if (month == 12) {
			year++;
			month = 0;
		}
		
		if (month == 1)
		{
			if ((year%4)==0) return 29;
			else return 28;
		}
		else
		{
			var nums = [31,28,31,30,31,30,31,31,30,31,30,31];
			
			return nums[month];
		}
	}
	
	$.add_zero = function(n)
	{
		n = parseInt(n,10);
		
		if (n<10) return "0"+n;
		else return n;
	}
	
})(jQuery)
