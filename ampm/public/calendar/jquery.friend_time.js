/**
 * @author admin
 */
(function($) {
	
	$.fn.extend({
		friend_time: function(data,friend_unit_callback,before_render_friend_callback) {
			return this.each(function() {
				this.hash_date = {}
				this.friend_unit_callback = friend_unit_callback;
				this.before_render_friend_callback = before_render_friend_callback;
				
				for (var i=0;i<data.length;i++)
				{
					if (!(data[i].time in this.hash_date))
						this.hash_date[data[i].time] = []
						
					this.hash_date[data[i].time].push(data[i].friend);
				}
				//console.info(this.hash_date)
				
//				var all_children = $(this).children('*');
//				for (var i=0;i<all_children.length;i++)
//				{
//					console.info($(all_children).height())
//				}
			});
		},
		friend_time_remove_friend: function(friend_id) {
			
			return this.each(function() {
				
			});
		},
		show_friend_time: function(time_list) {
			return this.each(function() {
				
				var temp = null
				for (var i=0;i<time_list.length;i++)
				{
					if (time_list[i].length == 10)
						time_list[i] = time_list[i]+' 00:00:00'
						
					var friends = this.hash_date[time_list[i]];
					
					if (friends == undefined || friends == null)
					{
						temp = {};
						break;
					}
					
					var new_temp = {};
					for (var j=0;j<friends.length;j++)
					{
						if (temp == null || temp[friends[j]] == true)
						{
							new_temp[friends[j]] = true;
						}
					}
					
					temp = new_temp;
					//console.info(temp)
				}
				
				//console.info(temp)
				if (temp == null) temp = {};
				
				if (this.before_render_friend_callback != undefined)
					this.before_render_friend_callback()
				
				str = "";
				for (var k in temp)
				{
					if (this.friend_unit_callback == undefined)
						str += k+"<br/>";
					else
						this.friend_unit_callback(k)
				}
				
			});
		}
	})
})(jQuery)