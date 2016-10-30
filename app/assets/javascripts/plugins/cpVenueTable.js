/*
 * 
 */
(function($) {
$.widget( "cp.venuesTable", $.cp.baseBootstrapTable , {

    createColModel : function(){
        return [
        {
            align: 'center',
            valign: 'middle',
            width: '26px',
            formatter : function(value, row) {
                return '<span class="grippy"></span>';
            }
        },{
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
