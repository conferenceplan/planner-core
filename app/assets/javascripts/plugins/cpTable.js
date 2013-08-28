/*
 * Base table plugin ...
 * 
 */
(function($) {
    
    var settings = {
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
        extraClause : null
    };

    var methods = {
        
        url : function() {
            return settings['root_url'] + settings['baseUrl'] + settings['getGridData'];
        },

        //
        init : function(options) {
            settings = $.extend(settings, options);

            // ----------------------------------------------------------
            //
            var grid = this.jqGrid({
                url : $.fn.cpTable.createUrl(settings),
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
                postData : {'namesearch' : 'true'}, // TODO - check
                colModel : $.fn.cpTable.createColModel(settings),
                multiselect : settings['multiselect'],
                pager : jQuery(settings['pager']),
                rowNum : 10,
                autowidth : true,
                shrinkToFit : true,
                height : "100%",
                // rowList : [10, 20, 30],
                sortname : settings['sortname'], //'people.last_name', // TODO
                sortorder : "asc",
                viewrecords : true,
                imgpath : 'stylesheets/custom-theme/images', // TODO
                caption : settings['caption'],
                onSelectRow : function(ids) {
                    settings['selectNotifyMethod'](ids);
                    return false;
                },
            });
            

            // ----------------------------------------------------------
            // Set up the pager menu for add, delete, and search
            this.navGrid(settings['pager'], {
                view : settings['view'],
                search : settings['search'],
                del : settings['del'],
                edit : settings['edit'],
                add : settings['add'],
                refresh : settings['refresh'],
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
                    settings['clearNotifyMethod'](); 
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
                    params.url = settings['root_url'] + settings['baseUrl'] + "/" + postdata[this.id + "_id"];
                },
            }, // edit options
            {
                // add options
                width : 350,
                reloadAfterSubmit : false,
                jqModal : true,
                closeOnEscape : true,
                bottominfo : "Fields marked with (*) are required",
                afterSubmit : function(response, postdata) {
                    // TODO - error handler
                    
                    // get the id of the new entry and change the id of the
                    var res = jQuery.parseJSON( response.responseText );
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
                    params.url = settings['root_url'] + settings['baseUrl'] + "/" + postdata;
                },
            }, // del options
            {
                // view options
                jqModal : true,
                closeOnEscape : true
            });

            // ----------------------------------------------------------
            //
            this.jqGrid('filterToolbar', {
                stringResult : true,
                searchOnEnter : false,
            });
            
            return grid;
        },

        //
        destroy : function() {
            // ???
        },
        
        tagQuery : function(options) {
            var newUrl = settings['root_url'] + settings['baseUrl'] + settings['getGridData'] + "?" + options.tagQuery;
            
            this.jqGrid('setGridParam', {
                url: newUrl
            }).trigger("reloadGrid");
        }
    };

    /*
     *
     */
    
    $.fn.cpTable = function(method) {
        if (methods[method]) {
            return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
        } else if ( typeof method === 'object' || !method) {
            return methods.init.apply(this, arguments);
        } else {
            $.error('Method ' + method + ' does not exist on jQuery.cpTable');
        }
    };

    $.fn.cpTable.settings = function() {
        return settings;
    };
    
    $.fn.cpTable.createColModel = function (settings) { return null; }; // To be over-ridden
    
    $.fn.cpTable.createUrl = function (settings) {
        var url = settings['root_url'] + settings['baseUrl'] + settings['getGridData'];
        var urlArgs = "";
        if (settings['extraClause']) {
            urlArgs += '?';
            urlArgs += settings['extraClause']; 
        }
        url += urlArgs;
        return url;
    };


})(jQuery);
