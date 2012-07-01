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
        var targetid = $(element).find('.question_detail').attr('id');
        $(element).find('.question-edit-link').cpDynamicArea('destroy');
        $(element).find('.question-edit-link').cpDynamicArea({
            'target' : '#' + targetid,
            'form' : '#question_form-' + targetid,
            'form-target' : '#' + targetid,
            'success' : init_question,
            'init' : init_question
        });
        
        $(element).find('.question-delete-link').cpRemoveButton({
            'target'  : '#selectable-questions',
            'success' : function(els) {
                //alert(els.html());
                init_questions(els);
            }
        });
        
        $(element).find('.survey_question_format, .survey_question_advanced, .survey_question_answers').coolfieldset({collapsed:true, animation:false});

        $(element).find('.question-type').change(
            function(event) {
                // TODO - Add code so that 'answers' can be added to question if type is not text
                // also if type changes to text then the answers need to be removed...
                if (event.currentTarget.value.indexOf('text') != -1) {
                    $(element).find('.question-answers').hide();
                } else {
                    $(element).find('.question-answers').show();
                }
            }
        );
}

function init_questions(element) {
	// go through each question and assign the edit logic
	element.find('.survey-question-display').each(function(idx, el) {
	    init_question(el);
	});

	element.find('.question-new-link').cpDynamicArea('destroy');
	element.find('.question-new-link').cpDynamicArea({
		'target' : '#edit-area',
		'form' : '#question_form-questionid-',
		'form-target' : '#selectable-questions',
        'init' : init_question,
		'success' : function() {
			init_questions(element);
			$('#edit-area').html('');
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
    		init_questions(el);
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
				removePlugins : "elementspath,flash",
				toolbar : 'CPlan',
                toolbar_CPlan : [
                        { name: 'basicstyles', items : [ 'Bold','Italic','Underline','Strike','Subscript','Superscript','-','RemoveFormat' ] },
                        { name: 'paragraph', items : [ 'NumberedList','BulletedList','-','Outdent','Indent','-','Blockquote','CreateDiv','-','JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock','-','BidiLtr','BidiRtl' ] },
                        { name: 'links', items : [ 'Link','Unlink','Anchor' ] },
                        { name: 'insert', items : [ 'Table','HorizontalRule','SpecialChar' ] }, // 'Image',
                        // '/',
                        // { name: 'styles', items : [ 'Styles','Format','Font','FontSize' ] },
                        // { name: 'colors', items : [ 'TextColor','BGColor' ] },
                        { name: 'tools', items : [ 'Maximize', 'ShowBlocks','-','About' ] }
                    ]
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
