function submit_email_registration()
{
	if (email_registration_validator.validate_all() == false) {
		return;
	}
	
	try {
		$('#email_registration_submit_button').loading_button(true);
		
		$.ajax({
			type: "POST",
			url: '/email_registration/register',
			cache: false,
			data: {
				"email": $('#email_registration_email').val()
			},
			success: function(data){
				try {
					if (data.ok == true) {
						location.href = data.redirect_url
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