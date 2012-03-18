/**
 * @author admin
 */
var kratoo_edit_handler = {};
kratoo_edit_handler.submit = function(sender,id) {

	if (kratoo_edit_validator.validate_all() == false) {
		return;
	}
	$(sender).loading_button(true);
	
	$.ajax({
		type: "POST",
		url: '/kratoo/edit_kratoo',
		cache: false,
		headers:{"Connection":"close"},
		data: {
			"kratoo_id":id,
			"title":$('#title').val(),
			"content":$('#content').val()
		},
		success: function(data){
			if (data.ok == true)
			{
				location.href = "/kratoo/view/" + data.kratoo_id;
			} else {
				$(sender).loading_button(false);
				kratoo_edit_validator.show_error(data.error_messages);
			}
			
		},
		error: function(req, status, e){
			$(sender).loading_button(false);
			alert('Cannot connect to the server. Please try again later.');
		}
	});
}