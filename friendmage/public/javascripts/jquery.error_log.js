/**
 * @author Tanin
 */
(function($){

 	$.extend({ 
 		
		//pass the options variable to the function
 		error_log: function(identifier, description) {
			try {
				$.ajax({
					type: "POST",
					url: '/error',
					cache: false,
					headers: {
						"Connection": "close"
					},
					dataType: "json",
					data: {
						"identifier": identifier,
						"description": description
					},
					success: function(data){
					}
				})
			} catch (e)
			{
				
			}
		}
		
	});
	
})(jQuery);


$(document).ajaxError(function(e, xhr, settings, exception) {
	if (settings.url == "/error") return;
	
  	$.error_log(settings.url,"Data sent: " + settings.data + "\r\n\r\n Response text:\r\n " + xhr.responseText);
	
	if (settings.url == "/home/load_more") return;
  	//alert('Cannot connect to whoWish server. Please try again in a moment.');
});