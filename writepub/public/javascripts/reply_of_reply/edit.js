/**
 * @author admin
 */
var reply_of_reply_edit_handler = {};
reply_of_reply_edit_handler.submit = function(sender,id) {
	if (reply_of_reply_edit_validator.validate_all() == false) {
		return;
	}
	
	$(sender).loading_button(true);
	
	$.ajax({
		type: "POST",
		url: '/reply_of_reply/edit',
		cache: false,
		headers:{"Connection":"close"},
		data: {
			"reply_of_reply_id":id,
			"content":$('#content').val()
		},
		success: function(data){
			if (data.ok == true)
			{
				location.href = "/kratoo/view/" + data.kratoo_id;
			} else {
				$(sender).loading_button(false);
				reply_of_reply_edit_validator.show_error(data.error_messages);
			}
			
		},
		error: function(req, status, e){
			$(sender).loading_button(false);
			alert('Cannot connect to the server. Please try again later.');
		}
	});
}
