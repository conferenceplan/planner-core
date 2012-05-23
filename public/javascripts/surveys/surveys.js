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
    	'edit-success'		: init
    }, options);

	
	$(settings['delete-button']).button({
		icons: {
        	primary: "ui-icon-trash"
       	},
       	text : false
	});
	if (settings['edit-button'].length > 0) {
	$(settings['edit-button']).button({
		icons: {
                primary: "ui-icon-pencil"
       },
       text : false
	});
	}
	$(settings['display-button']).button();
	
	$(settings['button-set']).buttonset();

	$(settings['display-button']).cpDynamicArea('destroy');
	$(settings['display-button']).cpDynamicArea({
		'target' : settings['target'],
		'form' : settings['form'],
		'success' : settings['success'],
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
		
        $(el).find('.survey_question_format').coolfieldset({collapsed:true, animation:false});
	});

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


function init_group_edit(id, el) {
	$(el).find('.group-edit-link').cpDynamicArea('destroy');
	$(el).find('.group-edit-link').cpDynamicArea({
		'target' : '.group_detail', //'#edit-area-1',
		'form' : '#layerform',
		'form-target' : '#group_list-' + id,
		'form-cancel-target' : '.group_detail',
		'success' : function() {
			init_group(id);
		},
		'cancel-success' : function() {
			init_group_edit(id, el);
		}
	});
};


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
    		$('#edit-area-1').html(''); // clears the area
    	},
    	'init'				: function(el) {
    		init_question(el);
    		init_group_edit(id,el);
    	}
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


function init_survey_area(el) {
    
	$(el).find('.survey-edit-link').cpDynamicArea({
		'target' : '#edit-area-1',
		'form' : '#layerform',
		'form-target' : '#survey_list',
		'form-cancel-target' : '#edit-area-1',
		'success' : function() {
			init();
			$(el).html('');
		},
		'cancel-success' : function(el) {
			init_survey_area(el);
		},
		'init' : function(el) {
			$(el).find('textarea.rte').each(function() {
				// alert($(this)[0].id);
			    try {
					if(CKEDITOR.instances[$(this)[0].id] != null) {
            			delete CKEDITOR.instances[$(this)[0].id];
			        }
        	    } catch(e){
			    }
			});
			$(el).find( 'textarea.rte' ).ckeditor({
				removePlugins : "elementspath,flash"
//				toolbar : 'Basic'
			});
		}
	});
}

function init() {
	init_buttons({
    	'delete-button'		: '.survey-delete',
    	'edit-button'       : '',
    	'display-button'    : '.survey-display',
    	'button-set'		: '.survey-buttons',
    	'target'			: '#edit-area-1',
    	'form-target'		: '#survey_list',
    	'form'				: '#layerform',
    	'success'			: init,
    	'edit-success'		: init,
    	'init'				: init_survey_area
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
					$('#edit-area-1').html('');
					$('#edit-area-2').html('');
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
