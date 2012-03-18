/*
 * Ruby box javascript
 * Do whatever you want; we simply don't care.
 * But don't forget to give us some credit :P
 * 
 * -- Tanun Niyomjit (whowish.com)
 * -- Tanin Na Nakorn (whowish.com)
 */
(function($){

 	$.fn.extend({ 
 		
		// text : can be a string or an array of string.
		// If it is an array of string, it will be rendered with <ul>
 		ruby_box: function(isShown,text) {

    		return this.each(function() {
				
				if (text == "")
				{
					isShown = false;
				}
				
				if ($.isArray(text))
				{
					if (text.length == 0)
					{
						isShown = false;
					}
					else if (text.length > 1) {
						var str = "<ul>";
						
						for (var i = 0; i < text.length; i++) {
							str += "<li>" + text[i] + "</li>"
						}
						
						str += "</ul>"
						text = str;
					}
					else
					{
						text = text[0];
					}
				}
				
				if (isShown) {
					if ($("#" + this.id + "_warning").length > 0) {
						$("#" + this.id + "_warning").html(text);
						$("#" + this.id + "_warning").hide();
						$("#" + this.id + "_warning").fadeIn();
					}
					else {	
					
						if ($("#" + this.id + "_warning_wrapper").length == 0)
						{
							//$(this).parent().wrap('<span id="' + this.id + '_warning_wrapper" style="display:inline-block;"/>');
							$(this).wrap('<span id="' + this.id + '_warning_wrapper" style="display:inline-block;"/>');
						}
					
					
						$('#' + this.id + '_warning_wrapper').append(' \
							<br/>\
							<span id="' + this.id + '_warning" style="display:none;" class="triangle-border top"> \
								'+text+' \
							</span>\
						');
						
						$("#" + this.id + "_warning").hide();
						$("#" + this.id + "_warning").fadeIn();
					}
					
					//$(this).focus();
				}
				else
				{
					if ($("#" + this.id + "_warning").length > 0) {
						$("#" + this.id + "_warning").fadeOut();
					}
				}
    		});
    	}
	});
	
})(jQuery);