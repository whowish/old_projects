/**
 * @author Tanin
 */

/*
 * Kratoo section
 * 
 * 
 * 
 * 
 */

var kratoo_handler = {};

kratoo_handler.agree = function(sender,type,kratoo_id) {
	try
	{
		$(sender).loading_icon(true);
		var data = {
			"kratoo_id":kratoo_id,
			"agree_type":type
		};
		
		
		$.ajax({
			type: "POST",
			url: '/kratoo/agree',
			cache: false,
			headers: {
				"Connection": "close"
			},
			data: data,
			success: function(response){
				if (response.ok == true) {
					$(sender).loading_icon(false);
					$('#kratoo_agree_unit').replaceWith(response.html);
				}
				else {
					$(sender).loading_icon(false);
				}
			},
			error: function(req, status, e){
				$(sender).loading_icon(false);
				if (req.status == 0) 
					return;
				alert('Cannot connect to the server. Please try again.')
			}
		});
	}catch (e)
	{
		$(sender).loading_icon(false);
		alert(e);
	}
}
	
kratoo_handler.remove = function(sender,id) {
	if (!confirm('Are you sure you want to delete this?')) return;
	$(sender).loading_icon(true);
	$.ajax({
		type: "POST",
		url: '/kratoo/delete',
		cache: false,
		headers:{"Connection":"close"},
		data: {
			"kratoo_id": id
		},
		success: function(data){
			if (data.ok == true)
			{
				top.location.href = data.url;
				return;
			}
			else
			{
				$(sender).loading_icon(false);
				alert(data.error_message);
			}
		},
		error: function(req, status, e){
			$(sender).loading_icon(false);
			alert('Cannot connect to the server. Please try again later.');
		}
	});
}

kratoo_handler.go_to_reply_offset = function(offset,sort) {
    try {
        $.ajax({
            type: "POST",
            url: '/reply',
            cache: false,
            data: {
                kratoo_id:"",
                offset: offset,
				sort: sort
            },
            success: function(data){
                try {
                    if (data.ok == true) {

                        $("#comment_panel").replaceWith(data.html);
                        $("#comment_panel").fadeIn();
                    }
                    else {

                    }

                }
                catch (e) {
                    $.error_log('comment_paging', e);
                    alert(e);
                }

            },
            error: function(req, status, e){
                 if (req.status == 0) return;
                alert('Cannot connect to the server. Please try again later.');
            }
        });
    } catch (e)
    {
        alert(e);
    }
}

/*
 * Kratoo Agree User section
 * 
 * 
 * 
 */

var kratoo_agree_handler = {};
$(function() {
	$('#kratoo_agree_dialog_box').dialog({ 
											autoOpen: false,
											resizeable:false,
											resizeable:false,
											width:"auto",
											height:"auto"
											});

});
kratoo_agree_handler.show_dialog = function(kratoo_id,agree_type) {
	$('#kratoo_agree_dialog_box').dialog('open');
	$('#kratoo_agree_list').html('loading');
	
	$.ajax({
		type: "POST",
		url: '/kratoo/agree_user',
		cache: false,
		headers:{"Connection":"close"},
		data: {
			"kratoo_id":kratoo_id,
			"agree_type":agree_type
			
		},
		success: function(data){	
			if (data.ok == true)
			{
				$('#kratoo_agree_list').html(data.html);
				
			} else {
				
			}
		},
		error: function(req, status, e){
		
			alert('Cannot connect to the server. Please try again later.');
		}
	});
}

/*
 * Reply section
 * 
 * 
 * 
 */

var reply_handler = {};

reply_handler.submit = function(sender,kratoo_id) {
	
	if (reply_validator.validate_all() == false) {
		return;
	}
	
	$(sender).loading_button(true);
	
	var is_anonymous = "no";
	
	if ($('#reply_anonymous_name_panel').length > 0
		&& $('#reply_anonymous_name_panel').css('display') != 'none')
	{
		is_anonymous = "yes";
	}
	
	$.ajax({
		type: "POST",
		url: '/reply/add',
		cache: false,
		headers:{"Connection":"close"},
		data: {
			"kratoo_id":kratoo_id,
			"content":$('#reply_content').val(),
			"is_anonymous":is_anonymous,
			"username":$('#reply_username').val()
		},
		success: function(data){
			$(sender).loading_button(false);
			if (data.ok == true)
			{
				$('#new_reply').before(data.html);
				$('#reply_identity_panel').replaceWith(data.identity_panel);
				if ($('#reply_content')[0].tagName.toLowerCase() == "iframe")
					$('#reply_content').contents().find('body').html('');
				else
					$('#reply_content').val('');
				
			} else {
				reply_validator.show_error(data.error_messages);
			}
		},
		error: function(req, status, e){
			$(sender).loading_button(false);
			alert('Cannot connect to the server. Please try again later.');
		}
	});
}

reply_handler.show_real_name_panel = function() {
	$('#reply_anonymous_name_panel').hide();
	$('#reply_real_name_panel').show();
}

reply_handler.show_anonymous_name_panel = function(){
	$('#reply_anonymous_name_panel').show();
	$('#reply_real_name_panel').hide();
}

reply_handler.facebook_login_callback = function(reply_identity_panel_html,reply_of_reply_identity_panel_html) {
	reply_handler.login_callback(reply_identity_panel_html,reply_of_reply_identity_panel_html);
}

reply_handler.login_callback = function(reply_identity_panel_html,reply_of_reply_identity_panel_html) {
	$('#reply_identity_panel').html(reply_identity_panel_html);
	$('#reply_submit_panel_require_login').hide();
	$('#reply_submit_panel').show();
	
	$('#reply_of_reply_identity_panel').html(reply_of_reply_identity_panel_html);
	$('#reply_of_reply_login_panel').hide();
	$('#reply_of_reply_form_panel').show();
}


reply_handler.login = function(sender,kratoo_id) {
	reply_handler.process_login(sender,
								reply_login_validator,
								$('#reply_login_remember_me:checked').val(),
								kratoo_id);
}

/* process_login is either call by reply_handler.login or reply_of_reply_handler.login
 * (They have different validator.)
 * 
 * 
 */
reply_handler.process_login = function(sender,validator,remember_me,kratoo_id) {
	
	if (!validator.validate_all()) {
		return;
	}
	
	$(sender).loading_button(true);

	$.ajax({
		type: "POST",
		url: '/member/login',
		cache: false,
		headers:{"Connection":"close"},
		data: {
			"username":validator.get_value("username"),
			"password":validator.get_value("password"),
			"kratoo_id":kratoo_id,
			"remember_me": remember_me,
			"option":"receiver_reply"
		},
		success: function(data){
			if (data.ok == true)
			{
				reply_handler.login_callback(data.reply_identity_panel, data.reply_of_reply_identity_panel);
			} else {
				$(sender).loading_button(false);
				validator.show_error(data.error_messages);
			}
			
		},
		error: function(req, status, e){
			$(sender).loading_button(false);
			alert('Cannot connect to the server. Please try again later.');
		}
	});
}

reply_handler.agree = function(sender,id,type) {
	try
	{
		//$(sender).loading_button(true,{word:""});
		$(sender).loading_icon(true);

		$.ajax({
			type: "POST",
			url: '/reply/agree',
			cache: false,
			headers: {
				"Connection": "close"
			},
			data: {
				"reply_id": id,
				"agree_type":type
			},
			success: function(response){
				$(sender).loading_icon(false);
				
				if (response.ok == true) {
					$('#reply_agree_unit_' + id).replaceWith(response.html);
				}
			},
			error: function(req, status, e){
				$(sender).loading_icon(false);
				if (req.status == 0) return;
				alert('Cannot connect to the server. Please try again.')
			}
		});
	}catch (e)
	{
		$(sender).loading_icon(false);
		alert(e);
	}
}
		
reply_handler.remove = function(sender,id) {
	if (!confirm('Are you sure you want to delete this?')) return;
	try
	{
		$(sender).loading_icon(true);
		var data = {
			authenticity_token: "<%=form_authenticity_token%>",
			"reply_id": id
		};
		
		
		$.ajax({
			type: "POST",
			url: '/reply/delete',
			cache: false,
			headers: {
				"Connection": "close"
			},
			data: data,
			success: function(response){
				if (response.ok == true) {
					
					$('#reply_' + id).fadeOut(function(){
						$('#reply_' + id).remove();
					});
				}
				else {
					$(sender).loading_icon(false);
				}
			},
			error: function(req, status, e){
				$(sender).loading_icon(false);
				if (req.status == 0) 
					return;
				alert('Cannot connect to the server. Please try again.')
			}
		});
	}catch (e)
	{
		$(sender).loading_icon(false);
		alert(e);
	}
}

/*
 * Reply Agree User section
 * 
 * 
 * 
 */

var reply_agree_handler = {};
$(function() {
	$('#reply_agree_dialog_box').dialog({ 
											autoOpen: false,
											resizeable:false,
											resizeable:false,
											width:"auto",
											height:"auto"
											});

});
reply_agree_handler.show_dialog = function(reply_id,agree_type) {
	$('#reply_agree_dialog_box').dialog('open');
	$('#reply_agree_list').html('loading');
	
	$.ajax({
		type: "POST",
		url: '/reply/agree_user',
		cache: false,
		headers:{"Connection":"close"},
		data: {
			"reply_id":reply_id,
			"agree_type":agree_type
			
		},
		success: function(data){	
			if (data.ok == true)
			{
				$('#reply_agree_list').html(data.html);
				
			} else {
				
			}
		},
		error: function(req, status, e){
		
			alert('Cannot connect to the server. Please try again later.');
		}
	});
}


/* Reply of Reply section
 * 
 * 
 */

var reply_of_reply_handler = {};
reply_of_reply_handler.current_reply_id = null;

$(function() {
	$('#reply_of_reply_dialog_box').dialog({ 
											autoOpen: false,
											resizeable:false,
											resizeable:false,
											width:"auto",
											height:"auto"
											});

	setTimeout("$('#reply_of_reply_content').writepub_editor({css_path:'/writepub_editor/writepub_content_editor.css'});",1000);

});
reply_of_reply_handler.show_post_dialog = function(reply_id) {
	reply_of_reply_handler.current_reply_id = reply_id;
	$('#reply_of_reply_dialog_box').dialog('open');
}

reply_of_reply_handler.submit = function(sender) {
	if (reply_of_reply_handler.current_reply_id == null) return;
	
		
	if (reply_of_reply_validator.validate_all() == false) {
		return;
	}
	
	$(sender).loading_button(true);
	
	var is_anonymous = "no";
	
	if ($('#reply_of_reply_anonymous_name_panel').length > 0
		&& $('#reply_of_reply_anonymous_name_panel').css('display') != 'none')
	{
		is_anonymous = "yes";
	}
	
	
	$.ajax({
		type: "POST",
		url: '/reply_of_reply/add',
		cache: false,
		headers:{"Connection":"close"},
		data: {
			"reply_id":reply_of_reply_handler.current_reply_id,
			"content":$('#reply_of_reply_content').val(),
			"is_anonymous":is_anonymous,
			"username":$('#reply_of_reply_username').val()
		},
		success: function(data){
			$(sender).loading_button(false);
			if (data.ok == true)
			{
				$('#new_reply_of_reply_' + reply_of_reply_handler.current_reply_id).before(data.html);
				$('#reply_of_reply_dialog_box').dialog('close');
				
				if ($('#reply_of_reply_content')[0].tagName.toLowerCase() == "iframe")
					$('#reply_of_reply_content').contents().find('body').html('');
				else
					$('#reply_of_reply_content').val('');
				
			} else {
				reply_of_reply_validator.show_error(data.error_messages);
			}
		},
		error: function(req, status, e){
			$(sender).loading_button(false);
			alert('Cannot connect to the server. Please try again later.');
		}
	});
}

reply_of_reply_handler.login = function(sender,kratoo_id) {
	reply_handler.process_login(sender, 
								reply_of_reply_login_validator,
								$('#reply_of_reply_login_remember_me:checked').val(),
								kratoo_id);
}

reply_of_reply_handler.agree = function(sender,id,type) {
	try
	{
		$(sender).loading_icon(true);

		$.ajax({
			type: "POST",
			url: '/reply_of_reply/agree',
			cache: false,
			headers: {
				"Connection": "close"
			},
			data: {
				"reply_of_reply_id": id,
				"agree_type":type
			},
			success: function(response){
				
				$(sender).loading_icon(false);
				if (response.ok == true) {
					$('#reply_of_reply_agree_unit_' + id).replaceWith(response.html);
				}
			},
			error: function(req, status, e){
				$(sender).loading_icon(false);
				if (req.status == 0) 
					return;
				alert('Cannot connect to the server. Please try again.')
			}
		});
	}catch (e)
	{
		$(sender).loading_icon(false);
		alert(e);
	}
}
		
	
reply_of_reply_handler.remove = function(sender,id) {
	if (!confirm('Are you sure you want to delete this?')) return;
	try {
		$(sender).loading_icon(true);
		
		$.ajax({
			type: "POST",
			url: '/reply_of_reply/delete',
			cache: false,
			data: {
				authenticity_token: "<%=form_authenticity_token%>",
				reply_id:"<%=entity.id%>",
				"reply_of_reply_id": id,
				"kratoo_id":"<%=entity.kratoo.id%>"
			},
			success: function(data){
				if (data.ok == true) {
						
						$('#reply_of_reply_' + id).fadeOut(function(){
							$('#reply_of_reply_' + id).remove();
						});
					}
					else {
						$(sender).loading_icon(false);
					}
				
			},
			error: function(req, status, e){
				$(sender).loading_icon(false);
                 if (req.status == 0) return;
				alert('Cannot connect to the server. Please try again later.');
			}
		});
	} catch (e)
	{
		$(sender).loading_icon(false);
		$.error_log('submit_delete_reply',e);
		alert(e);
	}
}

reply_of_reply_handler.show_real_name_panel = function() {
	$('#reply_of_reply_anonymous_name_panel').hide();
	$('#reply_of_reply_real_name_panel').show();
}

reply_of_reply_handler.show_anonymous_name_panel = function(){
	$('#reply_of_reply_anonymous_name_panel').show();
	$('#reply_of_reply_real_name_panel').hide();
}

/*
 * Reply of Reply Agree User section
 * 
 * 
 * 
 */

var reply_of_reply_agree_handler = {};
$(function() {
	$('#reply_of_reply_agree_dialog_box').dialog({ 
											autoOpen: false,
											resizeable:false,
											resizeable:false,
											width:"auto",
											height:"auto"
											});

});
reply_of_reply_agree_handler.show_dialog = function(reply_of_reply_id,agree_type) {
	$('#reply_of_reply_agree_dialog_box').dialog('open');
	$('#reply_of_reply_agree_list').html('loading');
	
	$.ajax({
		type: "POST",
		url: '/reply_of_reply/agree_user',
		cache: false,
		headers:{"Connection":"close"},
		data: {
			"reply_of_reply_id":reply_of_reply_id,
			"agree_type":agree_type
			
		},
		success: function(data){	
			if (data.ok == true)
			{
				$('#reply_of_reply_agree_list').html(data.html);
				
			} else {
				
			}
		},
		error: function(req, status, e){
		
			alert('Cannot connect to the server. Please try again later.');
		}
	});
}