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
		day_selector: function(more_options) {
			
			var current_date = new Date();
			var options = {shown_date: $.get_year(current_date)+"-"+$.add_zero(current_date.getMonth()+1)+"-01",
									selected_date:[],
									time_selector_panel:null}
			
			$.extend(options,more_options);
			

			return this.each(function() {
				
				this.selected_date = {};
				this.in_the_process_of_selection = false;
				this.time_selector_panel = options.time_selector_panel;
				
				for (var i=0;i<options.selected_date.length;i++)
					this.selected_date[options.selected_date[i]] = true;
				
				$(this).addClass('calendar');
				
				var prev_month_code = $.adjust_month(options.shown_date,-1);
				var next_month_code = $.adjust_month(options.shown_date,+1);

				var s = '<span class="span-35 margin-top-1 clearfix">\
							<a href="#" class="calendar_previous_button float-left" onclick="$(\'#'+this.id+'\').day_selector_prev();return false;">\
							</a>\
							<span class="span-31 calendar_header">\
								<span class="calendar_month_label">\
									Febuary\
								</span> \
								<span class="calendar_year_label">\
									2011\
								</span>\
							</span>\
							<a href="#" class=" calendar_next_button float-left" onclick="$(\'#'+this.id+'\').day_selector_next();return false;">\
							</a>\
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
				
				s += '<span class="calendar_month_container span-35"></span>'
				
				
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
				
				$(this).day_selector_go_to(options.shown_date);
			});
		},
		
		day_selector_prev: function() {
			
			return this.each(function() {
				$(this).day_selector_go_to($.adjust_month(this.shown_date,-1));
			});
		},
		
		day_selector_next: function() {
			
			return this.each(function() {
				$(this).day_selector_go_to($.adjust_month(this.shown_date,+1));
			});
		},
		
		day_selector_go_to: function(cur_date) {
			
			return this.each(function() {
				
				var today = new Date();
				var today_month = $.get_year(today)+"-"+$.add_zero(today.getMonth()+1);
				today = $.get_year(today)+"-"+$.add_zero(today.getMonth()+1)+"-"+$.add_zero(today.getDate());
				
				
				this.shown_date = cur_date;
				
				$(this).mouseleave(function(){
					$(this).day_selector_stop_select();
				})
				//console.info(cur_date)
				cur_date = $.parse_date(cur_date);
				
				//console.info(cur_date.getMonth())
				$(this).find(".calendar_year_label").html($.get_year(cur_date));
				$(this).find(".calendar_month_label").html($.name_of_month[cur_date.getMonth()]);
				
				start_date = new Date($.get_year(cur_date), cur_date.getMonth(), 1);
				//console.info(start_date.getDay()+" "+start_date.getYear()+" "+start_date.getMonth()+" "+start_date.getDate()+" "+this.shown_date);
				
				var end_last_month = $.number_of_days($.get_year(start_date),start_date.getMonth()-1);
				//console.info("end_last_month="+end_last_month)
				var start_last_month = (end_last_month - start_date.getDay())+1;
				
				var end_current_month = $.number_of_days($.get_year(start_date),start_date.getMonth());
				
				end_date = new Date($.get_year(cur_date), cur_date.getMonth(), end_current_month);
				var end_next_month = 6-end_date.getDay();
				
				var run_day_of_week = 0;
				
				var next_month_code = $.adjust_month(this.shown_date,+1).substring(0,7);
				var cur_month_code = this.shown_date.substring(0,7);
				var prev_month_code = $.adjust_month(this.shown_date,-1).substring(0,7);
				
				if (prev_month_code < today_month) {
					$(this).find('.calendar_previous_button').css({'visibility':'hidden'});
				} else {
					$(this).find('.calendar_previous_button').css({'visibility':'visible'});
				}
				
				var s = '';
				
				// generate last month
				for (var i=start_last_month;i<=end_last_month;i++)
				{
					var date = prev_month_code+'-'+$.add_zero(i);
					var selected_class = (this.selected_date[date])? "calendar_day_selected":"";
				
					var event = ' onmousedown="$(\'#'+this.id+'\').day_selector_start_select(\''+date+'\');"'+
								 ' onmouseup="$(\'#'+this.id+'\').day_selector_stop_select();"'+
								 ' onmouseover="$(\'#'+this.id+'\').day_selector_mouse_enter(\''+date+'\');"';
				
					var append_class = "";
					if (date < today && !this.selected_date[date])
					{
						append_class = "_disabled"
						event = "";
					}

					s += '<span id="'+this.id+date+'" class="'+selected_class+' calendar_other_month_day calendar_unit'+append_class+' calendar_day_'+((run_day_of_week++)%7)+'"' +
						 event +
						 '>'+i+'<span class="calendar_unit_padding"></span></span>'
				}
				
				// generate current month
				for (var i=1;i<=end_current_month;i++)
				{
					var date = cur_month_code+'-'+$.add_zero(i);
					var selected_class = (this.selected_date[date])? "calendar_day_selected":"";
					
					var append_class = "";
					
					var event = ' onmousedown="$(\'#'+this.id+'\').day_selector_start_select(\''+date+'\');"'+
								 ' onmouseup="$(\'#'+this.id+'\').day_selector_stop_select();"'+
								 ' onmouseover="$(\'#'+this.id+'\').day_selector_mouse_enter(\''+date+'\');"';
					
					if (date < today && !this.selected_date[date])
					{
						append_class = "_disabled"
						event = "";
					}

					s += '<span id="'+this.id+date+'" class="'+selected_class+' calendar_current_month_day calendar_unit'+append_class+' calendar_day_'+((run_day_of_week++)%7)+'"' +
						 event+
						'>'+i+'<span class="calendar_unit_padding"></span></span>'
				}
		
				// generate next month
				for (var i=1;i<=end_next_month;i++)
				{
					var date = next_month_code+'-'+$.add_zero(i);
					var selected_class = (this.selected_date[date])? "calendar_day_selected":"";
					
					var event = ' onmousedown="$(\'#'+this.id+'\').day_selector_start_select(\''+date+'\');"'+
								 ' onmouseup="$(\'#'+this.id+'\').day_selector_stop_select();"'+
								 ' onmouseover="$(\'#'+this.id+'\').day_selector_mouse_enter(\''+date+'\');"';
					
					var append_class = "";
					if (date < today && !this.selected_date[date])
					{
						append_class = "_disabled"
						event = "";
					}
					
					s += '<span id="'+this.id+date+'" class="'+selected_class+' calendar_other_month_day calendar_unit'+append_class+' calendar_day_'+((run_day_of_week++)%7)+'"' +
						 event+
						'>'+i+'<span class="calendar_unit_padding"></span></span>'
				}
				
				var body = $(this).find('.calendar_month_container');
				$(body).html(s);
				
				var children = $(body).find("*");
				for (var i=0;i<children.length;i++)
				{
					$.disable_selection(children[i]);
				}
			});
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