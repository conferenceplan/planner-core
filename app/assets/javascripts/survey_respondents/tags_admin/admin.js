/*
 * 
 */
function init() {
	$('#new_tag').hide(); //
	$('#move_selection').hide(); //
	$('#tag_edit_button').addClass('ui-state-disabled');
}

function clearForm() {
	init();
	$('#tag-list').html('')
	$('#tag_operation').val('')
	$('#tag_context').val('')
	$('#new_tag').val('');
	$('#original_tag').val('');
}

jQuery(document).ready(function(){

	init();	

	$('#tag_operation').change( function(obj) {
		init();	
		var op = $(this).val(); // get the operation from the selection
		if (op && op != '') {
			$('#tag_edit_button').removeClass('ui-state-disabled'); //.attr("disabled", true); //
		}
		if (op == 'edit') {
			$('#new_tag').show(); //
		} else if (op == 'move') {
			$('#move_selection').show(); //
		}
	});
	
	// Add getting the tags based on the context
	$('#tag_context').change( function(obj) {
		var context = $(this).val(); // get the context from the selection
		$('#context').val(context);
		$('#new_tag').val('');
		$('#original_tag').val('');
		if (context && context != '') {
			$.ajax({ 
				url: "/survey_respondents/tags/cloud?target=selection&context=" + context, 
				success: function(data){
					// set the tags within the select field
					$('#tag-list').html(data);

					$('#selectable > li').click(function(event) {
						$("#selectable").children(".ui-selected").removeClass("ui-selected"); //make all unselected
						// highlight selected only
						$(this).addClass('ui-selected');
						$('#new_tag').val($(this).text()); //
						$('#original_tag').val($(this).text());
					});
      			}
			});
		} else {
			// clear the tags from the select field
			$('#tag-list').html('')
			// and remove the context from the form
		}
	});

	$('#tagForm').ajaxForm({
		target  : '#result',
		success : function() {
			clearForm();
		}
	}
	);
	
});
