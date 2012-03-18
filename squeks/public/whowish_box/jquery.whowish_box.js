whowish_box_stack_options = [];
		
(function($){

 	$.extend({ 

		whowish_box_title_color: function(bg_color)
		{
			if (whowish_box_stack_options.length == 0) return;
			
			
			whowish_box_stack_options[whowish_box_stack_options.length-1].background_color = bg_color;
			$('#whowish_box_title').css('background-color',bg_color);
		},
		
		whowish_box_title_text: function(text,options)
		{
			if (whowish_box_stack_options.length == 0) return;
			
			if (options == undefined) {
				$('#whowish_box .whowish_box_name').html(text);
			} else {
				$('#whowish_box .whowish_box_name').html('\
					<span style="position:relative;">\
					<span class="'+options.whowish_word_class+'">'+text+'</span>\
					'+options.edit+'\
					</span>\
				');
			}
		},

		//pass the options variable to the function
 		whowish_box: function(new_options){
			
			options = {background_color:'#78BD40'}
			$.extend(options,new_options);
			
			// ensure IE works
			options.background_color = $.trim(options.background_color)
			
			whowish_box_stack_options.push(options);
			
			if ($('#whowish_box').length == 0) {
				
				$("body").append(' \
					<div class="whowish_box" id="whowish_box"> \
						<a name="whowish_box" style="margin-top:-100px;"></a> \
						<div class="whowish_box_container"> \
							<div id="whowish_box_title" class="whowish_box_headline"> \
								<span class="whowish_box_name">Unknown</span> \
								<span class="whowish_box_close_button"></span> \
								<span class="whowish_box_back_button"> \
									<span class="whowish_box_back_icon"></span> \
									<span class="whowish_box_back_text">Back</span> \
								</span> \
							</div> \
							<div class="whowish_box_content"> \
								\
							</div> \
							<div style="height:0px;clear:left;">&nbsp;</div> \
							<div id="whowish_box_loading" style="display:block;text-align:center;height:110px;"> \
								<div style="margin: 5px 5px 5px 5px;margin-left:auto;margin-right:auto;"> \
									<img src="/whowish_box/loading.gif"> \
								</div> \
							</div> \
						</div> \
						<div style="height:0px;clear:left;">&nbsp;</div>\
					</div> \
				');
				
//				if ($('#whowish_box_overlay').length == 0) {
//					$("body").append('<div id="whowish_box_overlay" class="whowish_box_overlay_hide"></div>')
//				}
				
				$('#whowish_box .whowish_box_close_button').click(function() { $(document).trigger('close.whowish_box') })
				$('#whowish_box .whowish_box_back_button').click(function() { $(document).trigger('back.whowish_box') })
				//$('#whowish_box_overlay').click(function() { $(document).trigger('close.whowish_box') })

			}
			
			if (whowish_box_stack_options.length <= 1)
			{
				$('#whowish_box .whowish_box_back_button').hide();
			}
			else
			{
				$('#whowish_box .whowish_box_back_button').show();
			}
			
			$('#whowish_box_title').css('background-color',options.background_color);
			//$('#whowish_box_title').css('background-color','#CCCCCC');

			$('#whowish_box .whowish_box_name').html('&nbsp;');
			
			$.whowish_box_load();
			
			var scrolls = $.get_page_scroll();
			$('#whowish_box').css({
				"top":(scrolls[1]+100)+"px",
				"left":(($(window).width()-$('#whowish_box').width())/2)+"px"
			});
			
			$('#whowish_box').fadeIn('fast',function() {
				//$('#whowish_box_overlay').addClass('whowish_box_overlay_show');
				//location.href = '#whowish_box';
				
				$.get(options.url,{is_whowish_box:"true"}, function(data) {
				
					if (options.url != whowish_box_stack_options[whowish_box_stack_options.length-1].url) return;
					
				  $('#whowish_box .whowish_box_content').html(data +
				  	'	<script language="javascript"> \
							$("#whowish_box .whowish_box_content").show(); \
							$("#whowish_box #whowish_box_loading").hide();\
						</script>\
					');	
					$('#whowish_box').css({'width':'522px'});
				  
				  	var scrolls = $.get_page_scroll();
					$('#whowish_box').css({
						"top":(100+scrolls[1])+"px",
						"left":(($(window).width()-$('#whowish_box').width())/2)+"px"
					});
					
//					try {
//						FB.Canvas.setAutoResize();
//					} catch (e) {}
					
					
				});
			});
			
			
			

		},
		
		whowish_box_load: function() {
			$('#whowish_box').css('width','522px');
			$('#whowish_box .whowish_box_content').hide();
			$('#whowish_box #whowish_box_loading').show();
			
		},
		
		get_page_scroll: function() {
			
		    var xScroll, yScroll;
		    if (self.pageYOffset) {
		      yScroll = self.pageYOffset;
		      xScroll = self.pageXOffset;
		    } else if (document.documentElement && document.documentElement.scrollTop) {	 // Explorer 6 Strict
		      yScroll = document.documentElement.scrollTop;
		      xScroll = document.documentElement.scrollLeft;
		    } else if (document.body) {// all other Explorers
		      yScroll = document.body.scrollTop;
		      xScroll = document.body.scrollLeft;
		    }
		    return new Array(xScroll,yScroll)
		}
	});
	
	  $(document).bind('close.whowish_box', function() {
	  	whowish_box_stack_options = []
		$('#whowish_box').fadeOut('fast',function () {
			$('#whowish_box .whowish_box_content').html('');
			//$('#whowish_box_overlay').removeClass('whowish_box_overlay_show');
			
			try {
				FB.Canvas.setAutoResize();
			} catch (e) {}
		});
	  })
	  
	  $(document).bind('back.whowish_box', function() {
	  	whowish_box_stack_options.pop();
		$.whowish_box(whowish_box_stack_options.pop());
	  })
	
})(jQuery);
