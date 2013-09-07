/*
 * 
 */
(function($) {
$.widget( "cp.itemTable", $.cp.baseTable , {

    createColModel : function(){
        return [{
            label: 'Title',
            name: 'item[title]',
            index: 'programme_items.title',
            width: 500,
        }, {
            name: 'programme_item[format_name]',
            label : "Format",
            index: 'format_id',
            hidden: !this.options.format_name,
            width: 150,
            search: true,
            stype: "select",
            searchoptions: {
                dataUrl: this.options.root_url + 'formats/listwithblank'
            },
        },
        {
            label : 'Duration',
            name: 'programme_item[duration]',
            index: 'duration',
            hidden : !this.options.duration,
            width: 60,
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
        }, {
            label : 'Room',
            name: 'room',
            hidden : !this.options.room,
            sortable: false,
            search: false,
            width: 80,
            editable: false,
            edittype: "select",
            editoptions: {
                dataUrl: '/rooms/listwithblank'
            },
            formoptions: {
                rowpos: 4,
                label: "Room",
            },
            editrules: {
                required: false
            }
        }, {
            label: 'Day',
            name: 'start_day',
            hidden : !this.options.day,
            sortable: false,
            search: false,
            width: 100,
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
            label : 'Time',
            name: 'start_time',
            hidden : !this.options.time,
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
        }, {
            label : 'Ref',
            name: 'programme_item[pub_reference_number]',
            index: 'pub_reference_number',
            hidden : !this.options.ref_number,
            width: 60,
            editable: false,
            formoptions: {
                rowpos: 7,
                label: "Ref Number",
                elmprefix: "(*)"
            },
           
        },{
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
/***    
    var methods = {
        //
        init : function(options) {
            var settings = {
                baseUrl : "programme_items",
                getGridData : "/getList.json",
                multiselect : false,
                onlySurveyRespondents : false,
                // sortname : 'programme_items.title'
            };

            // cpTable = this.cpTable;
            // settings = $.extend(settings, cpTable.settings);
            settings = $.extend(settings, options);
            
            // alert(settings['sortname']);
            
            this.cpTable.createColModel = createColModel;
            // this.cpTable.createUrl = createUrl; // TODO
            tbl = this.cpTable(settings); // create th underlying table
            return tbl;
        },
        
    };

    $.fn.cpItemTable = function(method) {
        if (methods[method]) {
            return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
        } else if ( typeof method === 'object' || !method) {
            return methods.init.apply(this, arguments);
        } else {
            $.error('Method ' + method + ' does not exist on jQuery.cpItemTable');
        }
    };
***/
});
})(jQuery);
