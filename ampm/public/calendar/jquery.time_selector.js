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
					$('#' + this.id + '-' + i).removeClass('timeline_unit_deselected');
					$('#' + this.id + '-' + i).removeClass('timeline_unit_selected');
				}
			});
		},
		time_selector: function(more_options) {
			var options = {selected_time: [],shown_date:[],friend_list_panel:null,calendar_panel:null,disable_event:false}
			
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
				
				for (var i = 0; i < options.selected_time.length; i++)
					this.selected_time[options.selected_time[i]] = true;
				
				for (var i = 0; i < options.shown_date.length; i++)
					this.shown_date[options.shown_date[i]] = true;
				
				/*
				var blank_panel = "<span class='timeline_blank' style='display:block;'>"
									+ "&lt;-- Click on the calendar to add all possible meeting times."
									+ "</span>"
				*/
				
				var blank_panel = '<span class="timeline_blank span-31 margin-left-4px margin-top-8"> \
										<span class="left_yellow_arrow display_inline_block"> \
										</span><span class="height20 padding_horizontal_4px yellow_2meet4_bg dark_gray font11 bold_font display_inline_block">\
											Click on calendar to add all possible meeting times \
										</span> \
									</span>';
				$(this).html(blank_panel+'<span class="timeline_bottom"></span>');
				
				
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

				s = '<span class="timeline_column" id="'+this.id+'-'+date+'" style="display:none;cursor:pointer;">\
						<span onclick="$(\'#'+this.id+'\').time_selector_select_whole_day(\''+date+'\');"\
						class="timeline_day_header calendar_header_day_'+date_obj.getDay()+'" style="-moz-user-select: none;">\
							<span class="span-4 month medium_dark_gray margin-top-4px" style="margin-left:5px;">\
								'+$.days_of_week[date_obj.getDay()]+'\
							</span>\
							<span class="span-4 font11 bold_font" style="margin-left:5px;">\
								<span class="dark_gray">'+date_obj.getDate()+'</span>\
								<span class="medium_dark_gray">'+$.name_of_month[date_obj.getMonth()].substring(0,3)+'</span>\
							</span>\
						</span>';
				
				for (var i=0;i<24;i++){
					var unit_date_time = date + " "+$.add_zero(i);
					var date_time_id = date + "-"+$.add_zero(i);
					
					var selected_class = "";
					if (this.selected_time[date_time_id] == true)
						selected_class = "timeline_unit_selected"
						
					var event_str = "";
					
					if (this.disable_event == false)
					{
						event_str = ' onmousedown="$(\'#'+this.id+'\').time_selector_start_select(\''+unit_date_time+'\');"'+
						 ' onmouseup="$(\'#'+this.id+'\').time_selector_stop_select();"'+
						 ' onmouseover="$(\'#'+this.id+'\').time_selector_mouse_enter(\''+unit_date_time+'\');"'
					}
					
					var content = "x";
					
					if (i==12) content = "Noon";
					else if (i==0) content = "12am";
					else {
						content = (i%12);//+((i>12)?"pm":"am");
						
						if (i==23) content += ((i>12)?"pm":"am");
					}
					
					s += '<span id="'+this.id+'-'+date_time_id+'"" class="timeline_unit '+selected_class+'"'+
					 	 event_str +
						 '>'+content+'</span>';
				}
				
				s += '</span>'
				
				
				var cols = $(this).children('.timeline_column');
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
				
				$(this).children('.timeline_blank').hide();
				
			});
		},
		time_selector_remove_date: function(date) {
			return this.each(function() {
				var temp_obj = $('#'+this.id+'-'+date)[0];
				
				// change id
				var parent = this;
				temp_obj.id = temp_obj.id + (new Date).toUTCString();
				$(temp_obj).fadeOut(function() {
					$(this).remove();
			
					if($(parent).children('*').length <= 2)
						$(parent).children('.timeline_blank').show();
				});
				
				if (this.friend_list_panel != null)
					$(this.friend_list_panel).show_friend_time($(this).time_selector_get_selected_time());
				
				
			});
		},
		time_selector_select_whole_day: function(date){
		
			return this.each(function(){
			
				var all_day_is_selected = true;
				for (var i=0;i<24;i++)
				{
					var date_id = date+"-"+$.add_zero(i);
					if (this.selected_time[date_id] == undefined)
					{
						this.selected_time[date_id] = true;
						$('#' + this.id + '-' + date_id).addClass('timeline_unit_selected');
						all_day_is_selected = false;
					}
				}
				
				if (all_day_is_selected)
				{
					for (var i = 0; i < 24; i++) {
						var date_id = date+"-"+$.add_zero(i);
						delete this.selected_time[date_id];
						$('#' + this.id + '-' + date_id).removeClass('timeline_unit_deselected');
						$('#' + this.id + '-' + date_id).removeClass('timeline_unit_selected');
					}
				}
				
				if (this.friend_list_panel != null)
					$(this.friend_list_panel).show_friend_time($(this).time_selector_get_selected_time());
				
			});
		},
		
		time_selector_select: function(start_date_time,end_date_time){
		
			return this.each(function(){
			
				for (var i in this.current_highlight)
				{
					if (this.selected_time[i] == undefined)
					{
						this.selected_time[i] = true;
						$('#' + this.id + '-' + i).addClass('timeline_unit_selected');
					}
					else
					{
						delete this.selected_time[i];
						$('#' + this.id + '-' + i).removeClass('timeline_unit_deselected');
						$('#' + this.id + '-' + i).removeClass('timeline_unit_selected');
					}
				}
				
				if (this.friend_list_panel != null)
					$(this.friend_list_panel).show_friend_time($(this).time_selector_get_selected_time());
				
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
				
				var cols = $(this).children('.timeline_column');
				for (var i=0;i<cols.length;i++)
				{
					var col_date = cols[i].id.substring((this.id+'-').length);
					//console.info(col_date)
					if (!($.compare_date(start_date,col_date) > 0)
						&& !($.compare_date(col_date,end_date) > 0 ))
					{
						for (var j=start_time;j<=end_time;j++)
						{
							var date_time_id = col_date + "-" + $.add_zero(j);
							current_highlight[date_time_id] = true;
							
							if (this.current_highlight[date_time_id]) {
								delete this.current_highlight[date_time_id]
							}
							
							//console.info('#' + this.id + '-' + col_date + "-" + $.add_zero(j))
							if (this.selected_time[date_time_id] == true) {
								$('#' + this.id + '-' + date_time_id).removeClass('timeline_unit_selected');
								$('#' + this.id + '-' + date_time_id).addClass('timeline_unit_deselected');
							}
							else {
								$('#' + this.id + '-' + date_time_id).addClass('timeline_unit_selected');
							}
						}
					}
					
				}
				
				// delete old
				for (i in this.current_highlight)
				{
					if (this.selected_time[i] == true) {
						$('#' + this.id + '-' + i).removeClass('timeline_unit_deselected');
						$('#' + this.id + '-' + i).addClass('timeline_unit_selected');
					}
					else {
						$('#' + this.id + '-' + i).removeClass('timeline_unit_selected');
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
	
	
})(jQuery)
