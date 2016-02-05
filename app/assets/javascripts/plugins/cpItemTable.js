/*
 * 
 */
(function($) {
$.widget( "cp.itemTable", $.cp.baseTable , {

    options : {
        include_children : true
    },

    createColModel : function(){
        return [{
            label: this.options.title[1],
            hidden : !this.options.title[0],
            name: 'item[title]',
            index: 'programme_items.title',
            width: 400,
            searchoptions : {
                clearSearch : false
            },
            formatter : function(cellvalue, options, rowObject) {
                var res = "<div itemId='" + options.rowId + "'>" + cellvalue + "</div>"; // adding the item id so that drag-n-drop can use it
                return res;
            },
            cellattr : function(rowId, val, rawObject) {
                return 'class="ui-draggable"';
            }
        }, {
            name: 'programme_item[format_name]',
            label : this.options.format_name[1],
            index: 'programme_items.format_id',
            hidden: !this.options.format_name[0],
            width: 145,
            search: true,
            stype: "select",
            searchoptions: {
                dataUrl: this.options.root_url + 'formats/listwithblank',
                clearSearch : false
            },
        },
         {
            label : this.options.room[1], //'Room',
            name: 'room',
            hidden : !this.options.room[0],
            sortable: false,
            search: false,
            width: 125,
            editable: false
        }, {
            label: this.options.day[1], //'Day',
            name: 'start_day',
            hidden : !this.options.day[0],
            sortable: false,
            search: false,
            width: 130,
            editable: false
        }, {
            label : this.options.time[1], //'Time',
            name: 'start_time',
            hidden : !this.options.time[0],
            sortable: false,
            search: false,
            width: 60,
            editable: false
        },
        {
            label : this.options.duration[1], //'Duration',
            name: 'programme_item[duration]',
            index: 'programme_items.duration',
            hidden : !this.options.duration[0],
            width: 70,
            searchoptions: {
                clearSearch : false
            },
            editable: false
        },
         {
            label : this.options.nbr_participants[1], //'Ref',
            name: 'programme_item[participants]',
            hidden : !this.options.nbr_participants[0],
            sortable: false,
            search: false,
            editable: false,
            width: 60,
            formatter : function(cellvalue, options, rowObject) {
                if (typeof rowObject['programme_item[participants]'] != 'undefined') {
                    if (rowObject['programme_item[participants]'] > 0) {
                        return rowObject['programme_item[participants]'];
                    } else {
                        return "<span class='minor-text'>none</span>";
                    }
                }
            }     
        },
        {
            name: 'programme_item[lock_version]',
            width: 3,
            index: 'lock_version',
            hidden: true,
            editable: false,
            sortable: false,
            search: false
        },
        {
            name: 'children',
            width: 3,
            index: 'children',
            hidden: true,
            editable: false,
            sortable: false,
            search: false
        }];
    },

    removeSubgridIcon : function () {
        var $this = $(this);
        $this.find(">tbody>tr.jqgrow>td.ui-sgcollapsed").filter(function () {
            var rowData = $this.jqGrid("getRowData", $(this).closest("tr.jqgrow").attr("id"));
            return rowData.children == 'false';
        }).unbind("click").html("");
    },
    
    subGridRowExpandFn : function(subgrid_id, row_id) {
        var subgrid_table_id, pager_id;
        var tbl = jQuery(this).itemTable();
        var sub_url = tbl.itemTable('getSubGridUrl');
        var selectMethod = tbl.itemTable('option', 'selectNotifyMethod');
        var loadNotifyMethod = tbl.itemTable('option', 'loadNotifyMethod');
        var control =  tbl.itemTable('getControl');
        var parentGrid = jQuery(this).jqGrid(); // get the parent grid so that we can deselect if necessary
        var current_page = control.subgrid_page;
        var row_count = (typeof control.subgrid_rows != 'undefined') ? control.subgrid_rows : 10;
        
        // collapse the other grids that are open
        parentGrid.find("tr:has(.sgexpanded)").each(function () {
            num = $(this).attr('id');
            parentGrid.collapseSubGridRow(num);
        });
        
        subgrid_table_id = subgrid_id+"_t";
        
        if (control.current_grid != subgrid_table_id) {
            current_page = 1;
        };

        control.current_grid = subgrid_table_id;
        
        pager_id = "p_"+subgrid_table_id; 
        $("#"+subgrid_id).html("<table id='"+subgrid_table_id+"' class='scroll cp_subgrid'></table><div id='"+pager_id+"' class='scroll'></div>");
        var subgrid = jQuery("#"+subgrid_table_id).jqGrid({ 
                url             : sub_url + "?id="+row_id, 
                datatype        : "JSON", 
                mtype           : 'POST',
                page            : current_page,
                jsonReader      : {
                        repeatitems : false,
                        page        : "currpage",
                        records     : "totalrecords",
                        root        : "rowdata",
                        total       : "totalpages",
                        id          : "id",
                },
                colModel        : [{
                                        label: tbl.itemTable('option', 'title')[1],
                                        name: 'item[title]',
                                        index: 'programme_items.title',
                                        sortable: false,
                                        search: false,
                                        editable: false,
                                        width: 450
                                    }, {
                                        name: 'programme_item[format_name]',
                                        label : tbl.itemTable('option', 'format_name')[1],
                                        index: 'format_id',
                                        sortable: false,
                                        search: false,
                                        editable: false,
                                        width: 145
                                    },
                                    {
                                        label :  tbl.itemTable('option', 'duration')[1],
                                        name: 'programme_item[duration]',
                                        index: 'duration',
                                        sortable: false,
                                        search: false,
                                        editable: false,
                                        width: 70
                                    },
                                     {
                                        label : tbl.itemTable('option', 'nbr_participants')[1],
                                        name: 'programme_item[participants]',
                                        sortable: false,
                                        search: false,
                                        editable: false,
                                        width: 60,
                                        formatter : function(cellvalue, options, rowObject) {
                                            if (typeof rowObject['programme_item[participants]'] != 'undefined') {
                                                if (rowObject['programme_item[participants]'] > 0) {
                                                    return rowObject['programme_item[participants]'];
                                                } else {
                                                    return "<span class='minor-text'>none</span>";
                                                }
                                            }
                                        }     
                                    },
                                    {
                                        name: 'programme_items[lock_version]',
                                        width: 3,
                                        index: 'lock_version',
                                        hidden: true,
                                        editable: false,
                                        sortable: false,
                                        search: false
                                    }],
                sortname        : tbl.itemTable('option','sortname'),
                sortorder       : "asc",
                height          : '100%',
                autowidth       : true,
                editurl         : tbl.itemTable('editUrl'),
                pager           : pager_id,
                rowList         : [10, 20, 30, 60],
                rowNum          : row_count,
                onSelectRow     : function(ids) {
                    parentGrid.jqGrid('resetSelection');
                    
                    var data = jQuery("#"+subgrid_table_id).jqGrid('getRowData', ids);
                    var title = data['item[title]'];
                    var _model = selectMethod(ids, title); // get the current model and put it in the controller view
                    
                    if (_model) {
                        control.model = _model;
                        control.subgrid = subgrid_table_id;
                        control.parent_id = row_id;
                    }
                    
                    return false;
                },
                gridComplete    : function() {
                    loadNotifyMethod();
                },
                loadComplete    : function() {
                    control.subgrid_rows = subgrid.getGridParam("rowNum");
                    if (control.model) {
                        subgrid.setSelection(control.model.id, false);
                    }
                },
                onPaging : function(pgButton) {
                    var pagerId = this.p.pager.substr(1);
                    var newValue = parseInt($('input.ui-pg-input', "#pg_" + $.jgrid.jqID(pagerId)).val());
                    if (pgButton.indexOf("first") > -1) {
                        newValue = 1;
                    } else if (pgButton.indexOf("last") > -1) {
                        newValue = parseInt(subgrid.jqGrid("getGridParam", 'lastpage'));
                    } else if (pgButton.indexOf("prev") > -1) {
                        newValue = newValue - 1;
                    } else if (pgButton.indexOf("next") > -1) {
                        newValue = newValue + 1;
                    };
                    control.subgrid_page = newValue;
                }
        });
        jQuery("#"+subgrid_table_id).jqGrid('navGrid',"#"+pager_id,{edit:false,add:false,del:false,search:false});
    },

    createSubgridColModel : function() {
        return this.createColModel();
    },

    getItem : function(id) {
        // get an object that represents the person from the underlying grid - just the id and names
        return {
            id : id,
            title : jQuery(this.element.jqGrid('getCell', id, 'item[title]')).text()
        };
    },
    
    createUrl : function () {
        var url = this.options.root_url + this.options.baseUrl + this.options.getGridData;
        var urlArgs = "";
        if (this.options.extraClause || this.options.onlySurveyRespondents || this.options.include_children) {
            urlArgs += '?';
        }
        if (this.options.extraClause) {
            urlArgs += this.options.extraClause; 
        }

        if (urlArgs.length > 0) {
            urlArgs += "&";
        }
        urlArgs += this.options.include_children ? "include_children=true" : "include_children=false"; 

        if (this.options.ignoreScheduled) {
            if (urlArgs.length > 0) {
                urlArgs += "&";
            }
            urlArgs += "igs=true"; 
        }
        url += urlArgs;
        return url;
    },

    getSubGridUrl : function() {
        var url = this.options.root_url + this.options.baseUrl + this.options.subGridUrl; // + this.options.getGridData;
        return url;
    },
    
    pageTo : function(mdl) {
        return mdl.get('title');
    },
    
});
})(jQuery);
