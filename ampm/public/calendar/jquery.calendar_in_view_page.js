/**
 * @author admin
 */
(function($) {
	
	$.fn.extend({
		
		day_selector_get_selected_date: function() {
			
			var elem = this[0];
			var result = [];
			
			for (var i in elem.selected_date)
			{
				result.push(i)
			}
			return result;
		},
		day_selector_reset: function() {
			
			return this.each(function() {
				for (var i in this.selected_date)
				{
					delete this.selected_date[i];
					
					$('#' + this.id + i).removeClass('calendar_day_selected');
					
					if (this.time_selector_panel != null) {
						$(this.time_selector_panel).time_selector_remove_date(i);
					}
				}
				
				$(this.time_selector_panel).time_selector_reset();
			});
		},
		day_selector_select_friend: function(friend_id) {
			return this.each(function(){
				
				$(this).day_selector_reset()
				
				var date = [];
				
				if (friend_id in this.hash_friends_to_date_unit)
					date = this.hash_friends_to_date_unit[friend_id];
				
				$(this).day_selector_manually_select(date);
			});
		},
		day_selector_manually_select: function(date) {

			return this.each(function(){
				for (var i=0;i<date.length;i++)
				{
					//if (!(date[i] in this.scope_date)) continue;
					
					//console.info(i)
					if (this.selected_date[date[i]] == undefined)
					{
						this.selected_date[date[i]] = true;
						$('#' + this.id + date[i]).addClass('calendar_day_selected');
					}
					else
					{
						delete this.selected_date[date[i]];
						$('#' + this.id + date[i]).removeClass('calendar_day_selected');
					}
				}
				
				if (this.friend_list_panel != null)
					$(this.friend_list_panel).show_friend_time($(this).day_selector_get_selected_date());
			});
		},
		day_selector: function(more_options) {
			
			var current_date = new Date();
			var options = {selected_date:[],
							friend_list_panel:null,
							disable_event:false,
							friends_data:[],
							scope_date:[]}
			
			$.extend(options,more_options);
			

			return this.each(function() {
				
				this.selected_date = {};
				this.in_the_process_of_selection = false;
				this.friend_list_panel = options.friend_list_panel;
				this.disable_event = options.disable_event;
				
				for (var i=0;i<options.selected_date.length;i++)
					this.selected_date[options.selected_date[i].substring(0,10)] = true;
				
				$(this).addClass('calendar');
				
				var months_to_show = {};
				this.scope_date = {}
				for (var i=0;i<options.scope_date.length;i++)
				{
					this.scope_date[options.scope_date[i].substring(0,10)] = true;
					
					months_to_show[options.scope_date[i].substring(0,7)] = true;
				}
				//console.info(this.scope_date)
				
				this.hash_date_unit_of_friends = {}
				this.hash_friends_to_date_unit = {}
				for (var i=0;i<options.friends_data.length;i++)
				{
					var date = options.friends_data[i].time.substring(0,10);

					if (!(date in this.hash_date_unit_of_friends))
						this.hash_date_unit_of_friends[date] = []
						
					this.hash_date_unit_of_friends[date].push(options.friends_data[i].friend);
					
					if (!(options.friends_data[i].friend in this.hash_friends_to_date_unit))
						this.hash_friends_to_date_unit[options.friends_data[i].friend] = []
					
					// change format
					this.hash_friends_to_date_unit[options.friends_data[i].friend].push(date);
				}
				
				var s = "";

				for (var month_code in months_to_show)
				{
					var start_date = $.parse_date(month_code+"-01");
					s += '<span class="span-35 margin-top-1 clearfix">\
								<span class="span-31 calendar_header">\
									<span class="calendar_month_label">\
										'+$.name_of_month[start_date.getMonth()]+'\
									</span> \
									<span class="calendar_year_label">\
										'+$.get_year(start_date)+'\
									</span>\
								</span>\
							</span>\
							<span class="span-35 fontsize11 bold_font medium_gray clearfix" style="margin-top:13px;">';
					
					// create header
					for (var i=0;i<=6;i++)
					{
						s += '<span class="calendar_header_day">'+$.days_of_week[i]+'</span>'
					}
					
					s += '</span>\
						  <span class="span-35 clearfix">'
					
					for (var i=0;i<=6;i++)
					{
						s += '<span class="calendar_color_day calendar_header_day_'+i+'"></span>';
					}
					
					s += '</span>'
					
					s += '<span class="view_day_mode"><span class="calendar_month_container span-35">'
					s += $(this).day_selector_generate_month(month_code+"-01")
					s += '</span></span>'
					
				}
				
				
				$(this).html(s);
				
				var temp_obj = this;
				$(this).children('.calendar_month_container').mouseleave(function(){
					$(temp_obj).day_selector_stop_select();
				})
				
				var children = $(this).find("*");
				for (var i=0;i<children.length;i++)
				{
					$.disable_selection(children[i]);
				}
				
				$(this).mouseleave(function(){
					$(this).day_selector_stop_select();
				})
				
				if (this.friend_list_panel != null)
					$(this.friend_list_panel).show_friend_time($(this).day_selector_get_selected_date());
			});
		},
		
		day_selector_generate_month: function(cur_date_str) {

			cur_date = $.parse_date(cur_date_str);
			
			start_date = new Date($.get_year(cur_date), cur_date.getMonth(), 1);

			var end_last_month = $.number_of_days($.get_year(start_date),start_date.getMonth()-1);
			var start_last_month = (end_last_month - start_date.getDay())+1;
			
			var end_current_month = $.number_of_days($.get_year(start_date),start_date.getMonth());
			
			end_date = new Date($.get_year(cur_date), cur_date.getMonth(), end_current_month);
			var end_next_month = 6-end_date.getDay();
			
			var run_day_of_week = 0;
			
			var cur_month_code = cur_date_str.substring(0,7);
			
			var s = '';
			
			// generate last month
			for (var i=start_last_month;i<=end_last_month;i++)
			{
				s += '<span class="calendar_other_month_day calendar_unit_disabled calendar_day_'+((run_day_of_week++)%7)+'"' +
					 '>&nbsp;<span class="calendar_unit_padding"></span></span>'
			}
			
			
			// generate current month
			for (var i=1;i<=end_current_month;i++)
			{
				var date = cur_month_code+'-'+$.add_zero(i);
				var selected_class = (this[0].selected_date[date])? "calendar_day_selected":"";
				
				var event = ' onmousedown="$(\'#'+this[0].id+'\').day_selector_start_select(\''+date+'\');"'+
					 		' onmouseup="$(\'#'+this[0].id+'\').day_selector_stop_select();"'+
					 		' onmouseover="$(\'#'+this[0].id+'\').day_selector_mouse_enter(\''+date+'\');"';
				var appended_class = "";
				
				var content = "";
				
				if (this[0].hash_date_unit_of_friends[date])
				{
					content = '<span class="span-4 margin-left-4px margin-top-1 font14  height20 align_center">';
					content += '<span class="friends_icon"></span> ' + this[0].hash_date_unit_of_friends[date].length;
					content += '</span>';
				}
				
				if (this[0].disable_event == true)
				{
					event = "";
					appended_class = (this[0].selected_date[date])? "_selected":"_static";
					selected_class = "";
				}
				
				if (!(date in this[0].scope_date))
				{
					event = "";
					appended_class = "_disabled";
					selected_class = "";
				}
				
				s += '<span style="position:relative;" id="'+this[0].id+date+'" class="'+selected_class+' calendar_month_day calendar_unit'+appended_class+' calendar_day_'+((run_day_of_week++)%7)+'"' +
					'>'+i+''+content+'<span class="calendar_unit_padding"></span>'+
					'<span style="position:absolute;left:0px;top:0px;width:100%;height:100%;" '+event+'>&nbsp;</span>'+
					'</span>'
			}
	
			// generate next month
			for (var i=1;i<=end_next_month;i++)
			{
				s += '<span class="calendar_other_month_day calendar_unit_disabled calendar_day_'+((run_day_of_week++)%7)+'"' +
					'>&nbsp;<span class="calendar_unit_padding"></span></span>'
			}
			
			return s;
		},
		
		day_selector_select: function(date){
		
			return this.each(function(){
				if (this.selected_date[date] == true) {
					delete this.selected_date[date];
					$('#' + this.id + date).removeClass('calendar_day_selected');
					
					if (this.time_selector_panel != null) {
						$(this.time_selector_panel).time_selector_remove_date(date);
					}
				}
				else {
					this.selected_date[date] = true;
					$('#' + this.id + date).addClass('calendar_day_selected');
					
					if (this.time_selector_panel != null) {
						$(this.time_selector_panel).time_selector_add_date(date);
					}
				}
				
				if (this.friend_list_panel != null)
					$(this.friend_list_panel).show_friend_time($(this).day_selector_get_selected_date());
			});
		},
		
		day_selector_start_select: function(date){
			return this.each(function(){
				this.in_the_process_of_selection = true;
				
				$(this).day_selector_select(date);
				
				//console.info('start')
			});
		},
		
		day_selector_stop_select: function(){
			return this.each(function(){
				this.in_the_process_of_selection = false;
				//console.info('stop')
			});
		},
		
		day_selector_mouse_enter: function(date){
			
			return this.each(function(){
				//console.info(this.in_the_process_of_selection+"")
				if (!this.in_the_process_of_selection) return;
				
				$(this).day_selector_select(date);
			});
		}
	});
	
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

})(jQuery);