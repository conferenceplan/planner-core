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
            width: 450,
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
            index: 'format_id',
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
            editable: false,
            edittype: "select",
            editoptions: {
                dataUrl: '/rooms/listwithblank'
            },
            formoptions: {
                label: "Room",
            },
            editrules: {
                required: false
            }
        }, {
            label: this.options.day[1], //'Day',
            name: 'start_day',
            hidden : !this.options.day[0],
            sortable: false,
            search: false,
            width: 80,
            editable: false,
            edittype: "select",
            editoptions: {
                value: "-1:;0:Wednesday;1:Thursday;2:Friday;3:Saturday;4:Sunday"
            },
            formoptions: {
                rowpos: 5,
                label: "Day",
            },
            editrules: {
                required: false
            }
        }, {
            label : this.options.time[1], //'Time',
            name: 'start_time',
            hidden : !this.options.time[0],
            sortable: false,
            search: false,
            width: 60,
            editable: false,
            editoptions: {
                size: 20
            },
            formoptions: {
                rowpos: 6,
                label: "Start Time",
            },
            editrules: {
                required: false
            }
        },
        {
            label : this.options.duration[1], //'Duration',
            name: 'programme_item[duration]',
            index: 'duration',
            hidden : !this.options.duration[0],
            width: 70,
            searchoptions: {
                clearSearch : false
            },
            editable: true,
            editoptions: {
                size: 20
            },
            formoptions: {
                rowpos: 3,
                label: "Duration",
                elmprefix: "(*)"
            },
            editrules: {
                required: true
            }
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
            editable: true,
            sortable: false,
            search: false,
            formoptions: {
                rowpos: 8,
                label: "lock"
            }
        },
        {
            name: 'children',
            width: 3,
            index: 'children',
            hidden: true,
            editable: true,
            sortable: false,
            search: false,
            formoptions: {
                rowpos: 9,
                label: "children"
            }
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

        // collapse the other grids that are open
        parentGrid.find("tr:has(.sgexpanded)").each(function () {
            num = $(this).attr('id');
            parentGrid.collapseSubGridRow(num);
        });
        
        subgrid_table_id = subgrid_id+"_t";
        
        pager_id = "p_"+subgrid_table_id; 
        $("#"+subgrid_id).html("<table id='"+subgrid_table_id+"' class='scroll cp_subgrid'></table><div id='"+pager_id+"' class='scroll'></div>"); 
        var subgrid = jQuery("#"+subgrid_table_id).jqGrid({ 
                url             : sub_url + "?id="+row_id, 
                datatype        : "JSON", 
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
                                        editable: true,
                                        sortable: false,
                                        search: false,
                                        formoptions: {
                                            rowpos: 8,
                                            label: "lock"
                                        }
                                    }],
                sortname        : tbl.itemTable('option','sortname'),
                sortorder       : "asc",
                height          : '100%',
                autowidth       : true,
                editurl         : tbl.itemTable('editUrl'),
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
                    if (control.model) {
                        subgrid.setSelection(control.model.id);
                    }
                }
        });
    },

    createSubgridColModel : function() {
        return this.createColModel();
        // return [
            // { 
                // name : [this.options.title[1], this.options.format_name[1], this.options.duration[1]], 
                // width : [55,200,80]
            // }
        // ];
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
