/**
 * @author admin
 */
(function($){

 	$.fn.extend({ 
	
		turquoise:function()
		{
			return this.each(function() {
				
				var self = this;
				
				$(this).addClass('turquoise');
				$(this).hide();
				$(this).html('<span class="turquoise_holder"> \
								<span class="turquoise_x"> \
									<span>\
										ปิด\
									</span>\
								</span>\
								<span class="turquoise_border">\
									<span class="turquoise_content_container">\
										<span class="span-88 margin-top-1 margin-left-1 clearfix">\
											'+$(this).html()+'\
										</span>\
									</span>\
								</span>\
							</span>');
				
				$(this).find(".turquoise_border").css('cursor','move');
				$(this).find(".turquoise_content_container").css('cursor','default');
				
				$(this).find(".turquoise_border").mousedown(function() {
					self.turquoise_move = true;
				});
				
				$(document)
				
				$(this).find('.turquoise_x').click(function() {
					$(self).hide();
				});
			
    		});
			
		}
	});
	
})(jQuery);