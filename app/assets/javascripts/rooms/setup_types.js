/*
 *		Setup type grid definition
 */

jQuery(document).ready(function(){
    // The grid containing the list of room setup types
	
	var index = 0;
	var columns = [];
	columns[index++] = $.planIt.textSearch(['setup_type', 'name'], 225, 1, "Name:", true);
	columns[index++] = $.planIt.textSort(['setup_type', 'description'], 325, 2, "Description:", false);
	columns[index++] = $.planIt.hidden(['setup_type', 'lock_version']);
	
    var colNames = ['Name', 'Description', 'lock_version'];
 	
    var params = $.planIt.gridParams('setup_types', 'setup_type_id', colNames, columns, 'Room Setup Types');
	jQuery("#setup_types").jqGrid(params);
    
	var editFetch = function(postData)
	{
		return postData.setup_types_id;
	}

    // Set up the pager menu for edit, add, and delete

	var edit = $.planIt.editOptions('setup_types', editFetch);
	var add = $.planIt.addOptions('setup_types');
	var del = $.planIt.deleteOptions('setup_types');
	
    jQuery("#setup_types").navGrid('#pager', {search:false, view:false}, edit, add, del);
});

