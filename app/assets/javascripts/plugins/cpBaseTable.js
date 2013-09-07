/*
 * Base table widget ...
 * 
 */
(function($) {
$.widget( "cp.baseTable" , {
    
    options : {
        pager : '#pager',
        root_url : "/", // so that sub-domains can be taken care of
                baseUrl : "", // HAS TO BE OVER-RIDDEN by the sub-component
                getGridData : "", // for getting the data
                caption : "My Table",
                selectNotifyMethod : function(ids) {},
                clearNotifyMethod : function() {},
                view : false,
                search : false,
                del : true,
                edit : true,
                add : true,
                refresh : false,
                multiselect : false,
                extraClause : null,
                sortname : null
    },
    
    _create : function() {
        // create the grid that is associated with the element
        var selectMethod = this.options.selectNotifyMethod;
        var pageToMethod = this.pageTo;
        var clearNotifyMethod = this.options.clearNotifyMethod;
        var base_url = this.options.root_url + this.options.baseUrl;
        
        var grid = this.element.jqGrid({
                url : this.createUrl(),
                datatype : 'JSON',
                jsonReader : {
                    repeatitems : false,
                    page : "currpage",
                    records : "totalrecords",
                    root : "rowdata",
                    total : "totalpages",
                    id : "id",
                },
                mtype : 'POST',
                postData : {'namesearch' : 'true'},
                colModel : this.createColModel(),
                multiselect : this.options.multiselect,
                pager : jQuery(this.options.pager),
                rowNum : 10,
                autowidth : true,
                shrinkToFit : true,
                height : "100%",
                // rowList : [10, 20, 30],
                sortname : this.options.sortname,
                sortorder : "asc",
                viewrecords : true,
                imgpath : 'stylesheets/custom-theme/images', // Check if this is needed
                caption : this.options.caption,
                editurl: this.editUrl(),
                onSelectRow : function(ids) {
                    selectMethod(ids);
                    return false;
                },
                loadComplete : function(data) {
                    if (data.currentSelection) {
                        grid.setSelection(data.currentSelection);
                    };
                    grid.setGridParam({
                         postData : {page_to : null, current_selection : null},
                    });
                }
        });
        this.element.navGrid(this.options.pager, {
                view : this.options.view,
                search : this.options.search,
                del : this.options.del,
                edit : this.options.edit,
                add : this.options.add,
                refresh : this.options.refresh,
            }, //options
            {
                // edit options
                width : 350,
                reloadAfterSubmit : true,
                jqModal : true,
                closeOnEscape : true,
                closeAfterEdit : true,
                bottominfo : "Fields marked with (*) are required",
                afterSubmit : function(response, postdata) {
                    // TODO - error handler
                    clearNotifyMethod();  
                    return [true, "Success", ""];
                },
                beforeShowForm : function(form) { // change the style of the modal to make it compatible with our theme
                    var dlgDiv = $("#editmod" + grid[0].id);
                    // grid[0] is the div for the whole dialog box
                    // alert(dlgDiv[0].className); // ui-widget ui-widget-content ui-corner-all ui-jqdialog
                    // dlgDiv[0].className = "modal";
                    // alert(dlgDiv.html()); // = "HHHH"
//                     
                    // var dlgHeader = $("#edithd" + grid[0].id);
                    // dlgHeader[0].className = "modal-header";
                    // //modal-header
//                     
//                     
                    // //modal-body
                    // var dlgContent = $("#editcnt" + grid[0].id);
                    // dlgContent[0].className = "modal-body";
                    
                    
                    //modal-footer
                    
                    //modal-edit-button
                    //modal-new-button
                },
                mtype : 'PUT',
                onclickSubmit : function(params, postdata) {
                    params.url = base_url + "/" + postdata[this.id + "_id"];
                },
            }, // edit options
            {
                // add options
                width : 350,
                reloadAfterSubmit : true, // reload the grid, and we make sure we are on a page where the new item is
                jqModal : true,
                closeOnEscape : true,
                bottominfo : "Fields marked with (*) are required",
                afterSubmit : function(response, postdata) {
                    // TODO - error handler
                    
                    // get the id of the new entry and change the id of the
                    var res = jQuery.parseJSON( response.responseText );
                    grid.setGridParam({
                         postData : {
                                 page_to : pageToMethod(res), // make sure that the current page contains the selected element
                                 filters : {},
                                 current_selection : res.id // to pass back for the selection
                             },
                    });
                    grid[0].clearToolbar(); // clear the tool bar i.e make sure that there are no filters
                    
                    // TODO - If there is an active tag query we need to clear it as well TODO TODO

                    return [true, "Success", res.id];
                },
                closeAfterAdd : true
            }, // add options
            {
                // del options
                reloadAfterSubmit : false,
                jqModal : true,
                closeOnEscape : true,
                mtype : 'DELETE',
                onclickSubmit : function(params, postdata) {
                    params.url = base_url + "/" + postdata;
                },
            }, // del options
            {
                // view options
                jqModal : true,
                closeOnEscape : true
            });
            
            this.element.jqGrid('filterToolbar', {
                stringResult : true,
                searchOnEnter : false,
            });
    },
    
    // Determine what the URL for the table should be
    _url : function() {
        return this.options.root_url + this.options.baseUrl + this.options.getGridData;
    },

        tagQuery : function(options) {
            var newUrl = this.options.root_url + this.options.baseUrl + this.options.getGridData + "?" + options.tagQuery;
            
            this.element.jqGrid('setGridParam', {
                url: newUrl
            }).trigger("reloadGrid");
        },
    
    createColModel : function() {
        
    },
        
    createUrl : function () {
        var url = this.options.root_url + this.options.baseUrl + this.options.getGridData;
        var urlArgs = "";
        if (this.options.extraClause) {
            urlArgs += '?';
            urlArgs += this.options.extraClause; 
        }
        url += urlArgs;
        return url;
    },

    editUrl : function () {
        return "";
    },
    
    pageTo : function (data) {
        return "";
    }
});
})(jQuery);
