/*
 * 
 */
(function($) {
$.widget( "cp.roomTable", $.cp.baseTable , {
    createColModel : function(){
        return [{
            label : this.options.name[1], //'Name',
            hidden : !this.options.name[0],
            // label: 'Room Name',
            name: 'name',
            index: 'name',
            search : false,
            // width: 500,
        }, {
            label : this.options.setup[1], //'Name',
            hidden : !this.options.setup[0],
            // label: 'Setup',
            name: 'setup.name',
            index: 'setup.name',
            search : false,
            sort : false,
        }, {
            label : this.options.capacity[1], //'Name',
            hidden : !this.options.capacity[0],
            // label: 'Capacity',
            name: 'room_setup.capacity',
            index: 'room_setup.capacity',
            search : false,
            sort : false,
        }, {
            label : this.options.purpose[1], //'Name',
            hidden : !this.options.purpose[0],
            // label: 'Purpose',
            name: 'purpose',
            index: 'purpose',
            search : false,
            sort : false,
        }, {
            label : this.options.comment[1], //'Name',
            hidden : !this.options.comment[0],
            // label: 'Comment',
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

    pageTo : function(mdl) {
        return mdl.get('name');
    },
    
    getRoomForVenue : function(venueId) {
        // Set the URL for that we have the venue as an argument
        this.options.extraClause = "venue_id=" + venueId;
        this.options.id = venueId;
        this.options.id_name = 'venue_id';
        
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
