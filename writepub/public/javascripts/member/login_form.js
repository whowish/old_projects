/**
 * @author admin
 */
var login_form_handler = {};

login_form_handler.submit = function(sender) {
	if (!login_form_validator.validate_all()) {
		return;
	}
	
	try {
		$(sender).loading_button(true);
		
		$.ajax({
			type: "POST",
			url: '/member/login',
			cache: false,
			data: {
				"redirect_url":$('#login_form_redirect_url').val(),
				"username": $('#login_form_username').val(),
				"password": $('#login_form_password').val()
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
						login_form_validator.show_error(data.error_messages);
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
