/**
 * @author admin
 */
(function($){

 	$.coin_balloon = function(text)
		{
				if ($('#navigator').children('.global_width').children('.coin_balloon').length == 0)
				{
					html = '<span id="coin_balloon" class="coin_ballon" style="display:none;"> \
								<span class="coin_ballon_arrow margin-left-1"> \
								</span> \
								<span class="coin_ballon_content" style="white-space:nowrap;overflow:visible;width:50px;"> \
									<span class="squeks_coin float-left"> \
									</span> \
									<span id="coin_balloon_text" class="float-left height20 margin-left-5px font12 bold_font white"> \
										'+text+' \
									</span> \
								</span> \
							</span>';
					$('#navigator').children('.global_width').append(html);
				}
				
				$('#coin_balloon_text').html(text);
				
				$('#coin_balloon').css({
										'position':'absolute',
										'z-index':900000,
										'left':"890px",
										'top':"22px"
										});
				
				$('#coin_balloon').show();
				
				setTimeout(function(){
					$('#coin_balloon').fadeOut();
				},3000);

		}
})(jQuery);

