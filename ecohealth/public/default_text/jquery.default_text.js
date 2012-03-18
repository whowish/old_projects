/*
 *  Do whatever you want with it. I don't care
 *  But don't fotget to give me some credit :P
 *  - Tanin Na Nakorn (whowish.com)
 * 
 */
(function($){

 	$.fn.extend({ 
 		
		//pass the options variable to the function
 		default_text: function(msg,auto_select) {
			return this.each(function() {
				var real_obj = this;
				
				
				if ($("#_default_text_" + $(this)[0].id + "_default_text").length == 0) {
					default_obj = $(this).clone();
					$(default_obj).insertBefore(this)
					$(default_obj).addClass('jquery_default_text')
								.attr('id', "_default_text_" + $(this)[0].id + "_default_text")
								.attr('name', "_default_text_" + $(this)[0].id + "_default_text")
								.attr('onkeyup', "")
								.attr('click', "")
					$(default_obj).die();
				}
				
				var default_obj = $("#_default_text_" + $(this)[0].id + "_default_text")[0];
				$(default_obj).val(msg)
				
				if (auto_select == true) {
					$(real_obj).focus(function(){
						$(real_obj)[0].select();
					})
				}
				
				if ($(real_obj).val() == "") {
					$(real_obj).hide();
					$(default_obj).show();
				}
				else
				{
					$(real_obj).show();
					$(default_obj).hide();
				}
				
				$(default_obj).focus(function()
			    {
			        $(default_obj).hide();
					$(real_obj).show();
					$(real_obj).focus();
			    });
				
				$(real_obj).blur(function()
			    {
			        if ($(real_obj).val() == "")
			        {
			            $(default_obj).show();
						$(real_obj).hide();
			        }
			    });


			});
		}
		
	});
	
})(jQuery);