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
        root_url            : "/",              // so that sub-domains can be taken care of
        baseUrl             : "",               // HAS TO BE OVER-RIDDEN by the sub-component
        getGridData         : "",               // for getting the data (part of the URL)
        caption             : "My Table",
        delayed             : false,
        selectNotifyMethod  : function(row) {},
        extraClause         : null,
        cardView            : false,
        showRefresh         : false,
        search              : true,
        pageSize            : 10,
        pageList            : [10, 25, 50, 100, 200]
        
        // pager               : '#pager',
        // clearNotifyMethod   : function() {},
        // loadNotifyMethod    : function() {},
        // multiselect         : false,
        // sortname            : null,
        // filtertoolbar       : true,
        // showControls        : true,
        // controlDiv          : 'item-control-area', // Use this if using control and multiple grids on one page
        // modelType           : null, // Should be provided by the caller
        // modelTemplate       : null,
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
        return this.options.root_url + this.options.baseUrl + this.options.getGridData;
    },
    
    /*
     * 
     */
    createUrl : function () {
        var url = this.options.root_url + this.options.baseUrl + this.options.getGridData;
        var urlArgs = "";
        if (this.options.extraClause) {
            urlArgs += '?';
            urlArgs += this.options.extraClause; 
        };
        url += urlArgs;
        return url;
    },
    
    /*
     * 
     */
    createColModel : function() {},
    
    /*
     * 
     */
    createTable : function() {
        var selectMethod = this.options.selectNotifyMethod;
        var grid = this.element.bootstrapTable({
                url: this.createUrl(),
                onClickRow : function(row, element) {
                        $(element).parent().find('tr').removeClass('success');
                        $(element).addClass('success');
                        selectMethod(row);
                    },
                method: 'get',
                cache: false,
                striped: true,
                sidePagination: 'server',
                pagination: true,
                pageSize: this.options.pageSize,
                pageList: this.options.pageList,
                search: this.options.search,
                showRefresh: this.options.showRefresh,
                cardView: this.options.cardView,
                columns: this.createColModel(),
                searchAlign: 'left'
        });
    }
});

})(jQuery);
