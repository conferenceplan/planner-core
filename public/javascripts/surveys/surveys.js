/*
 */

function init_buttons(options) {
	var settings = $.extend( {
    	'delete-button'		: '.survey-delete',
    	'edit-button'       : '.survey-edit',
    	'display-button'    : '.survey-display',
    	'button-set'		: '.survey-buttons',
    	'target'			: '#edit-area-1',
    	'form-target'		: '#survey_list',
    	'form'				: '#layerform',
    	'success'			: init,
    	'edit-success'		: init,
    	'init'				: function() { }
    }, options);

	
	$(settings['delete-button']).button({
		icons: {
        	primary: "ui-icon-trash"
       	},
       	text : false
	});
	$(settings['edit-button']).button({
		icons: {
                primary: "ui-icon-pencil"
       },
       text : false
	});
	$(settings['display-button']).button();
	
	$(settings['button-set']).buttonset();

	$(settings['display-button']).cpDynamicArea('destroy');
	$(settings['display-button']).cpDynamicArea({
		'target' : settings['target'],
		'form' : settings['form'],
		'success' : settings['success'],
		'init' : settings['init']
	});

	$(settings['edit-button']).cpDynamicArea('destroy');
	$(settings['edit-button']).cpDynamicArea({
		'target' : settings['target'],
		'form' : settings['form'],
		'form-target' : settings['form-target'],
		'success' : settings['edit-success'],
		'init' : settings['init']
	});

	$(settings['delete-button']).cpRemoveButton({
		'target'  : settings['form-target'],
		'success' : function() {
			settings['success']();
			$(settings['target']).html('')
		}
	});
}

function init_question(element) {
	// go through each question and assign the edit logic
	element.find('.question-stuff').each(function(idx, el) {
		var targetid = $(el).find('.question_detail').attr('id');
	    $(el).find('.question-edit-link').cpDynamicArea('destroy');
	    $(el).find('.question-edit-link').cpDynamicArea({
			'target' : '#' + targetid,
			'form' : '#question_form-' + targetid,
			'form-target' : '#' + targetid,
			'success' : function() {
				init_question(element);
			}
		});
		
		$(el).find('.question-delete-link').cpRemoveButton({
			'target'  : '#selectable-questions',
			'success' : function() {
					init_question(element);
			}
		});
		// $(el).find('.question-delete-link').click(function(event) {
			// $.ajax({
				// url : event.currentTarget.href,
				// success : function(data) {
					// $('#edit-area').replaceWith(data);
					// init_question();
				// }
			// });
			// event.preventDefault();
		// });
	});

	// $().appendTo('#selectable-questions')
	// Add event to question-new-link
	element.find('.question-new-link').cpDynamicArea('destroy');
	element.find('.question-new-link').cpDynamicArea({
		'target' : '#edit-area',
		'form' : '#question_form-questionid-',
		'form-target' : '#selectable-questions',
		'success' : function() {
			init_question(element);
			$('#edit-area').html('');
			// and clear the add area
		}
	});
}

function init_group(id) {
	init_buttons({
    	'delete-button'		: '.group-delete',
    	'edit-button'       : '.group-edit',
    	'display-button'    : '.group-display',
    	'button-set'		: '.group-buttons',
    	'target'			: '#edit-area-1',
    	'form-target'		: '#group_list-'+ id,
    	'form'				: '#layerform',
    	'success'			: function() {
    		init_group(id);
    	},
    	'edit-success'		: function() {
			init_group(id);
    		$('#edit-area-1').html('');
    	},
    	'init'				: init_question
	});

	$(".group-dialog" ).button();
	$(".group-dialog").cpDialog('destroy');
	$(".group-dialog" ).cpDialog({
		'target' : '#group_list-'+ id,
		'form' : '.group_form',
		'success' : function() {
			init_group(id);
    		$('#edit-area-1').html('');
		}
	});
}

function init() {
	init_buttons({
    	'delete-button'		: '.survey-delete',
    	'edit-button'       : '.survey-edit',
    	'display-button'    : '.survey-display',
    	'button-set'		: '.survey-buttons',
    	'target'			: '#edit-area-1',
    	'form-target'		: '#survey_list',
    	'form'				: '#layerform',
    	'success'			: init,
    	'edit-success'		: init
	});

	$(".survey-dialog").button();
	$(".survey-dialog" ).cpDialog('destroy');
	$(".survey-dialog").cpDialog({
		'target' : '#survey_list',
		'form' : '.survey_form',
		'success' : init
	});

	$("#survey-accordian").accordion({
		active : false,
		autoHeight: false,
		change : function(e, ui) {
			// show the groups associated with the survey
			var id = ui.newHeader.attr("surveyid");
			$.ajax({
				url : "/surveys/" + id + "/survey_groups",
				success : function(data) {
					$('#current_groups-' + id + ' div').replaceWith(data);
					init_group(id);
				}
			});
		}
	});
}

jQuery(document).ready(function() {
	init();
});
