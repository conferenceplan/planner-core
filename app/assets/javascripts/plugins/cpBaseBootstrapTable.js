/*
 * Base table widget ...
 * 
 */
(function($) {
    
$.widget( "cp.baseBootstrapTable" , {
    /*
     * 
     */
    options : {
        // pager               : '#pager',
        root_url            : "/",              // so that sub-domains can be taken care of
        baseUrl             : "",               // HAS TO BE OVER-RIDDEN by the sub-component
        getGridData         : "",               // for getting the data (part of the URL)
        caption             : "My Table",
        extraClause         : null,
        selectNotifyMethod  : function(row) { alert("selected"); },
        // clearNotifyMethod   : function() {},
        // loadNotifyMethod    : function() {},
        // multiselect         : false,
        // sortname            : null,
        // filtertoolbar       : true,
        // showControls        : true,
        // controlDiv          : 'item-control-area', // Use this if using control and multiple grids on one page
        // modelType           : null, // Should be provided by the caller
        // modelTemplate       : null,
        delayed             : false,
        // confirm_content     : "Are you sure you want to delete the selected data?",
        // confirm_title       : "Confirm Deletion"
    },
    
    /*
     *
     */
    _create : function() {
        if (!this.options.delayed) {
            this.createTable();
        }
    },
    
    render : function() {
        if (this.options.delayed) {
            this.createTable();
        }
    },
    
    /*
     * 
     */    
    _url : function() {
        // Determine what the URL for the table should be
        return this.options.root_url + this.options.baseUrl; // + this.options.getGridData;
    },
    
    /*
     * 
     */
    createUrl : function () {
        var url = this.options.root_url + this.options.baseUrl ;//+ this.options.getGridData;
        // var urlArgs = "";
        // if (this.options.extraClause) {
            // urlArgs += '?';
            // urlArgs += this.options.extraClause; 
        // };
        // url += urlArgs;
        return url;
    },
    
    /*
     * 
     */
    createColModel : function() {
    },
    
    /*
     * 
     */
    createTable : function() {
        var grid = this.element.bootstrapTable({
                url: this.createUrl(),
                onClickRow : function(row) { alert("row"); },   //this.selectNotifyMethod,
                method: 'get',
                cache: false,
                // height: 400, // TODO ?????
                striped: true,
                pagination: true,
                pageSize: 10,
                pageList: [10, 25, 50, 100, 200],
                search: true,
                searchAlign: 'left',
                showColumns: true,
                showRefresh: true,
                sidePagination: 'server',
                clickToSelect: true, // true for checkbox for select, i.e., for multi-select
                minimumCountColumns: 2,
                columns: this.createColModel()
        });
    }
});

})(jQuery);
