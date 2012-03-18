/*
 *  Do whatever you want with it. I don't care
 *  But don't fotget to give us some credit. (Apache License)
 *  - Tanin Na Nakorn
 *  - Sergiu Rata
 */
(function($){
    $.fn.extend({         
        //pass the options variable to the function
        default_text: function(msg, opts) {
			
			if (opts == undefined) { opts = {}; }
			
            var defaultTextClassName = opts.defaultClass != null ? opts.defaultClass : "jquery_default_text";
            var defaultIdSuffix = opts.defaultIdSuffix != null ? opts.defaultIdSuffix : "_default_text";

            return this.each(function() {
                var real_obj = this;
				var default_obj = null;
				
				if ($('#' + $(this)[0].id + defaultIdSuffix).length == 0) {
					default_obj = $(this).clone();
					$(default_obj).css('display',$(real_obj).css('display'));
					$(default_obj).attr('name',$(real_obj).attr('name')+defaultIdSuffix);
					$(default_obj).hide();
					
					$(default_obj).insertBefore(this);
					$(default_obj).val(msg).addClass(defaultTextClassName).attr('id', $(this)[0].id + defaultIdSuffix);
					
					if ($(real_obj).val() == "") {
	                    $(real_obj).hide();
	                    $(default_obj).show();
	                } else {
	                    $(real_obj).show();
	                    $(default_obj).hide();
	                }
	                
	                var defaultClickHandler = function() {
						setTimeout(function() {
							if ($(real_obj).css('display') == 'none') {
								$(default_obj).hide();
								$(real_obj).show();
								$(real_obj).focus();
							}
						},1);
	                };
	
	                $(default_obj).click(defaultClickHandler);
	                $(default_obj).mousedown(defaultClickHandler);
	                $(default_obj).focus(defaultClickHandler);
	                
	                $(real_obj).blur(function() {
						setTimeout(function() {
		                    if ($(real_obj).val() == "") {
		                        $(default_obj).show();
		                        $(real_obj).hide();
		                    }
						},1);
	                });
					
				} else
				{
					$('#' + $(this)[0].id + defaultIdSuffix).val(msg);
				}
                
                
            });
        }        
    });    
})(jQuery);