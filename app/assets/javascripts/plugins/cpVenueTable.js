/*
 * 
 */
(function($) {
$.widget( "cp.venuesTable", $.cp.baseBootstrapTable , {

    createColModel : function(){
        return [{
            field: 'name',
            title: this.options.name,
            align: 'left',
            valign: 'middle',
            sortable: false,
        }
        ];
    }

});

})(jQuery);
