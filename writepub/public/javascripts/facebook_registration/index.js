	function submit_facebook_registration() {
		if (!facebook_registration_validator.validate_all()) {
			return;
		}
		
		try {
			$('#facebook_registration_submit_button').loading_button(true);
			
			$.ajax({
				type: "POST",
				url: '/facebook_registration/create',
				cache: false,
				data: {
					"username": $('#facebook_registration_username').val(),
					"password": $('#facebook_registration_password').val(),
					"redirect_path": $('#facebook_registration_redirect_path').val()
				},
				success: function(data){
					try {
						if (data.ok == true) {
							
							location.href = data.redirect_url;

						}
						else {
							$('#facebook_registration_submit_button').loading_button(false);
							facebook_registration_validator.show_error(data.error_messages);
						}
						
					} 
					catch (e) {
						$('#facebook_registration_submit_button').loading_button(false);
						alert(e);
					}
					
				},
				error: function(req, status, e){
					$('#facebook_registration_submit_button').loading_button(false);
					alert('Cannot connect to the server. Please try again later.');
				}
			});
		} catch (e)
		{
			$('#facebook_registration_submit_button').loading_button(false);
			alert(e);
		}
	}