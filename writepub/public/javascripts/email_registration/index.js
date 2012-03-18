	function submit_email_registration()
	{
		if (!email_registration_validator.validate_all()) {
			return;
		}
		
		try {
			$('#email_registration_submit_button').loading_button(true);
			
			$.ajax({
				type: "POST",
				url: '/email_registration/create',
				cache: false,
				data: {
					"username": $('#email_registration_username').val(),
					"password": $('#email_registration_password').val(),
					"email": $('#email_registration_email').val(),
					"unique_key": $('#email_registration_unique_key').val()
					
				},
				success: function(data){
					try {
						if (data.ok == true) {
							location.href = data.redirect_url;
						}
						else {
							$('#email_registration_submit_button').loading_button(false);
							email_registration_validator.show_error(data.error_messages);
						}
						
					} 
					catch (e) {
						$('#email_registration_submit_button').loading_button(false);
						alert(e);
					}
					
				},
				error: function(req, status, e){
					$('#email_registration_submit_button').loading_button(false);
					alert('Cannot connect to the server. Please try again later.');
				}
			});
		} catch (e)
		{
			$('#email_registration_submit_button').loading_button(false);
			alert(e);
		}
	}