/*
 * 
 */
(function($) {
$.widget( "cp.venueTable", $.cp.baseTable , {
    createColModel : function(){
        return [{
            label: 'Venue',
            name: 'name',
            index: 'name',
                search : false,
            // width: 500,
        }];
    }
});
})(jQuery);
