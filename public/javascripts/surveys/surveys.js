/*
 */

function init() {
	$(".survey-delete" ).button({
		icons: {
        	primary: "ui-icon-trash"
       	},
       	text : false
	});
	$(".survey-edit" ).button({
		icons: {
                primary: "ui-icon-pencil"
       },
       text : false
	});
	$(".survey-dialog, .survey-edit" ).button();
	
	$( ".survey-buttons" ).buttonset();

	$(".survey-dialog, .survey-edit" ).cpDialog('destroy');
	$(".survey-dialog, .survey-edit").cpDialog({
		'target' : '#survey_list',
		'form' : '.survey_form',
		'success' : init
	});

	$(".survey-delete").cpRemoveButton({
		'target'  : '#survey_list',
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

function edit_form_submit() {
	$(".survey_group_submit").click( function(event) {
				$.ajax({
					url : event.currentTarget.href,
					dataType : "html",
		            success: function(data){
						$('#edit-area').html(data);
            		}
            	});
				event.preventDefault();
	});
}

function init_group(id) {
	$(".group-delete" ).button({
		icons: {
        	primary: "ui-icon-trash"
       	},
       	text : false
	});
	$(".group-edit" ).button({
		icons: {
                primary: "ui-icon-pencil"
       },
       text : false
	});
	$(".group-dialog" ).button();
	
	$( ".group-buttons" ).buttonset();

$(".group-edit").click( function(event) {
				$.ajax({
					url : event.currentTarget.href,
					dataType : "html",
		            success: function(data){
						$('#edit-area').html(data);
            		}
            	});
				event.preventDefault();
			});


	$(".group-dialog").cpDialog('destroy');
	$(".group-dialog" ).cpDialog({
		'target' : '#group_list-'+ id,
		'form' : '.group_form',
		'success' : function() {
			init_group(id);
		}
	});
	$(".group-delete").cpRemoveButton({
		'target'  : '#group_list-'+ id,
		'success' :	function() {
			init_group(id);
		}
	});
}

jQuery(document).ready(function() {
	init();
});
