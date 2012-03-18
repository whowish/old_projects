(function($){
	
	$.fn.old_val = $.fn.val;

 	$.fn.extend({ 
	
		val: function(value) {
			
			try {
				
				try {
					if (this[0].tagName.toLowerCase() != "iframe") throw "Not iframe"
				} catch (e) {
					throw "Not iframe"
				}
				
				if (value == undefined) {
					content = $(this).contents().find('body').html();
					
					if ($.trim(content) == "<br>"
						|| $.trim(content) == "<br/>"
						|| $.trim(content) == "<br />")
					{
						content = "";
					}	
					
					return content;
					
				} else {
					return $(this).contents().find('body').html(value);
				}
					
			} catch (e) {
				
				if (e != "Not iframe") throw e;
				
				if (value == undefined) {
					return $(this).old_val();
				} else {
					return $(this).old_val(value);
				}
				
			}
		},

 		writepub_editor: function(overidden_options) {
			
			//alert("MSIE = " + $.browser.msie);
			//alert("Safari = " + $.browser.safari);
			//alert("Opera = " + $.browser.opera);
			//alert("Mozilla = " + $.browser.mozilla);
			//alert("Webkit = " + $.browser.webkit);
			
			if (this[0].writepub_editor_enabled == true) return;
			if(!$.browser.msie && !$.browser.mozilla && !$.browser.webkit) return;
			
			var options = {temporary_image_path: "/temporary_file/image",
							on_leave_message:"If you leave, your content will be gone.",
							css_path:"writepub_content_editor.css"}
							
			$.extend(options,overidden_options);
			
			var id = $(this).attr("id");
			var classes = $(this).attr("class");
			var style = $(this).attr("style");
			var pre_html = $(this).val();
			
			
			
			$(this).replaceWith('<iframe id="' + id + '"></iframe>');
			
			var self = $('#'+id)[0];
			
			self.writepub_editor_enabled = true;
			self.pre_html = pre_html;
			self.options = options;
			$(self).attr("class", classes);
			$(self).attr("style", style);
			
			writepub_editor.insert_toolbar(self);
			writepub_editor.insert_expand_bar(self);
			writepub_editor.image_dialog_box.setup(self);
			writepub_editor.link_dialog_box.setup(self);
			writepub_editor.video_dialog_box.setup(self);
			
			setTimeout("writepub_editor.initialize_designmode('"+id+"');",100);
			
			/*
			$(window).bind('beforeunload', function(e){
				
				html = $.trim($('#' + id).contents().find('body').html());
				
	            if (html == "<br>" || html == ""){return;}
	
	            var e = e || window.event;
	            // for ie, ff
	            e.returnValue = self.options.on_leave_message;
	            // for webkit
	            return self.options.on_leave_message;             
	        });*/
			
			
		},
		writepub_editor_tools: function(key){
			
			if (key == 'b') writepub_editor.insert_bold(this[0]);
			else if (key =='i') writepub_editor.insert_italic(this[0]);
			
			else if (key == 'open_link') writepub_editor.link_dialog_box.open(this[0]);
			else if (key == 'link') writepub_editor.insert_link(this[0],arguments[1]);
			
			else if (key == 'open_image') writepub_editor.image_dialog_box.open(this[0]);
			else if (key == 'image') writepub_editor.insert_image(this[0],arguments[1],arguments[2]);
			
			else if (key == 'open_video') writepub_editor.video_dialog_box.open(this[0]);
			else if (key == 'video') writepub_editor.insert_video(this[0],arguments[1]);
			
			else return false; // it didn't do anything
			
			return true; // it did something
			
		}
		
	});
	
})(jQuery);

var writepub_editor = {};
writepub_editor.input = null;
writepub_editor.selection = null;

writepub_editor.initialize_designmode = function(id) {
	var self = $('#'+id)[0];

	$(self).contents()[0].designMode = "on";
	$(self)[0].contentEditable = "true";
	
	setTimeout("writepub_editor.intialize_css_and_key_event('"+id+"');",1);
}

writepub_editor.intialize_css_and_key_event = function(id) {

	var self = $('#'+id)[0];
	
	var cssLink = document.createElement("link") 
    cssLink.href = self.options.css_path; 
    cssLink.rel = "stylesheet"; 
    cssLink.type = "text/css"; 
	
	$(self).contents().find('head')[0].appendChild(cssLink);
	
	$(self).contents().keydown(function(e) {

		if (e.ctrlKey == true) {
			
			doSomething = $('#'+id).writepub_editor_tools(String.fromCharCode(e.which).toLowerCase());
			
			if (doSomething == true) {
				e.preventDefault();
			}
		}
		
    });
	
	$(self).contents().find('body').html(self.pre_html);
}

writepub_editor.insert_bold = function(self) {
	$(self).contents()[0].execCommand("bold",false,""); 
}

writepub_editor.insert_italic = function(self) {
	$(self).contents()[0].execCommand("italic",false,""); 
}

writepub_editor.insert_link = function(self, url) {
	
	if ($.trim(url).match(/^(https?|ftp)/i) == null) throw "An URL must start with 'http', 'https' or 'ftp";
	
	$(self).contents()[0].execCommand("CreateLink", false, url);
	$(self).contents().find('a[href="'+url+'"]').attr('title',url);
}

writepub_editor.insert_video = function(self, url) {
	
	if (url.match(/^(https?:\/\/)?(www.)?youtube.com\//) == null)
	{
		throw "Youtube's URL is invalid."
	}
	
	if ((result = url.match(/^(https?:\/\/)?(www.)?youtube.com\/watch\?(.*)v=([^&]+)/)) != null)
	{
		url = "http://www.youtube.com/embed/"+result[4];
	}
	
	video_html = '<iframe width="480" height="390" src="'+url+'" frameborder="0" allowfullscreen></iframe>'; 
	

	if ($.browser.msie) {
		// IE does not support InsertHTML command
		
		var i_document = $(self)[0].contentWindow.document;
		
		if (i_document.selection && i_document.selection.createRange) {
			var range = i_document.selection.createRange();
			if (range.pasteHTML) {
				range.pasteHTML(video_html);
			}
		}
	} else {
		$(self).contents()[0].execCommand("InsertHTML", false, video_html);
	}
}

writepub_editor.insert_image = function(self, url) {
	
	if ($.browser.msie) { 
		// Only IE has a problem with inserting multiple images at once (Problem with selection)
		// Therefore, we insert HTML directly
		
		var image_html = '<img src="' + url + '">'; 
		
		var i_document = $(self)[0].contentWindow.document;
		
		if (i_document.selection && i_document.selection.createRange) {
			var range = i_document.selection.createRange();
			if (range.pasteHTML) {
				range.pasteHTML(image_html);
			}
		}
	} else {
		$(self).contents()[0].execCommand("InsertImage", false, url);
	}

}

writepub_editor.show_dialog_box_overlay = function() {
	if ($('#writepub_editor_dialog_box_overlay').length == 0) {
		$("body").append('<div id="writepub_editor_dialog_box_overlay" class="writepub_editor_editor_overlay"></div>');
	}
}

writepub_editor.close_dialog_box = function(){
	$('#writepub_editor_dialog_box_overlay').hide();
	$('#writepub_editor_link_dialog_box').hide();
	$('#writepub_editor_video_dialog_box').hide();
	$('#writepub_editor_image_dialog_box').hide();
}
	
writepub_editor.insert_toolbar = function(self) {
	
	var id = self.id;
	$(self).before('<span id="'+id+'_toolbar" class="writepub_editor_toolbar">' +
						'<input type="button" unselectable="on" class="bold_button" onclick="$(\'#'+id+'\').writepub_editor_tools(\'b\');">' +
						'<input type="button" unselectable="on" class="italic_button" onclick="$(\'#'+id+'\').writepub_editor_tools(\'i\');">' +
						'<input type="button" unselectable="on" class="link_button" onclick="$(\'#'+id+'\').writepub_editor_tools(\'open_link\');">' +
						'<input type="button" unselectable="on" class="image_button" onclick="$(\'#'+id+'\').writepub_editor_tools(\'open_image\');">' +
						'<input type="button" unselectable="on" class="vdo_button" onclick="$(\'#'+id+'\').writepub_editor_tools(\'open_video\');">' +
					'</span>');
			
}

writepub_editor.insert_expand_bar = function(self) {
	
	var id = self.id;
	
	$(self).after('<span id="'+id+'_expand_bar" unselectable="on" class="writepub_editor_expand_bar" style="width:' + $(self).outerWidth() + 'px;float:' + $(self).css('float') + '">' +
						'<span unselectable="on" onmousedown="this.focus();"></span>' +
					'</span>');
					
	$(function() {
		$("#"+id+"_expand_bar").children('span').draggable({
			axis:'y',
			iframeFix: true,
			scroll:true,
			scrollSpeed:1,
			start: function(event, ui) {
				$('#'+id).css('opacity',0.4);
				
				$('#'+id)[0].save_height = $('#'+id).height();
			},
			drag: function(event, ui) { 
				//console.log(ui.position.top + " " + $('#'+id).height());
				
				var top = ui.position.top
				ui.position.top = 0;
				
				var h = $('#'+id).height();
				var new_h = $('#'+id)[0].save_height + top;
				
				if (new_h > 100) {
					$('#'+id).css('height',new_h + 'px');
				}
				
			},
			stop: function(event, ui) { 
				$('#'+id).css('opacity',1.0);
				$('#'+id).focus();
			}
			
		});
		
		disableSelection($("#"+id+"_expand_bar").children('span')[0])
		disableSelection($("#"+id+"_expand_bar")[0])
	});
	

	
			
}


function disableSelection(target){

    if (typeof target.onselectstart!="undefined") //IE route
        target.onselectstart=function(){return false}

    else if (typeof target.style.MozUserSelect!="undefined") //Firefox route
        target.style.MozUserSelect="none"

    else //All other route (ie: Opera)
        target.onmousedown=function(){return false}

}
/*
 * Link dialog box handler
 * 
 */

writepub_editor.link_dialog_box = {};
writepub_editor.link_dialog_box.open = function(input) {
	
	writepub_editor.input = input;
	
	writepub_editor.input.focus();
	writepub_editor.selection = writepub_editor.helper.save_selection(writepub_editor.input);
	writepub_editor.show_dialog_box_overlay();
	
	if ($('#writepub_editor_link_dialog_box').length == 0) {
		alert("Please define #writepub_editor_link_dialog_box");
		writepub_editor.close_dialog_box();
	}
	
	$('#writepub_editor_link_dialog_box_url').val("");
	
	$('#writepub_editor_dialog_box_overlay').show();
	$('#writepub_editor_link_dialog_box').show();
	$('#writepub_editor_link_dialog_box_url').focus();
}

writepub_editor.link_dialog_box.submit = function() {
	
	var url = $('#writepub_editor_link_dialog_box_url').val();

	writepub_editor.helper.restore_selection(writepub_editor.input, writepub_editor.selection);
	
	try {
	
		writepub_editor.insert_link(writepub_editor.input, url);
		writepub_editor.close_dialog_box();
		$('#writepub_editor_link_dialog_box_error_panel').hide();
	} catch (e) {
		$('#writepub_editor_link_dialog_box_error_panel').hide();
		$('#writepub_editor_link_dialog_box_error_panel').html(e);
		$('#writepub_editor_link_dialog_box_error_panel').fadeIn();
	}
	
	
}

writepub_editor.link_dialog_box.setup = function(self) {
	
	if ($('#writepub_editor_link_dialog_box').length > 0) return;
	
	$(self).after('<div id="writepub_editor_link_dialog_box" class="writepub_editor_link_dialog_box" style="position: fixed; width: 400px; z-index: 100001; top: 50%; left: 50%; display: block; margin-top: -75.5px; margin-left: -203px;display:none;">' +
						'<div style="display:block;">'+
							'<h1>'+
								'Link'+
							'</h1>'+
							'<span class="writepub_editor_dialog_box_row">'+
								'<p>'+
									'URL:'+
								'</p>'+				
								'<input type="text" id="writepub_editor_link_dialog_box_url" class="writepub_editor_dialog_textbox_input" placeholder="URL"/><br/>'+
							'</span>'+
							'<span id="writepub_editor_link_dialog_box_error_panel" style="margin-left:30px;" class="writepub_editor_dialog_box_row" style="display:none;">'+
							'</span>'+
							'<span class="writepub_editor_dialog_box_row">'+
								'<input type="button" class="blue_button" value="Add" onclick="writepub_editor.link_dialog_box.submit();"/>'+
								'<input type="button" class="gray_button" value="Close" onclick="writepub_editor.close_dialog_box();"/>'+
							'</span>'+
						'</div>'+
					'</div>');
	
	$('#writepub_editor_link_dialog_box_url').keyup(function(event) {
		
		if (event.which==13) writepub_editor.link_dialog_box.submit();
		
	});
			
}


/*
 * Video dialog box handler
 * 
 */
writepub_editor.video_dialog_box = {};
writepub_editor.video_dialog_box.open = function(input) {
	
	writepub_editor.input = input;
	
	writepub_editor.input.focus();
	writepub_editor.selection = writepub_editor.helper.save_selection(writepub_editor.input);
	writepub_editor.show_dialog_box_overlay();
	
	if ($('#writepub_editor_video_dialog_box').length == 0) {
		alert("Please define #writepub_editor_video_dialog_box");
		writepub_editor.close_dialog_box();
	}
	
	$('#writepub_editor_video_dialog_box_url').val("");
	
	$('#writepub_editor_dialog_box_overlay').show();
	$('#writepub_editor_video_dialog_box').show();
	$('#writepub_editor_video_dialog_box_url').focus();
}

writepub_editor.video_dialog_box.submit = function() {
	
	var url = $('#writepub_editor_video_dialog_box_url').val();
	
	writepub_editor.helper.restore_selection(writepub_editor.input, writepub_editor.selection);
	
	try {
		writepub_editor.insert_video(writepub_editor.input, url);
		writepub_editor.close_dialog_box();
		$('#writepub_editor_video_dialog_box_error_panel').hide();
	} catch (e) {
		$('#writepub_editor_video_dialog_box_error_panel').hide();
		$('#writepub_editor_video_dialog_box_error_panel').html(e);
		$('#writepub_editor_video_dialog_box_error_panel').fadeIn();
	}
	
}

writepub_editor.video_dialog_box.setup = function(self) {
	
	if ($('#writepub_editor_video_dialog_box').length > 0) return;
	
	$(self).after('<div id="writepub_editor_video_dialog_box" class="writepub_editor_video_dialog_box" style="position: fixed; width: 400px; z-index: 100001; top: 50%; left: 50%; display: block; margin-top: -75.5px; margin-left: -203px;display:none;">' +
						'<div style="display:block;">' +
							'<h1>' +
								'Youtube' +
							'</h1>' +
							'<span class="writepub_editor_dialog_box_row">' +
								'<p>' +
									'URL:' +
								'</p>' +
								'<input type="text" id="writepub_editor_video_dialog_box_url" class="writepub_editor_dialog_textbox_input" placeholder="URL Link"/><br/>' +
							'</span>' +
							'<span id="writepub_editor_video_dialog_box_error_panel" style="margin-left:30px;" class="writepub_editor_dialog_box_row" style="display:none;">'+
							'</span>'+
							'<span class="writepub_editor_dialog_box_row">' +
								'<input type="button" class="blue_button" value="Add" onclick="writepub_editor.video_dialog_box.submit();"/>' +
								'<input type="button" class="gray_button" value="Close" onclick="writepub_editor.close_dialog_box();"/>' +
							'</span>' +
						'</div>' +
					'</div>');

	$('#writepub_editor_video_dialog_box_url').keyup(function(event) {
		
		if (event.which==13) writepub_editor.video_dialog_box.submit();
		
	});

}

/*
 * Image dialog box handler
 * 
 */
writepub_editor.image_dialog_box = {};
writepub_editor.image_dialog_box.open = function(input) {
	
	writepub_editor.input = input;
	
	writepub_editor.input.focus();
	writepub_editor.selection = writepub_editor.helper.save_selection(writepub_editor.input);
	writepub_editor.show_dialog_box_overlay();
	
	if ($('#writepub_editor_image_dialog_box').length == 0) {
		alert("Please define #writepub_editor_image_dialog_box");
		writepub_editor.close_dialog_box();
	}
	
	$('#writepub_editor_image_dialog_box_url').val("");
	
	$('#writepub_editor_dialog_box_overlay').show();
	$('#writepub_editor_image_dialog_box').show();
	$('#writepub_editor_upload_button').focus();
}

writepub_editor.image_dialog_box.submit = function() {
	
	var url = $('#writepub_editor_image_dialog_box_url').val();
	
	writepub_editor.helper.restore_selection(writepub_editor.input, writepub_editor.selection);
	
	try {
		
		var spans = $('#writepub_editor_image_container').children('span');
		
		for (var i=0;i<spans.length;i++) {
			if ($(spans[i]).hasClass('selected') && $(spans[i]).find('img').length > 0) {
				url = $(spans[i]).find('img')[0].src;
				writepub_editor.insert_image(writepub_editor.input, url);
				$(spans[i]).removeClass('selected');
			}
		}
		
		
		writepub_editor.close_dialog_box();
		$('#writepub_editor_image_dialog_box_error_panel').hide();
	} catch (e) {
		$('#writepub_editor_image_dialog_box_error_panel').hide();
		$('#writepub_editor_image_dialog_box_error_panel').html(e);
		$('#writepub_editor_image_dialog_box_error_panel').fadeIn();
	}
	
}
writepub_editor.image_dialog_box.setup = function(self) {
	
	if ($('#writepub_editor_image_dialog_box').length > 0) return;
	
	$(self).after('<div id="writepub_editor_image_dialog_box" class="writepub_editor_image_dialog_box" style="position: fixed; width: 430px;height:200px; z-index: 100001; top: 50%; left: 50%; display: block; margin-top: -75.5px; margin-left: -223px;display:none;">' +
						'<div style="display:block;">' +
							'<span id="writepub_editor_image_super_container" style="width: 430px;height:170px;overflow:hidden;display:block;">' +
								'<span id="writepub_editor_image_container" style="width: 430px;height:190px;overflow:scroll;display:block;">' +
								'</span>' +
							'</span>' +
							'<span id="writepub_editor_image_dialog_box_error_panel" style="display:none;">' +
							'</span>' +
							'<span class="writepub_editor_dialog_box_row">' +
								'<input id="writepub_editor_insert_image_button" class="green_button" type="button" value="Insert selected images" onclick="writepub_editor.image_dialog_box.submit();" />' +
								'<input id="writepub_editor_upload_button" class="blue_button" type="button" value="Upload File" />' +
								'<input type="button" class="gray_button" value="Close" onclick="writepub_editor.close_dialog_box();"/>' +
							'</span>' +
						'</div>' +
					'</div>');


	$("#writepub_editor_image_container").delegate(".writepub_editor_thumbnail_unit", "click", function(){
		$(this).toggleClass("selected");
	});
	
	$("#writepub_editor_image_container").delegate(".writepub_editor_thumbnail_unit", "dblclick", function(){
		$(this).addClass("selected");
		writepub_editor.image_dialog_box.submit();
	});
	
	$('#writepub_editor_upload_button').wiky_uploader({
											action: self.options.temporary_image_path,
											mouseover_class:"button_hover",
											mousedown_class:"button_down",
											debug:false,
											params:{
												max_width:400
											},
											onSubmit: function(fileId, fileName){
												$('#writepub_editor_image_container').prepend(
													'<span class="writepub_editor_thumbnail_unit" id="writepub_editor_thumbnail_unit_'+fileId+'">' +
														'<span class="writepub_editor_thumbnail_unit_img">' +
															'<span class="writepub_editor_thumbnail_unit_img_progress"></span>'+
														'</span>'+
														'<span class="writepub_editor_thumbnail_unit_text">'+fileName+'</span>'+
													'</span>');
											},
									        onProgress: function(fileId, fileName, loaded, total){
												
												progress_span = $('#writepub_editor_thumbnail_unit_'+fileId).find('.writepub_editor_thumbnail_unit_img_progress');
												progress_span = progress_span[0];
										
											},
									        onComplete: function(fileId, fileName, responseJSON){
												$('#writepub_editor_thumbnail_unit_'+fileId).find('.writepub_editor_thumbnail_unit_img_progress').remove();
												
												$('#writepub_editor_thumbnail_unit_'+fileId).children('.writepub_editor_thumbnail_unit_img').html('<img src="'+responseJSON.filename+'"/>');
											},
									        onCancel: function(id, fileName){
												$('#writepub_editor_thumbnail_unit_'+fileId).fadeOut(function() {$(this).remove();});
											}
										});
}


/*
 * Helpers
 */
writepub_editor.helper = {}
writepub_editor.helper.save_selection = function(iframe) {
	
	var i_window = $(iframe)[0].contentWindow;
	var i_document = $(iframe)[0].contentWindow.document;
	
    if (i_window.getSelection) {
        sel = i_window.getSelection();
        if (sel.getRangeAt && sel.rangeCount) {
            var ranges = [];
            for (var i = 0, len = sel.rangeCount; i < len; ++i) {
                ranges.push(sel.getRangeAt(i));
            }
            return ranges;
        }
    } else if (i_document.selection && i_document.selection.createRange) {
        return i_document.selection.createRange();
    }
    return null;
}

writepub_editor.helper.restore_selection = function(iframe, savedSel) {
	
	var i_window = $(iframe)[0].contentWindow;
	var i_document = $(iframe)[0].contentWindow.document;

    if (savedSel) {
        if (i_window.getSelection) {
            sel = i_window.getSelection();
            sel.removeAllRanges();
            for (var i = 0, len = savedSel.length; i < len; ++i) {
                sel.addRange(savedSel[i]);
            }
        } else if (i_document.selection && savedSel.select) {
            savedSel.select();
        }
    }
}
