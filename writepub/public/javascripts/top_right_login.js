/**
 * @author admin
 */
var top_right_login_handler = {};

top_right_login_handler.submit = function(sender,redirect_url) {
	if (!top_right_login_validator.validate_all()) {
		return;
	}
	
	try {
		$(sender).loading_button(true);
		
		$.ajax({
			type: "POST",
			url: '/member/login',
			cache: false,
			data: {
				"redirect_url":redirect_url,
				"username": $('#top_right_login_username').val(),
				"password": $('#top_right_login_password').val(),
				"remember_me": $('#top_right_login_remember_me:checked').val()
			},
			success: function(data){
				try {
					if (data.ok == true) {
						if (data.redirect_url != undefined) {
							top.location.href = data.redirect_url;
							return;
						}
					}
					else {
						$(sender).loading_button(false);
						top_right_login_validator.show_error(data.error_messages);
					}
				} 
				catch (e) {
					$(sender).loading_button(false);
					alert(e);
				}
				
			},
			error: function(req, status, e){
				$(sender).loading_button(false);
				alert('Cannot connect to the server. Please try again later.');
			}
		});
	} catch (e)
	{
		$(sender).loading_button(false);
		alert(e);
	}
}		
