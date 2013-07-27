// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

//= require jquery-1.9.1.min
//= require jquery-ui-1.9.2.custom.min
//= require jquery_ujs
//= require jquery-migrate-1.1.1
//= require jquery.timers-1.2
//= require jquery.freeow
//= require jquery.form
//= require jquery.timeentry.min
//= require grid.locale-en
//= require jquery.jqGrid.min

//= require bootstrap

//= require backbone/underscore-min
//= require backbone/backbone
//= require backbone/extensions/backbone-relational
//= require backbone/extensions/backbone.paginator.js
//= require backgrid/backgrid
//= require moment/moment
//= require backgrid/extensions/moment-cell/backgrid-moment-cell
//= require backgrid/extensions/text-cell/backgrid-text-cell

//= require planIt

$(document).ready(function(){
		$('li.menutop').hover(
			function() { $('ul', this).css('visibility', 'visible'); },
			function() { $('ul', this).css('visibility', 'hidden'); });
			
});
	
