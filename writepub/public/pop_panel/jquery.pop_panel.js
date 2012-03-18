/**
 * @author admin
 */
(function($){

 	$.fn.extend({ 
 		
 		pop_panel: function() {
			return this.each(function() {
				
				$(this).addClass('pop_panel');
				var children = $(this).children('span');
				if (children.length == 1) return;

                $(children[1]).hide();

                var button = $(this).find('.pop_panel_button');
				$(button[0]).css('cursor','pointer');
                $(button[1]).css('cursor','pointer');

				$(button[0]).click(function() {
                    var children = $(this).parents('.pop_panel').children('span');
                    $(children[1]).show();
                    $(children[0]).hide();
					
					
					$('body').append("<div id='pop_panel_overlay' style='position:fixed;left:0px;top:0px;width:100%;height:100%;display:block;'></div>");
				
					$('#pop_panel_overlay').click(function() {
						$(button[1]).trigger('click');
					});
				});

                $(button[1]).click(function() {
                    var children = $(this).parents('.pop_panel').children('span');
                    $(children[1]).hide();
                    $(children[0]).show();
					
					$('#pop_panel_overlay').remove();
				});
				
			})
		}
		
	});
	
})(jQuery);