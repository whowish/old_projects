/**
 * @author admin
 */
(function($){

 	$.fn.extend({ 
 		
		//pass the options variable to the function
 		hover_panel: function() {
			return this.each(function() {
				
				var children = $(this).children('span');
				
				if (children.length == 1) return;
				
				$(this).mouseleave(function() {
	
					var children = $(this).children('span');
	
					$(children[1]).hide();
					$(children[0]).show();

				}).mouseenter(function() {

					var children = $(this).children('span');
					
					$(children[0]).hide();
					$(children[1]).show();
				})
				
			})
		}
		
	});
	
})(jQuery);