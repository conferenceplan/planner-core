/*
 * 
 */
(function($) {
$.widget( "cp.roomTable", $.cp.baseTable , {
    createColModel : function(){
        return [{
            label: 'Room Name',
            name: 'name',
            index: 'name',
            search : false,
            // width: 500,
        }, {
            label: 'Setup',
            name: 'setup.name',
            index: 'setup.name',
            search : false,
            sort : false,
        }, {
            label: 'Capacity',
            name: 'room_setup.capacity',
            index: 'room_setup.capacity',
            search : false,
            sort : false,
        }, {
            label: 'Purpose',
            name: 'purpose',
            index: 'purpose',
            search : false,
            sort : false,
        }, {
            label: 'Comment',
            name: 'comment',
            index: 'comment',
            search : false,
            sort : false,
        }];
    },

    _create : function() {
        // Prevent the table from being created
        // this._super();
    },
    
    getRoomForVenue : function(venueId) {
        // Set the URL for that we have the venue as an argument
        this.options.extraClause = "venue_id=" + venueId;
        
        // If the table already created then we just need a refresh
        if (typeof this.instantiated == 'undefined') {
            $.cp.baseTable.prototype._create.apply(this);
            this.instantiated = true;
        } else {
            // refresh the grid with the new URL
            $(this.element).setGridParam({url : this.createUrl() }).trigger("reloadGrid");
        }
    }
    
// jQuery(document).ready(function() {
    // $('#venues').venueTable('ttt');
// });
});
})(jQuery);
