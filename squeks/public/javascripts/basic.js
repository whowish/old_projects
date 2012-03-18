/**
 * @author Tanin
 */
function view_all_hops(bus_id)
{
	
}

function hop(bus_id)
{
	$.whowish_box({title:"Hop",url:"/hop?bus_id="+bus_id});
}

function show_more(type,q)
{
	$('#show_more_button').loading_button(true);
	var signature = $(".bus_signature","span[id^=bus_container_]:last").val();
	$.ajax({
			type: "POST",
			url: '/home/show_more',
			cache: false,
			headers:{"Connection":"close"},
			data: {
				type:type,
				q:q,
				signature:signature
			},
			success: function(response){
				if (response.ok == true) {
					$('#show_more_button').before(response.html);
					$('#show_more_button').loading_button(false);
					
					if (response.end == true)
					{
						$('#show_more_button').hide();
					}
				}
				else {
					
					$('#show_more_button').loading_button(false);
				}
			},
			error: function(req,status,e){
				$('#show_more_button').loading_button(false);
                if (req.status == 0) return;
			}
		});
}
