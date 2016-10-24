/*
 * 
 */
(function($) {
$.widget( "cp.roomsTable", $.cp.baseBootstrapTable , {

    createColModel : function(){
        return [
        {
            align: 'center',
            valign: 'top',
            formatter : function(value, row) {
                return '<span class="grippy"></span>';
            }
        },{
            field: 'name',
            title: this.options.name,
            align: 'left',
            valign: 'middle',
            sortable: false,
        },{ // Default setup
            field: 'setup', // setup.name
            title: this.options.default_setup,
            visible: this.options.show_setup,
            align: 'left',
            valign: 'middle',
            sortable: false,
            formatter : function(value, row) {
                if (row.setup) {
                    if (typeof row.setup.name === 'undefined') {
                        return "";
                    } else {
                        return row.setup.name;
                    }
                } else {
                    return "";
                };
            }
        },{ // Capacity
            field: 'capacity', // room_setup.capacity
            title: this.options.capacity,
            visible: this.options.show_setup,
            align: 'left',
            valign: 'middle',
            sortable: false,
            formatter : function(value, row) {
                if (row.setup) {
                    if (typeof row.room_setup.capacity === 'undefined') {
                        return "";
                    } else {
                        return row.room_setup.capacity;
                    }
                } else {
                    return "";
                };
            }
        },{
            field: 'purpose',
            title: this.options.purpose,
            align: 'left',
            valign: 'middle',
            sortable: false
        },{
            field: 'comment',
            title: this.options.comment,
            align: 'left',
            valign: 'middle',
            sortable: false
        }
        ];
    }

});

})(jQuery);
