/**
 * @author apiromna
 */
	
	function get_parameters(module,id)
	{
		params = {};
		params["id"] = id; 
		for(i=0;i<parameters[module].length;i++)
		{
			params[parameters[module][i]] = $('#' + parameters[module][i] +  '_' + module + '_'+id).val();
		}
		// params["name"] = $('#name_' + module + '_' + id).val();
		return params;
	}
	
	function clear(module,id)
	{
		$('#save_button_'+module+'_'+id).attr('class','add_icon');
		//$('#name_'+module+'_'+id).val('');
		for (i = 0; i < parameters[module].length; i++)
		{
			$('#' + parameters[module][i] + '_'+module+'_'+id).val('');
		}
	}
	
	function reset_error(module, id){
		$('#row_' + module + '_' + id).removeClass('error_row');
		
		for (i = 0; i < parameters[module].length; i++) {
			$('#error_'+parameters[module][i]+'_'+module+'_' + id).css({'display': 'none'});
		}
	}
	
	function get_selected_value(select)
	{
		for (i=0;i<select.options.length;i++)
			if (select.options[i].selected)
				return select.options[i].value;
	}
	
	function get_checked_values(id)
	{
		str = "";
		i = 0;
		while ($(id + '_' + i))
		{
			if ($(id + '_' + i).checked)
			{
				if (str != "") str += ",";
				str += "" + $(id + '_' + i).value;
			}
			
			i++;
		}
		
		return str;
	}

	function set_error(module,id,error_message)
	{
		$('#save_button_'+module+'_'+id).attr('class','error_icon');
		$('#row_'+module+'_'+id).addClass("error_row");
		
		for (i = 0; i < parameters[module].length; i++) {
			
			value = eval('error_message.'+parameters[module][i]+'[0]');
			if (value == null || value == undefined) continue;
			
			$('#error_'+parameters[module][i]+'_'+module+'_' + id).css({'display': 'block'});
			$('#error_'+parameters[module][i]+'_'+module+'_' + id).html(eval('error_message.'+parameters[module][i]+'[0]'));
		}
	}
	
	function save(module,id)
	{
		//if ($('#save_button_'+module+'_'+id).attr('class') == "ok_icon") return;
		
		$('#save_button_'+module+'_'+id).attr('class','loading_icon');
		
		reset_error(module,id);
		
		params = get_parameters(module,id);
		
		$.ajax({
			type: "POST",
			url: '/' + module + '/edit',
			cache: false,
			headers: {
				"Connection": "close"
			},
			dataType: "json",
			data: params,
			success: function(json){
				if (json.ok == true) {
					$('#save_button_' + module + '_' + id).attr('class', 'ok_icon');
				}
				else {
					set_error(module, id, json.error_message);
				}
			}
		});
	}
	
	function remove_entry(module,id)
	{
		//if ($('#delete_button_'+module+'_'+id).attr('class') == 'loading_icon') return;
		
		if (!confirm('Are you sure you want to delete this entry?')) return;
		
		$('#delete_button_'+module+'_'+id).attr('class','loading_icon');
		
		reset_error(module,id);
		$.ajax({
			type: "POST",
			url: '/' + module + '/delete',
			cache: false,
			headers: {
				"Connection": "close"
			},
			dataType: "json",
			data: {
				id: id
			},
			success: function(json){
				if (json.ok == true) {
					$('#row_' + module + '_' + id).remove();
				}
				else {
					$('#delete_button_' + module + '_' + id).attr('class', 'delete_icon');
					
					error_message = function(){
					};
					error_message[parameters["location"][0]] = [json.error_message];
					
					set_error(module, id, error_message);
				}
			}
		});
	}
	

	
	
	function add(module,id)
	{
		//if ($('#save_button_'+module+'_'+id).attr('class') == 'loading_icon') return;
		
		params = get_parameters(module,id);
		params["parent_id"] = parent_id;
		reset_error(module,id);
		
		$.ajax({
			type: "POST",
			url: '/' + module + '/add',
			cache: false,
			headers: {
				"Connection": "close"
			},
			dataType: "json",
			data: params,
			success: function(json){
				if (json.ok == true) {
					clear(module, id);
					$('#row_' + module + '_' + id).before(json.new_row);
				}
				else {
					set_error(module, id, json.error_message);
				}
			}
		});
	}
	
	$(document).ajaxError(function(){
		alert("Cannot connect to server. Please try again later");
	})