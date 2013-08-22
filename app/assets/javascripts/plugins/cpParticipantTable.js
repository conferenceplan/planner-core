/*
 *
 */
(function($) {
    var settings = {
        baseUrl : "participants",
        getGridData : "/getList.json",
        multiselect : false,
        onlySurveyRespondents : false
    };

    var cpTable = null;

        /*
         * retrieve the id of the element
         * this is some context within the existing plugin
         */
        var createColModel = function(){
            return [{
                label : 'Name',
                index : 'people.last_name', // TODO - we need a way to tell back end to search on name(s)
                hidden : false,
                editable : false,
                formatter : function(cellvalue, options, rowObject) {
                    var res = "";
                    
                    if (typeof rowObject['person[pseudonym_attributes][first_name]'] != 'undefined') {
                        res += rowObject['person[pseudonym_attributes][first_name]'];
                    };
                    if (typeof rowObject['person[pseudonym_attributes][last_name]'] != 'undefined') {
                        res += ' ';
                        res += rowObject['person[pseudonym_attributes][last_name]'];
                    };
                    if (typeof rowObject['person[pseudonym_attributes][suffix]'] != 'undefined') {
                        res += ' ';
                        res += rowObject['person[pseudonym_attributes][suffix]'];
                    };
                    
                    if (res.length > 0) {
                        res += "<br/>(" + rowObject['person[first_name]'] + ' ' + rowObject['person[last_name]'] + ' ' + rowObject['person[suffix]'] + ")";
                    } else {
                        res = rowObject['person[first_name]'] + ' ' + rowObject['person[last_name]'] + ' ' + rowObject['person[suffix]'];
                    }

                    
                    return res;
                }
            }, {
                name : 'person[first_name]',
                label : 'First Name',
                // index : 'people.first_name',
                hidden : true, //!settings['first_name'],
                width : 200,
                editable : true,
                editoptions : {
                },
                formoptions : {
                    rowpos : 1,
                    label : "First Name",
                },
                editrules : {
                    required : false,
                    edithidden : true
                }
            }, {
                name : 'person[last_name]',
                label : 'Last Name',
                index : 'people.last_name',
                hidden : true, //!settings['last_name'],
                editable : true,
                editoptions : {
                },
                formoptions : {
                    rowpos : 2,
                    label : "Last Name (*)",
                },
                editrules : {
                    required : true,
                    edithidden : true
                }
            }, {
                name : 'person[suffix]',
                label : 'Suffix',
                index : 'people.suffix',
                hidden : true, //!settings['suffix'],
                editable : true,
                search : false,
                editoptions : {
                },
                formoptions : {
                    rowpos : 3,
                    label : "Suffix",
                },
                editrules : {
                    required : false,
                    edithidden : true
                }
            }, {
                name : 'person[invitestatus_id]',
                label : 'Invite Status',
                index : 'invitestatus_id',
                hidden : !cpTable.settings()['invite_status'],
                editable : true,
                edittype : "select",
                search : true,
                stype : "select",
                width : 60,
                searchoptions : {
                    dataUrl: cpTable.settings()['root_url'] + "participants/invitestatuslistwithblank"
                },
                editoptions : {
                    dataUrl: cpTable.settings()['root_url'] + "participants/invitestatuslist",
                    defaultValue : 'Not Set'
                },
                formoptions : {
                    rowpos : 4,
                },
                editrules : {
                    required : false,
                    edithidden : true
                }
            }, {
                name : 'person[invitation_category_id]',
                label : 'Invitation<br/>Category',
                index : 'invitation_category_id',
                hidden : !cpTable.settings()['invite_category'],
                editable : true,
                edittype : "select",
                search : true,
                stype : "select",
                width : 60,
                searchoptions : {
                    dataUrl: cpTable.settings()['root_url'] + "invitation_categories/list"
                },
                editoptions : {
                    dataUrl: cpTable.settings()['root_url'] + "invitation_categories/list",
                    defaultValue : 'Not Set'
                },
                formoptions : {
                    rowpos : 5,
                },
                editrules : {
                    required : false,
                    edithidden : true
                }
            }, {
                name : 'person[acceptance_status_id]',
                label : 'Acceptance',
                index : 'acceptance_status_id',
                hidden : !cpTable.settings()['acceptance_status'],
                editable : true,
                edittype : "select",
                search : true,
                stype : "select",
                width : 50,
                searchoptions : {
                    dataUrl: cpTable.settings()['root_url'] + "participants/acceptancestatuslistwithblank"
                },
                editoptions : {
                    dataUrl: cpTable.settings()['root_url'] + "participants/acceptancestatuslist",
                    defaultValue : 'Not Set'
                },
                formoptions : {
                    rowpos : 6,
                },
                editrules : {
                    required : false,
                    edithidden : true
                }
            }, {
                name : 'person[has_survey]',
                label : 'Survey',
                hidden : !cpTable.settings()['has_survey'],
                editable : false,
                sortable : false,
                search : false,
                align : 'center',
                width : 40,
            }, {
                name : 'person[pseudonym_attributes][first_name]',
                label : 'Publication<br/>First Name',
                index : 'pseudonyms.first_name',
                hidden : true, //!settings['pub_first_name'],
                editable : true,
                sortable : false,
                editoptions : {
                },
                formoptions : {
                    rowpos : 7,
                    label : "Pub First Name"
                },
                editrules : {
                    required : false,
                    edithidden : true
                }
            }, {
                name : 'person[pseudonym_attributes][last_name]',
                label : 'Publication<br/>Last Name',
                index : 'pseudonyms.last_name',
                hidden : true, //!settings['pub_last_name'],
                editable : true,
                sortable : false,
                editoptions : {
                },
                formoptions : {
                    rowpos : 8,
                    label : "Pub Last Name"
                },
                editrules : {
                    required : false,
                    edithidden : true
                }
            }, {
                name : 'person[pseudonym_attributes][suffix]',
                label : 'Publication<br/>Suffix',
                index : 'pseudonyms.suffix',
                hidden : true, //!settings['pub_suffix'],
                editable : true,
                sortable : false,
                search : false,
                editoptions : {
                },
                formoptions : {
                    rowpos : 9,
                    label : "Pub Suffix"
                },
                editrules : {
                    required : false,
                    edithidden : true
                }
            }, {
                name : 'person[comments]',
                index : 'people.comments',
                hidden : true,
                editable : true,
                edittype : 'textarea',
                sortable : false,
                search : false,
                editoptions : {
                    cols : 36
                },
                editrules : {
                    edithidden : true
                },
                formoptions : {
                    rowpos : 10,
                    label : "Comments"
                },
            }, {
                name : 'person[lock_version]',
                index : 'lock_version',
                hidden : true,
                editable : true,
                sortable : false,
                search : false,
                formoptions : {
                    rowpos : 11,
                    label : "lock"
                }
            }];
        };
        
    createUrl = function (settings) {
        var url = settings['root_url'] + settings['baseUrl'] + settings['getGridData'];
        var urlArgs = "";
        if (settings['extraClause'] || settings['onlySurveyRespondents']) {
            urlArgs += '?';
        }
        if (settings['extraClause']) {
            urlArgs += settings['extraClause']; 
        }
        if (settings['onlySurveyRespondents']) {
            if (urlArgs.length > 0) {
                urlArgs += "&";
            }
            urlArgs += "onlySurveyRespondents=true"; 
        }
        url += urlArgs;
        return url;
    };


    var methods = {
        //
        init : function(options) {
            settings = $.extend(settings, options);
            
            // TODO - move the default specific to the participant table from cpTable settings to this module
            cpTable = this.cpTable;

            this.cpTable.createColModel = createColModel;
            this.cpTable.createUrl = createUrl;
            tbl = this.cpTable(settings); // create th underlying table
            return tbl;
        },
        
        tagQuery : function(options) {
            this.cpTable('tagQuery',options);
        }
    };

    
    $.fn.cpParticipantTable = function(method) {
        // return $.fn.cpTable(method);
        if (methods[method]) {
            // need to pass methods to the parent...
            // alert("gg");
            return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
        } else if ( typeof method === 'object' || !method) {
            // alert("ggh");
            return methods.init.apply(this, arguments);
        } else {
            $.error('Method ' + method + ' does not exist on jQuery.cpParticipantTable');
        }
    };


})(jQuery);
