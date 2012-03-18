/**
 * Created by Switch Button.
 * User: admin
 * Date: 3/17/11
 * Time: 2:58 PM
 * To change this template use File | Settings | File Templates.
 */
(function($){

 	$.fn.extend({
        get_switch_button_value: function ()
        {
            var width = $(this[0]).width();
            var margin = parseInt($(this[0]).children('span').css('margin-left'));

            return ((margin < (width/4))?"no":"yes");
        },

        toggle_switch_button: function (callback)
        {
            var args = [];
            for (var i=1;i<arguments.length;i++) args[i-1] = arguments[i];

            return this.each(function() {
                if (this.operated) return;

                this.operated = true;

                var width = $(this).width();
                var button_width = $(this).children('span').width();
                var margin = parseInt($(this).children('span').css('margin-left'));
                if (!margin) margin = 0;

                var direction = ((margin < (width/4))? "+" :  "-")+"="+button_width;
                var obj = this;

                $(this).children('span').animate({
                    'margin-left': direction
                },75,function() {
					$(obj).children('span').css('margin-left',((margin < (width/4))? button_width :  0));
                    obj.operated = false;
                    callback(args[0]);
                })
            });
        }
	});

})(jQuery);
