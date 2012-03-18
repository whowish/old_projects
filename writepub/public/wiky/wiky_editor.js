/**
 * @author Tanin
 */
(function($){

 	$.fn.extend({ 

 		wiky_editor: function(options) {
			
			if (options == undefined) options = {};

			this[0].options = {default_bold_text:"Bold text",
							default_italic_text:"Italic text",
							default_heading_text:"Heading",
							preview_panel:null,
							preview_timeout:1000}
							
			$.extend(this[0].options,options);
			
			var obj = this[0];
			if (obj.wiky_editor == undefined) {
				$(obj).wiky_base_editor({'b':wiky_helper.insert_bold, 'i':wiky_helper.insert_italic, 'h':wiky_helper.insert_heading});
			}
			
			// preview on-the-fly
			if (this[0].options.preview_panel != null) {
				this[0].preview_id = 0;
				
				$(this[0]).keyup(function() {
					this.preview_id++;
					
					var obj = this;
					var this_preview_id = obj.preview_id;
					setTimeout(function() { obj.update_view(this_preview_id); },obj.options.preview_timeout);
				});
				
			}
			
			this[0].update_view = function(preview_id) {
				if (preview_id != undefined && preview_id != this.preview_id) return;
				
				$(this.options.preview_panel).html(wiky.process($(this).val()));
			}
			
			this[0].update_view();
			
			// IE does not save cursor position, after blurring. Therefore, we save it for them;
			obj.save_selection_position = {start:0,end:0};
			$(obj).mouseup(function(){
				this.save_selection_position = wiky_helper.get_selection(this);
			});
			
			$("#wiky_image_container").delegate(".wiky_thumbnail_unit", "click", function(){
				$(this).toggleClass("selected");
			});
			
			$('#wiky_upload_button').wiky_uploader({
													action:'/temporary_file/image',
													mouseover_class:"button_hover",
													mousedown_class:"button_down",
													debug:false,
													params:{
														max_width:400
													},
													onSubmit: function(fileId, fileName){
														$('#wiky_image_container').prepend('\
															<span class="wiky_thumbnail_unit" id="wiky_thumbnail_unit_'+fileId+'">\
																<span class="wiky_thumbnail_unit_img">\
																	<span class="wiky_thumbnail_unit_img_progress"></span>\
																</span>\
																<span class="wiky_thumbnail_unit_text">'+fileName+'</span>\
															</span>\
														');
													},
											        onProgress: function(fileId, fileName, loaded, total){
														
														progress_span = $('#wiky_thumbnail_unit_'+fileId).find('.wiky_thumbnail_unit_img_progress');
														progress_span = progress_span[0];
												
													},
											        onComplete: function(fileId, fileName, responseJSON){
														$('#wiky_thumbnail_unit_'+fileId).find('.wiky_thumbnail_unit_img_progress').remove();
														
														$('#wiky_thumbnail_unit_'+fileId).children('.wiky_thumbnail_unit_img').html('<img src="'+responseJSON.filename+'"/>');
													},
											        onCancel: function(id, fileName){
														$('#wiky_thumbnail_unit_'+fileId).fadeOut(function() {$(this).remove();});
													}
												});
			
		
		},
		wiky_editor_tools: function(key) {
			this[0].wiky_editor.save_history({which:key},true);
			
			
			if (key == 'b') wiky_helper.insert_bold(this[0]);
			else if (key =='i') wiky_helper.insert_italic(this[0]);
			else if (key =='h') wiky_helper.insert_heading(this[0]);
			else if (key == 'open_link') {
				$.wiky_editor_link_dialog_box(this);
			}
			else if (key == 'link') {
				wiky_helper.insert_link(this[0],arguments[1],arguments[2]);
			}
			else if (key == 'open_image') {
				$.wiky_editor_image_dialog_box(this);
			}
			else if (key == 'image') {
				wiky_helper.insert_image(this[0],arguments[1],arguments[2]);
			}
			else if (key == 'open_video') {
				$.wiky_editor_video_dialog_box(this);
			}
			else if (key == 'video') {
				wiky_helper.insert_video(this[0],arguments[1]);
			}
		}
	});
	
	$.wiky_editor_open_overlay = function() {
		if ($('#wiky_dialog_box_overlay').length == 0) {
			$("body").append('<div id="wiky_dialog_box_overlay" class="wiky_editor_overlay"></div>');
		}
		     

	}
	
	$.wiky_editor_link_dialog_box = function(input) {
		$.wiky_editor_instance = input;
		
		$.wiky_editor_open_overlay();
		
		if ($('#wiky_link_dialog_box').length == 0) {
			alert("Please define #wiky_link_dialog_box");
		}
		
		$('#wiky_link_dialog_box_url').val("");
		$('#wiky_link_dialog_box_name').val("");
		
		$('#wiky_dialog_box_overlay').show();
		$('#wiky_link_dialog_box').show();
	}
	
	$.wiky_editor_link_dialog_box_insert_link = function() {
		$($.wiky_editor_instance).wiky_editor_tools('link',$('#wiky_link_dialog_box_url').val(),$('#wiky_link_dialog_box_name').val());
		$.wiky_editor_close_dialog_box();
	}
	
	$.wiky_editor_close_dialog_box = function(){
		$('#wiky_dialog_box_overlay').hide();
		$('#wiky_link_dialog_box').hide();
		$('#wiky_video_dialog_box').hide();
		$('#wiky_image_dialog_box').hide();
	}
	
	$.wiky_editor_video_dialog_box = function(input) {
		$.wiky_editor_instance = input;
		
		$.wiky_editor_open_overlay();
		
		if ($('#wiky_video_dialog_box').length == 0) {
			alert("Please define #wiky_video_dialog_box");
		}
		
		$('#wiky_video_dialog_box_url').val("");
		
		$('#wiky_dialog_box_overlay').show();
		$('#wiky_video_dialog_box').show();
	}
	
	$.wiky_editor_video_dialog_box_insert_video = function() {
		$($.wiky_editor_instance).wiky_editor_tools('video',$('#wiky_video_dialog_box_url').val());
		$.wiky_editor_close_dialog_box();
	}
	
	$.wiky_editor_image_dialog_box = function(input) {
		$.wiky_editor_instance = input;
		
		$.wiky_editor_open_overlay();
		
		if ($('#wiky_image_dialog_box').length == 0) {
			alert("Please define #wiky_image_dialog_box");
		}
		
		$('#wiky_dialog_box_overlay').show();
		$('#wiky_image_dialog_box').show();
	}
	
	$.wiky_editor_image_dialog_box_insert_image = function(url,alt) {
		
		var spans = $('#wiky_image_container').children('span');
		
		for (var i=0;i<spans.length;i++) {
			if ($(spans[i]).hasClass('selected') && $(spans[i]).find('img').length > 0) {
				url = $(spans[i]).find('img')[0].src;
				$($.wiky_editor_instance).wiky_editor_tools('image',url);
				$(spans[i]).removeClass('selected');
			}
		}
		
		$.wiky_editor_close_dialog_box();
	}
	
})(jQuery);

wiky_helper = {}

wiky_helper.insert_image = function(input,url,alt) {
	if (url == undefined || url == "") return;
	if (alt == undefined) alt = "";
	
	var pos = wiky_helper.get_selection(input);
	
	
	var s = input.value;
	var inside = "";
	
	if (alt != "")
		inside = "[[File:"+url+" "+alt+"]]";
	else
		inside = "[[File:"+url+"]]";
		
	prefix = s.substring(0,pos.end).replace(/\r?\n$/,"");
	suffix = s.substring(pos.end).replace(/^\r?\n/,"");
		
	input.value =  prefix + "\n" + inside + "\n" + suffix;
	
	input.update_view();
	wiky_helper.set_selection(input,prefix.length + 1 + inside.length+1,prefix.length + 1 + inside.length+1);
	
}

wiky_helper.insert_link = function(input,url,name) {
	if (url == undefined || url == "") return;
	
	var pos = wiky_helper.get_selection(input);
	
	
	var s = input.value;
	inside = ""
	
	if (name != "")
		inside = "["+url+" "+name+"]";
	else
		inside = "["+url+"]";
	
	
	prefix = s.substring(0,pos.end);
	suffix = s.substring(pos.end);
	input.value = prefix + "" + inside + "" + suffix;
	
	
	input.update_view();
	wiky_helper.set_selection(input,pos.end + inside.length,pos.end + inside.length);
	
}

wiky_helper.insert_video = function(input,url) {
	if (url == undefined || url == "") return;
	
	var pos = wiky_helper.get_selection(input);
	
	var s = input.value;
	prefix = s.substring(0,pos.end).replace(/\r?\n$/,"");
	suffix = s.substring(pos.end).replace(/^\r?\n/,"");
	inside =  "[[Video:"+url+"]]";
		
	input.value = prefix + "\n" + inside + "\n" + suffix;
	
	input.update_view();
	
	wiky_helper.set_selection(input,prefix.length + 1 + inside.length+1,prefix.length + 1 + inside.length+1);
	
}

wiky_helper.insert_bold = function(input,key) {
	if (key != undefined && key != 66) return false;
	
	var count_sym = wiky_helper.count_wrapper(input,"'",3);
	
	if (count_sym.left >= 3 && count_sym.right >= 3) {
		wiky_helper.unwrap(input, count_sym.pos.start, count_sym.pos.end, "'''", input.options.default_bold_text);
	}
	else {
		
		var pos = wiky_helper.identify_whole_word(input);
		wiky_helper.wrap(input, pos.start, pos.end, "'''", input.options.default_bold_text);
	}
	
	
	return true;
}

wiky_helper.insert_italic = function(input,key) {
	if (key != undefined && key != 73) return false;
	
	var count_sym = wiky_helper.count_wrapper(input,"'",2);
	
	if (count_sym.left >= 2 && 
		count_sym.right >= 2 &&
		count_sym.left != 3 &&
		count_sym.right != 3) {
	
		wiky_helper.unwrap(input, count_sym.pos.start, count_sym.pos.end, "''", input.options.default_italic_text);
		
	} else {
	
		var pos = wiky_helper.identify_whole_word(input);
		wiky_helper.wrap(input, pos.start, pos.end, "''", input.options.default_italic_text);
	}
	
	
	return true;
}

wiky_helper.insert_heading = function(input,key) {
	if (key != undefined && key != 72) return false;
	
	var count_sym = wiky_helper.count_beginning_and_end(input,"=");
	
	if (count_sym.left >= 3 && count_sym.right >= 3) {
		wiky_helper.unwrap(input, count_sym.pos.start, count_sym.pos.end, "=", input.options.default_heading_text);
	}
	else if (count_sym.left >= 2 && count_sym.right >= 2) {
		wiky_helper.unwrap(input, count_sym.pos.start, count_sym.pos.end, "==", input.options.default_heading_text);
	} else {
	
		var pos = wiky_helper.identify_whole_line(input);
		wiky_helper.wrap(input, pos.start, pos.end, "===", input.options.default_heading_text);
	}
	
	return true;
}

wiky_helper.wrap = function(input, pos_start, pos_end, symbols, default_text){
	var s = input.value;
	
	if (pos_end > pos_start) {
		s = s.substring(0, pos_start) + ""+symbols+"" + s.substring(pos_start, pos_end) + ""+symbols+"" + s.substring(pos_end);
	}
	else {
		s = s.substring(0, pos_start) + ""+symbols+"" + default_text + ""+symbols+"" + s.substring(pos_end);
		pos_end = pos_start + default_text.length;
	}
	
	input.value = s;
	
	input.update_view();
	
	wiky_helper.set_selection(input, pos_start + symbols.length, pos_end + symbols.length);
}

wiky_helper.unwrap = function(input, pos_start, pos_end, symbols, default_text){
	var s = input.value;
	
	s = s.substring(0, pos_start - symbols.length) + s.substring(pos_start, pos_end) + s.substring(pos_end + symbols.length);
	
	input.value = s;
	
	input.update_view();
	
	wiky_helper.set_selection(input, pos_start - symbols.length, pos_end - symbols.length);
}

wiky_helper.count_beginning_and_end = function(input,sym) {
	
	var result = {left:0,right:0,pos: {start:0,end:0}};
	var s = input.value;
	
	var pos = wiky_helper.get_selection(input);
	
	{
		var count_single_quote = 0;
		var tmp_pos_start = pos.start-1;
		while (tmp_pos_start >= 0) {
			if (s.charAt(tmp_pos_start) == sym) {
				count_single_quote++;
			}
			else {
				if (s.charAt(tmp_pos_start) == "\n" || s.charAt(tmp_pos_start) == "\r") {
					break;
				}
				else {
					count_single_quote = 0;
				}
			}
			
			tmp_pos_start--;
		}
		
		result.left = count_single_quote;
		result.pos.start = tmp_pos_start + count_single_quote+1;
	}
	
	{
		var count_single_quote = 0;
		var tmp_pos_end = pos.end;
		while (tmp_pos_end < s.length) {
			if (s.charAt(tmp_pos_end) == sym) {
				count_single_quote++;
			}
			else 
				if (s.charAt(tmp_pos_end) == "\n" || s.charAt(tmp_pos_end) == "\r") {
					break;
				}
				else {
					count_single_quote = 0;
				}
			

			tmp_pos_end++;
		}
		
		result.right = count_single_quote;
		result.pos.end = tmp_pos_end - count_single_quote;
	}
	
	return result;
}

wiky_helper.count_wrapper = function(input,sym,min) {
	
	var result = {left:0,right:0,pos: {start:0,end:0}};
	var s = input.value;
	
	var pos = wiky_helper.get_selection(input);
	
	{
		var count_single_quote = 0;
		var tmp_pos_start = pos.start-1;
		while (tmp_pos_start >= 0) {
			if (s.charAt(tmp_pos_start) == sym) {
				count_single_quote++;
			}
			else {
				if (s.charAt(tmp_pos_start) == "\n" || s.charAt(tmp_pos_start) == "\r") {
					break;
				}
				else {
					if (count_single_quote >= min) {
						break;
					} else {
						count_single_quote = 0;
					}
					
				}
			}
			
			tmp_pos_start--;
		}
		
		result.left = count_single_quote;
		result.pos.start = tmp_pos_start + count_single_quote+1;
	}
	
	{
		var count_single_quote = 0;
		var tmp_pos_end = pos.end;
		while (tmp_pos_end < s.length) {
			if (s.charAt(tmp_pos_end) == sym) {
				count_single_quote++;
			}
			else 
				if (s.charAt(tmp_pos_end) == "\n" || s.charAt(tmp_pos_end) == "\r") {
					break;
				}
				else {
					if (count_single_quote >= min) {
						break;
					} else {
						count_single_quote = 0;
					}
				}
			

			tmp_pos_end++;
		}
		
		result.right = count_single_quote;
		result.pos.end = tmp_pos_end - count_single_quote;
	}
	
	return result;
}

wiky_helper.identify_whole_line = function(input) {
	
	var s = input.value;
	var pos = wiky_helper.get_selection(input);
	
	// identify the whole line
	while (pos.start >= 0 && s.charAt(pos.start) != '\n' && s.charAt(pos.start) != '\r') pos.start--;
	pos.start++;
	
	while (pos.end < s.length && s.charAt(pos.end) != '\n' && s.charAt(pos.end) != '\r') pos.end++;

	return pos;
}

wiky_helper.identify_whole_word = function(input) {
	
	var s = input.value;
	var pos = wiky_helper.get_selection(input);
	// if it does not select anything, we select the current word automatically
	if (pos.end == pos.start) {
		while (pos.start >= 0 && s.charAt(pos.start) != ' ' && s.charAt(pos.start) != '\n' && s.charAt(pos.start) != '\r') pos.start--;
		pos.start++;
		
		while (pos.end < s.length && s.charAt(pos.end) != ' ' && s.charAt(pos.end) != '\n' && s.charAt(pos.end) != '\r') pos.end++;
	}
	
	return pos;
}


wiky_helper.set_selection = function(e,start_pos,end_pos) {

    //Mozilla and DOM 3.0
    if('selectionStart' in e)
    {
        e.focus();
        e.selectionStart = start_pos;
        e.selectionEnd = end_pos;
    }
    //IE
    else if(document.selection)
    {
        e.focus();
        var tr = e.createTextRange();

        //Fix IE from counting the newline characters as two seperate characters
        var stop_it = start_pos;
        for (i=0; i < stop_it; i++) if( e.value[i].search(/[\r\n]/) != -1 ) start_pos = start_pos - .5;
        stop_it = end_pos;
        for (i=0; i < stop_it; i++) if( e.value[i].search(/[\r\n]/) != -1 ) end_pos = end_pos - .5;

        tr.moveEnd('textedit',-1);
        tr.moveStart('character',start_pos);
        tr.moveEnd('character',end_pos - start_pos);
        tr.select();
    }
}

wiky_helper.get_selection = function(el) {
    var start = 0, end = 0, normalizedValue, range,
    textInputRange, len, endRange;

    if (typeof el.selectionStart == "number" && typeof el.selectionEnd == "number") {
        start = el.selectionStart;
        end = el.selectionEnd;
    } else {
        range = document.selection.createRange();

        if (range && range.parentElement() == el) {
            len = el.value.length;
            normalizedValue = el.value.replace(/\r\n/g, "\n");

            // Create a working TextRange that lives only in the input
            textInputRange = el.createTextRange();
            textInputRange.moveToBookmark(range.getBookmark());

            // Check if the start and end of the selection are at the very end
            // of the input, since moveStart/moveEnd doesn't return what we want
            // in those cases
            endRange = el.createTextRange();
            endRange.collapse(false);

            if (textInputRange.compareEndPoints("StartToEnd", endRange) > -1) {
                start = end = len;
            } else {
                start = -textInputRange.moveStart("character", -len);
                start += normalizedValue.slice(0, start).split("\n").length - 1;

                if (textInputRange.compareEndPoints("EndToEnd", endRange) > -1) {
                    end = len;
                } else {
                    end = -textInputRange.moveEnd("character", -len);
                    end += normalizedValue.slice(0, end).split("\n").length - 1;
                }
            }
        } else {
			return el.save_selection_position;
		}
    }

    return {
        start: start,
        end: end
    };

}
