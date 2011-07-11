/*
 *
 */
jQuery(document).ready(function(){
	
	var setupGrid = function
	(
		room_id				// Id of the room this set of room setups applies to
	){
        var index = 0;
		var columns = [];
		var pickroom = 'rooms/picklist?room_id=' + room_id;

		var rooms = $.planIt.select(['room_setups', 'room_id'], 255, 0, "Room:", false, pickroom);
		rooms.editable = false;
		columns[index++] = rooms;
		
		columns[index++] = $.planIt.select(['room_setups', 'setup_type_id'], 225, 1, "Setup type:", true, 'setup_types/picklist');
		columns[index++] = $.planIt.textSearch(['room_setups', 'capacity'], 225, 2, "Capacity:", true);
		columns[index++] = $.planIt.checkbox(['default_setup'], 225, 3, "Default:", false);
		columns[index++] = $.planIt.hidden(['room_setups', 'lock_version']);
		
	    var colNames = ['Room', 'Type', 'Capacity', 'Default', 'lock_version'];
	 	
	    var params = $.planIt.gridParams('room_setups', 'room_setups_id', colNames, columns, 'Room Setups');
	    params.url = 'room_setups/list/?room_id=' + room_id;
	    params.editurl = 'room_setups/?room_id=' + room_id;
		params.pager = "#setups_pager";
		

		jQuery("#room_setups").jqGrid(params);

        // Set up the pager menu for edit, add, and delete

		var editFetch = function(postData)
		{
			return postData.room_setups_id;
		};

    	var edit = $.planIt.editOptions('room_setups', editFetch);
    	var add = $.planIt.addOptions('room_setups');
    	var del = $.planIt.deleteOptions('room_setups');
    	
        jQuery("#room_setups").navGrid('#setups_pager', {search:false, view:false}, edit, add, del);
	};
	
	var clearGrid = function()
	{
		jQuery('#setups').html('<table id="room_setups"></table><div id="setups_pager"></div>');
	};
	
    // The grid containing the list of rooms
	
	var index = 0;
	var columns = [];
	columns[index++] = $.planIt.textSearch(['room', 'name'], 125, 1, "Name:", true);
	
	var venue = $.planIt.select(['room', 'venue_id'], 125, 2, "Venue:", true, 'venue/list');
	venue.index ='venues.name';
	columns[index++] = venue;
	
	var setup = $.planIt.textSearch(['room', 'setup_types.name'], 125, 3, "Room Setup:", false);
	setup.editable = false;
	columns[index++] = setup;
	
	var capacity = $.planIt.numberSearch(['room', 'room_setups.capacity'], 125, 4, "Capacity:", false);
	capacity.editable = false;
	columns[index++] = capacity;
	
	columns[index++] = $.planIt.textSearch(['room', 'purpose'], 125, 5, "Purpose:", false);
	columns[index++] = $.planIt.textarea(['room', 'comment'], 125, 6, "Comment:", false);
	columns[index++] = $.planIt.hidden(['room', 'id']);
	columns[index++] = $.planIt.hidden(['room', 'lock_version']);
	
    var colNames = ['Room Name', 'Venue', 'Setup', 'Capacity', 'Purpose', 'Comment', 'room_id', 'lock_version'];
 	
    var params = $.planIt.gridParams('rooms', 'room_id', colNames, columns, 'Rooms');

    params.onSelectRow = function (id) {
    	var room_id;
        if (id == null) {
        	clearGrid();
        }
        else {
        	var row_data = jQuery("#rooms").getRowData(id);
        	room_id = row_data["room[id]"];
        	clearGrid();
        	setupGrid(room_id);
        }
    }
    
    params.loadComplete = function(){
    	clearGrid();
    }
    
    jQuery("#rooms").jqGrid(params);
    
	var editFetch = function(postData)
	{
		return postData.rooms_id;
	};

    // Set up the pager menu

	var edit = $.planIt.editOptions('rooms', editFetch);
	var add = $.planIt.addOptions('rooms');
	var del = $.planIt.deleteOptions('rooms');
	var search = $.planIt.searchOptions();
	var view = $.planIt.viewOptions("Rooms");
	
    jQuery("#rooms").navGrid('#pager', {}, edit, add, del, search, view);
});

