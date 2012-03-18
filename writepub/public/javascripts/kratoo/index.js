/**
 * @author Tanin
 */

var kratoo_handler = {};

kratoo_handler.Tag = Backbone.Model.extend();
kratoo_handler.TagSet = Backbone.Collection.extend();

kratoo_handler.tag_unit = Handlebars.compile($("#tag_unit").html());
kratoo_handler.tags = new kratoo_handler.TagSet();

kratoo_handler.tags.bind("add",function (entity) {
	$("#kratoo_tags").append(kratoo_handler.tag_unit({cid:entity.cid,name:entity.get('name')}));
	
	$("#kratoo_tags").children('.tag_'+entity.cid).hide();
	$("#kratoo_tags").children('.tag_'+entity.cid).fadeIn();
});

kratoo_handler.tags.bind("remove",function (entity) {
	$("#kratoo_tags").children(".tag_"+entity.cid).fadeOut(function() {$(this).remove();});
});



/*
 * Functions 
 *
 */

kratoo_handler.add_tag = function(sender) {
	
	var name = $(sender).val();
	$(sender).val('');
	
	if (name == "") return;
	if (this.tags.length >= 2) {
		// show the error message
		return; // full, cannot add anymore
	}
	
	if (this.tags.find( function(entity){ return entity.get('name')===name; }) == null)
		this.tags.add(new this.Tag({name:name}));
}

kratoo_handler.submit = function(sender) {
	
	if (kratoo_validator.validate_all() == false) {
		return;
	}
	
	$(sender).loading_button(true);
	
	var is_anonymous = "no";
	
	if ($('#kratoo_anonymous_name_panel').css('display') != 'none')
	{
		is_anonymous = "yes";
	}
	
	$.ajax({
		type: "POST",
		url: '/kratoo/add',
		cache: false,
		headers:{"Connection":"close"},
		data: {
			"title":$('#kratoo_title').val(),
			"content":$('#kratoo_content').val(),
			"kratoo_type":$('#kratoo_type').val(),
			"is_anonymous":is_anonymous,
			"username":$('#kratoo_username').val(),
			"tags":this.tags.map(function(entity) { return entity.get('name'); }).join(",")
		},
		success: function(data){
			if (data.ok == true)
			{
				location.href = "/kratoo/view/" + data.kratoo_id;
			} else {
				$(sender).loading_button(false);
				kratoo_validator.show_error(data.error_messages);
			}
			
		},
		error: function(req, status, e){
			$(sender).loading_button(false);
			alert('Cannot connect to the server. Please try again later.');
		}
	});
}

kratoo_handler.show_real_name_panel = function() {
	$('#kratoo_anonymous_name_panel').hide();
	$('#kratoo_real_name_panel').show();
}

kratoo_handler.show_anonymous_name_panel = function(){
	$('#kratoo_anonymous_name_panel').show();
	$('#kratoo_real_name_panel').hide();
}

kratoo_handler.facebook_login_callback = function(identity_panel_html) {
	$('#kratoo_identity_panel').html(identity_panel_html);
	
	$('#kratoo_submit_panel_require_login').hide();
	$('#kratoo_submit_panel').show();
}

kratoo_handler.login = function(sender) {
	
	if (!kratoo_login_validator.validate_all()) {
		return;
	}
	
	$(sender).loading_button(true);

	$.ajax({
		type: "POST",
		url: '/member/login',
		cache: false,
		headers:{"Connection":"close"},
		data: {
			"username":$('#kratoo_login_username').val(),
			"password":$('#kratoo_login_password').val(),
			"remember_me": $('#kratoo_login_remember_me:checked').val(),
			"option":"receiver_kratoo"
		},
		success: function(data){
			if (data.ok == true)
			{
				$('#kratoo_identity_panel').html(data.kratoo_identity_panel);
				$('#kratoo_submit_panel_require_login').hide();
				$('#kratoo_submit_panel').show();
			} else {
				$(sender).loading_button(false);
				kratoo_login_validator.show_error(data.error_messages);
			}
			
		},
		error: function(req, status, e){
			$(sender).loading_button(false);
			alert('Cannot connect to the server. Please try again later.');
		}
	});
}


$('#search_tag').autocomplete('/tag/autosuggest', {
		width:298,
		scroll: false,
		minChars: 2,
		extraParams: {
			id:  function() { return ""; }
		},
		parse: function(data)
		{
			if (data.ok == false) return [];

			var parsed = [];
			for (var i=0; i < data.results.length; i++) {
				parsed.push({
					data: data.results[i],
					value: data.results[i].name,
					result: function(data) {
						
						if (kratoo_handler.tags.length >= 2) {
							// show the error message
							return ""; // full, cannot add anymore
						}
						
						if (kratoo_handler.tags.find( function(entity){ return entity.get('name')===data.name; }) == null) 
							kratoo_handler.tags.add(new kratoo_handler.Tag({name:data.name}));
					
						$('#search_tag').val('');
						
						return "";
					}
				});
			}
			return parsed;
		},
		formatItem: function(data, i, n, value) {
			if (data.parent_names !== "")
				return value + "(" +data.parent_names+")";
			else
				return value;
		}
	});
