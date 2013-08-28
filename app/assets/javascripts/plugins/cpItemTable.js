/*
 * 
 */
(function($) {
    // http://sandbox.myconferenceplanning.org/programme_items/list
    var settings = {
        baseUrl : "programme_items",
        getGridData : "/getList.json",
        multiselect : false,
        onlySurveyRespondents : false,
        // sortname : 'programme_items.title'
    };
    
    var cpTable = null;


    var createColModel = function(){
        // alert(cpTable.settings()['root_url']);
        return [{
            label: 'Title',
            name: 'item[title]',
            index: 'programme_items.title',
            width: 500,
            editable: true,
            editoptions: {
                size: 20
            },
            formoptions: {
                rowpos: 1,
                label: "Title",
                elmprefix: "(*)"
            },
            editrules: {
                required: true
            }
        }, {
            label : "Format",
            name: 'programme_item[format_name]',
            index: 'format_id',
            width: 150,
            editable: true,
            edittype: "select",
            search: true,
            stype: "select",
            searchoptions: {
                dataUrl: cpTable.settings()['root_url'] + 'formats/listwithblank'
            },
            editoptions: {
                dataUrl: cpTable.settings()['root_url'] + 'formats/list',
                defaultValue: '1'
            },
            formoptions: {
                rowpos: 2,
                elmprefix: "&nbsp;&nbsp;&nbsp;&nbsp;"
            }
        // }, {
            // name: 'programme_item[format_id]',
            // index: 'format_id',
            // width: 150,
            // editable: true,
            // edittype: "select",
            // search: true,
            // stype: "select",
            // searchoptions: {
                // dataUrl: '/formats/listwithblank'
            // },
            // editoptions: {
                // dataUrl: '/formats/list',
                // defaultValue: '1'
            // },
            // formoptions: {
                // rowpos: 2,
                // elmprefix: "&nbsp;&nbsp;&nbsp;&nbsp;"
            // }
        },        //              First you need to make sure it is on a separate row - this is done via the rowpos attribute
        {
            label : 'Duration',
            name: 'programme_item[duration]',
            index: 'duration',
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
    };
    
    var methods = {
        //
        init : function(options) {
            settings = $.extend(settings, options);
            
            cpTable = this.cpTable;

            this.cpTable.createColModel = createColModel;
            // this.cpTable.createUrl = createUrl; // TODO
            tbl = this.cpTable(settings); // create th underlying table
            return tbl;
        },
        
        tagQuery : function(options) {
            this.cpTable('tagQuery',options);
        }
    };

    
    $.fn.cpItemTable = function(method) {
        if (methods[method]) {
            return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
        } else if ( typeof method === 'object' || !method) {
            return methods.init.apply(this, arguments);
        } else {
            $.error('Method ' + method + ' does not exist on jQuery.cpParticipantTable');
        }
    };

})(jQuery);
