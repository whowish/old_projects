(function($){

 	$.fn.extend({ 
 		
		// text : can be a string or an array of string.
		// If it is an array of string, it will be rendered with <ul>
 		jade_tooltip: function(text) {

    		return this.each(function() {

				var height = $(this).height();
				var width = $(this).width();
				
				
				
				if ($('.jade_tooltip', this).length == 0) {
				
					$(this).append(' \
						<div class="jade_tooltip dark_gray" style="left:' + (width*3/4) + 'px;bottom:'+(height/2)+'px;"> \
							<span class="jade_tolltip_content"> \
								' +text +' \
							</span> \
						    <span class="jade_tooltip_buttom"></span> \
						</div> \
					');
					
					$(this).bind('mouseleave',function() {
						$('.jade_tooltip', this).hide();
					});
				}
				else
				{
					$('.jade_tolltip_content', this).html(text);
					$('.jade_tooltip', this).css({left: (width*3/4)+"px",bottom: (height/2)+"px"});
					$('.jade_tooltip', this).show();
				}
    		});
    	}
	});
	
})(jQuery);