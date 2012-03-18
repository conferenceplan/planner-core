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
                primary: "ui-icon-wrench"
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

function init_group(id) {
	$(".group-delete" ).button({
		icons: {
        	primary: "ui-icon-trash"
       	},
       	text : false
	});
	$(".group-edit" ).button({
		icons: {
                primary: "ui-icon-wrench"
       },
       text : false
	});
	$(".group-dialog" ).button();
	
	$( ".group-buttons" ).buttonset();

	$(".group-dialog, .group-edit" ).cpDialog('destroy');
	$(".group-dialog, .group-edit" ).cpDialog({
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
	
	// $("#surveys")
        // .jstree({
            // "plugins" : ["themes","json_data","ui","crrm","hotkeys","types", "themeroller"],
// //            "plugins" : ["themes","html_data","ui","crrm","hotkeys","types"],
            // "core" : { "initially_open" : [ "phtml_1" ] },
            // "types" : {
            	// "max_depth" : -2, 
            	// "max_children" : -2,
            	// "valid_children" : ["survey"],
            	// "types" : {
            		// "survey" : {
            			// "valid_children" : "group",
            			// "icon" : { "image" : "/images/icons/survey.png"}
            		// },
            		// "group" : {
            			// "valid_children" : "question",
            			// "icon" : { "image" : "/images/icons/group.png"}
            		// },
            		// "question" : {
            			// "valid_children" : ["answer", "question"],
            			// "icon" : { "image" : "/images/icons/question.png"}
            		// },
            		// "answer" : {
            			// "valid_children" : "none",
            			// "icon" : { "image" : "/images/icons/answer.png"}
            		// }//,
            		// // "default" : {
            			// // "icon" : { "image" : "/images/icons/survey.png"}//,
            		// // }
            	// }
            // },
			// "json_data" : {
				// "data" : [
					// {
						// "data" : "survey1",
						// "attr" : { "rel" : "survey" },
						// "children" : [
							// "child 1", "child 2"
						// ]
					// },
					// {
						// "data" : "survey2",
						// "attr" : { "rel" : "survey" },
						// "children" : [
							// {
								// "data" : "group 3",
								// "attr" : { "rel" : "group" }
							// },
							// {
								// "data" : "group 4",
								// "attr" : { "rel" : "group" },
								// "children": [
									// {
										// "data" : "question 3",
										// "attr" : { "rel" : "question" },
										// "children": [
											// {
												// "data" : "answer 3",
												// "attr" : { "rel" : "answer" }
											// }
										// ]
									// }
								// ]
							// },
							// {
								// "data" : "group 5",
								// "attr" : { "rel" : "group" }
							// }
						// ]
					// }
				// ]
			// }
        // })
        // .bind("loaded.jstree", function (event, data) {
            // // you get two params - event & data - check the core docs for a detailed description
        // });
