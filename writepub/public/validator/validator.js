/**
 * @author Tanin
 * Assume jQuery
 */
function validator(error_summary_panel_id) {
	
	var fields_to_validate = {};
	
	this.error_summary_panel_id = error_summary_panel_id;
	
	this.register_validation = function(field,textbox_id,error_display_id,success_message,funcs_with_message) {
		
		var self = this;
		
		$(function() {
			
			$('#'+textbox_id).change(function() {
				self.validate(field);
			});
		});
		
		if (!(field in fields_to_validate)) {
			fields_to_validate[field] = {
				funcs_with_message: []
			};
		}
		
		fields_to_validate[field].textbox_id = textbox_id;
		fields_to_validate[field].success_message = success_message;
		fields_to_validate[field].error_display_id = error_display_id;
		
		for (var i = 0; i < funcs_with_message.length; i++) {
			fields_to_validate[field].funcs_with_message.push(funcs_with_message[i]);
		}
		
		//console.log(fields_to_validate);								
	}
	
	this.get_value = function(field) {
		var obj = $('#'+fields_to_validate[field].textbox_id)[0];
		
		if (obj == undefined) return null;
		
		return $.trim($(obj).val());
	}
	
	this.validate = function(field) {
		//console.log("validate "+field);
		if (!(field in fields_to_validate)) return true;
		
		var val = this.get_value(field);
		if (val == null) return [];
		
		//console.log("check");
		errors = [];
		
		var funcs_with_msg = fields_to_validate[field].funcs_with_message;
		for (var i = 0; i < funcs_with_msg.length; i++) {
			if (errors.length > 0 && funcs_with_msg[i] == null) break;
			if (funcs_with_msg[i] == null) continue;
			
			if(!funcs_with_msg[i].f(val)) {
				errors.push(funcs_with_msg[i].m);
			}
		}
		
		this.show_single_error(fields_to_validate[field].error_display_id,fields_to_validate[field].success_message,errors);
		this.show_error_summary_panel([]);
		return errors;
	}
	
	this.validate_all = function() {

		var error_messages = [];
		
		for (var field in fields_to_validate) {
			this_error_messages = this.validate(field);
			
			for (var i=0;i<this_error_messages.length;i++)
				error_messages.push(this_error_messages[i]);
		}
		
		this.show_error_summary_panel(error_messages);
		
		return error_messages.length == 0;
	}
	
	this.show_single_error = function(error_display_id,success_message,error_messages) {
		
		if (error_display_id == null || error_display_id == undefined) {
			return;
		}
		
		if (error_messages.length == 0) {
			
			if (success_message != null && success_message != "") {
				$('#'+error_display_id).html("<p class='tip ok'>"+success_message+"</p>");
			} else {
				$('#'+error_display_id).html("&nbsp;");
			}
			
			return;
		}
		
		var error_html = "";
		
		if( typeof error_messages === 'string' ) error_messages = [error_messages];
		
		for (var i=0;i<error_messages.length;i++) {
			error_html += "<p class='tip error'>"+error_messages[i]+"</p>";
		}
		
		//console.log(error_html);
		
		$('#'+error_display_id).html(error_html);
	}
	
	this.show_error = function(json) {
		
		error_messages = [];
		for (var field in json) {
			
			if( typeof json[field] === 'string' ) json[field] = [json[field]];
			
			if (field in fields_to_validate)
				this.show_single_error(fields_to_validate[field].error_display_id,"",json[field]);
			
			for (var i = 0; i < json[field].length; i++) {
				error_messages.push(json[field][i]);
			}
		}
		
		this.show_error_summary_panel(error_messages);
	}
	
	this.show_error_summary_panel = function(error_messages) {
		if (this.error_summary_panel_id != undefined && this.error_summary_panel_id != null) {
			var error_html = "";
		
			for (var i=0;i<error_messages.length;i++) {
				error_html += "<p class='tip error'>"+error_messages[i]+"</p>";
			}
			
			$('#'+this.error_summary_panel_id).html(error_html);
			$('#'+this.error_summary_panel_id).hide();
			$('#'+this.error_summary_panel_id).fadeIn();
		}
	}
	
	
}

validator_helper = {};
validator_helper.email = function(value) {
	if (value.match(/.+@.+/))
		return true;
	else
		return false;
}

validator_helper.number = function(allow_float,allow_negative,max_precision) {
	
	return function(value) {
		return false;
	};
}

validator_helper.max_length = function(max) {
	return function(value) {
		return (value.length <= max);
	};
}

validator_helper.presence = function(value) {
	return (value!="");
}

validator_helper.min_length = function(min) {
	return function(value) {
		return (value.length >= min);
	};
}


