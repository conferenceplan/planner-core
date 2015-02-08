/*
 * 
 */
(function($) {
$.widget( "cp.itemTable", $.cp.baseTable , {

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
            cellattr : function(rowId, val, rawObject) { // TODO - see if we can move out as an option
                return 'class="ui-draggable"';
            }
        }, {
            name: 'programme_item[format_name]',
            label : this.options.format_name[1], //"Format",
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
        /*
         {
            label : this.options.ref_number[1], //'Ref',
            name: 'programme_item[pub_reference_number]',
            index: 'pub_reference_number',
            hidden : !this.options.ref_number[0],
            width: 60,
            editable: false,
            searchoptions: {
                clearSearch : false
            },
            formoptions: {
                rowpos: 7,
                label: "Ref Number",
                elmprefix: "(*)"
            },
           
        }
        
        ,
        */
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
        }];
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
        if (this.options.extraClause || this.options.onlySurveyRespondents) {
            urlArgs += '?';
        }
        if (this.options.extraClause) {
            urlArgs += this.options.extraClause; 
        }
        if (this.options.ignoreScheduled) {
            if (urlArgs.length > 0) {
                urlArgs += "&";
            }
            urlArgs += "igs=true"; 
        }
        url += urlArgs;
        return url;
    },
    
    pageTo : function(mdl) {
        return mdl.get('title');
    },
    
});
})(jQuery);
