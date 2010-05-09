// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function(){
		$('li.menutop').hover(
			function() { $('ul', this).css('visibility', 'visible'); },
			function() { $('ul', this).css('visibility', 'hidden'); });
});
	
