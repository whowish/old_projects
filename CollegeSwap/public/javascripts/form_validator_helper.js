function validate_input_obj(input_obj,fn,value)
{
	if (value == null){
		value = $(input_obj).val();
	}
	
	var error = fn(value);
			
	if ((!(error instanceof Array) && error != null) 
		|| (error instanceof Array && error.length > 0))
	{
		$(input_obj).ruby_box(true,error);
		return false;
	}
	else
	{
		$(input_obj).ruby_box(false);
		return true;
	}
}

function get_string_errors(s)
{
	if( $.trim(s).length <= 0 )
	{
		return "Cannot be empty";
	}
	if( $.trim(s).length > 255 )
	{
		return "Cannot contain more than 255 characters";
	}
	return null;
}

function get_money_errors(s)
{
	if( $.trim(s).length <= 0 )
	{
		return "Cannot be empty";
	}
	
	if (!($.trim(s).match(/^[0-9]+(\.[0-9]{1,2})?$/)))
	{
		return "Must be a number"
	}
	
	return null;
}

function get_date_errors(s)
{
	if($.trim(s).length <= 0 )
	{
		return "Cannot be empty";
	}
	
	if (!($.trim(s).match(/^[0-9]{4}-[0-9]{2}-[0-9]{2}$/)))
	{
		return "Must be date with format YYYY-MM-DD"
	}
	
	return null;
}


function get_number_errors(s)
{
	if( $.trim(s).length <= 0 )
	{
		return "Cannot be empty";
	}
	
	if (!($.trim(s).match(/^[0-9]+?$/)))
	{
		return "Must be a number"
	}
	
	return null;
}

function get_email_errors(s)
{
	// check empty
	if( s.length <= 0 )
	{
		return "Must be an email";
	}
	// check invalid format
	index = s.indexOf( "@" );
	if( index == -1 )
	{
		return "is invalid because it does not contain '@'.";
	}
	// check min length
	mailaddr = s.substring(0, index);
	if( mailaddr.length < 4 )
	{
		return "is invalid because it must be at least 4 characters long";
	}
	// check max length
	if( mailaddr.length > 255 )
	{
		return "is invalid because it must be at most 255 characters long";
	}

	return null;
}

