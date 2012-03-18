/**
 * @author admin
 */
// jquery.escape 1.0 - escape strings for use in jQuery selectors
// http://ianloic.com/tag/jquery.escape
// Copyright 2009 Ian McKellar <http://ian.mckellar.org/>
// Just like jQuery you can use it under either the MIT license or the GPL
// (see: http://docs.jquery.com/License)
(function() {

jQuery.escape_html = function (s) {
	var escaped = s;;
	var findReplace = [[/</g, "&lt;"], [/>/g, "&gt;"], [/"/g, "&quot;"]]
	for (var i=0;i<findReplace.length;i++) {
		var item = findReplace[i];
		escaped = escaped.replace(item[0], item[1]);
	}

	return escaped;
}
})();
