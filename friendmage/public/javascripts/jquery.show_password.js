/**
 * @author Tanin
 */
(function($){

 	$.fn.extend({ 
 		
 		show_password: function(options) {

    		return this.each(function() {
				
				$(options.button).attr({"disabled":"disabled"});
				
				var parent = $(this).parent();	
				
				var text = $(this).val();
				var inner_html = $(this).parent().html();
				
				inner_html = inner_html.replace('type="password"','type="text"');
				inner_html = inner_html.replace("type='password'","type='text'");
	
				$(parent).html(inner_html);
				$(parent).children("input").val(text);
				
				if (options.button)
				{
					var input_text_field = $(parent).children("input")[0];
					var button_2 = options.button;
					var hide_text = options.hide_text;
					var show_text = options.show_text;
					
					var waitSecond = options.seconds;
					$(button_2).attr({"value":hide_text + " .. " + waitSecond});
					waitSecond--;
					
					var countDown = function(){
						if (waitSecond == 0)
						{
							$(input_text_field).mask_password({show_text:show_text,button:button_2})
						}
						else
						{
							$(button_2).attr({"value":hide_text + " .. " + waitSecond});
							waitSecond--;
							window.setTimeout(countDown, 1000);
						}
					};
						
					window.setTimeout(countDown, 1000);
	
				}
    		});
    	},
		
		mask_password : function(options) {
			var parent = $(this).parent();	
			
			var text = $(this).val();
			var inner_html = $(this).parent().html();
			
			inner_html = inner_html.replace('type="text"','type="password"');
			inner_html = inner_html.replace("type='text'","type='password'");

			$(parent).html(inner_html);
			$(parent).children("input").val(text);
			$(options.button).attr({"value":options.show_text});
			
			$(options.button).attr({"disabled":""});
		}
	});
	
})(jQuery);