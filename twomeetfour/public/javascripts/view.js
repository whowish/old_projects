var viewHandler = {};


viewHandler.edit = function(sender, id) {
	location.href = "/post/edit_form/" + id
}

viewHandler.remove = function(sender, id) {
	
	if (!confirm('คุณแน่ใจที่จะลบประกาศนี้ใช่ไหม ?')) return;
	
	$(sender).loading_icon(true);
	_gaq.push(['_trackEvent', 'Delete', 'Try', '']);
	
	$.ajax({
		type: "POST",
		url: '/post/delete',
		cache: false,
		data: {
			id: id,
		},
		success: function(data){
			_gaq.push(['_trackEvent', 'Delete', 'Succeeded', '']);

			if (data.ok != true) {
				$(sender).loading_button(false);
				alert(data.error_messages);
				return;
			}
			
			$('#post_'+id).fadeOut(function() {
				$(this).remove();
			});
			
		},
		error: function(req, status, e){
			$(sender).loading_icon(false);
			if (req.status == 0) return;
			
			mainLibrary.logFailedAjax('/post/delete', req, status, e);
			alert(e);
		}
	});
}

viewHandler.shareOnFacebook = function(url) {
	window.open("https://www.facebook.com/sharer.php?u="+url, 'facebook','height=400,width=700');
}

viewHandler.shareOnTwitter = function(url, text) {
	window.open("https://twitter.com/share?url=" + url + "&text=" + text, 'twitter','height=400,width=700');
}
