/*
 *
 */
(function($) {
    var settings = {
        pager : '#pager',
        root_url : "/",
        baseUrl : "participants/getList.json",
        caption : "Participants",
        selectNotifyMethod : function(ids) {},
        first_name : true,
        last_name : true,
        suffix : true,
        view : false,
        search : false,
        del : true,
        edit : true,
        add : true,
        refresh : false,
        multiselect : false,
        extraClause : null,
        onlySurveyRespondents : false
    };

    /*
     *
     */
    var methods = {

        //
        init : function(options) {
            settings = $.extend(settings, options);

            var url = settings['root_url'] + settings['baseUrl'];
            var urlArgs = ""
            if (settings['extraClause'] || settings['onlySurveyRespondents']) {
                urlArgs += '?';
            }
            if (settings['extraClause']) {
                urlArgs += settings['extraClause']; 
            }
            if (settings['onlySurveyRespondents']) {
                if (urlArgs.length > 0) {
                    urlArgs += "&"
                }
                urlArgs += "onlySurveyRespondents=true"; 
            }
            url += urlArgs;
            
            var colModel = [{
                name : 'first_name',
                label : 'First Name',
                index : 'people.first_name',
                hidden : !settings['first_name'],
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
                name : 'last_name',
                label : 'Last Name',
                index : 'people.last_name',
                hidden : !settings['last_name'],
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
                name : 'suffix',
                label : 'Suffix',
                index : 'people.suffix',
                hidden : !settings['suffix'],
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
                name : 'invite_status',
                label : 'Invite Status',
                index : 'invitestatus_id',
                hidden : !settings['invite_status'],
                editable : true,
                edittype : "select",
                search : true,
                stype : "select",
                searchoptions : {
                    dataUrl: settings['root_url'] + "participants/invitestatuslistwithblank"
                },
                editoptions : {
                    dataUrl: settings['root_url'] + "participants/invitestatuslist",
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
                name : 'invitation_category',
                label : 'Invitation<br/>Category',
                index : 'invitation_category_id',
                hidden : !settings['invite_category'],
                editable : true,
                edittype : "select",
                search : true,
                stype : "select",
                searchoptions : {
                    dataUrl: settings['root_url'] + "invitation_categories/list"
                },
                editoptions : {
                    dataUrl: settings['root_url'] + "invitation_categories/list",
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
                name : 'acceptance_status',
                label : 'Acceptance',
                index : 'acceptance_status_id',
                hidden : !settings['acceptance_status'],
                editable : true,
                edittype : "select",
                search : true,
                stype : "select",
                searchoptions : {
                    dataUrl: settings['root_url'] + "participants/acceptancestatuslistwithblank"
                },
                editoptions : {
                    dataUrl: settings['root_url'] + "participants/acceptancestatuslist",
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
                name : 'has_survey',
                label : 'Survey',
                hidden : !settings['has_survey'],
                editable : false,
                sortable : false,
                search : false,
            }, {
                name : 'pseudonym.first_name',
                label : 'Publication<br/>First Name',
                index : 'pseudonyms.first_name',
                hidden : !settings['pub_first_name'],
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
                name : 'pseudonym.last_name',
                label : 'Publication<br/>Last Name',
                index : 'pseudonyms.last_name',
                hidden : !settings['pub_last_name'],
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
                name : 'pseudonym.suffix',
                label : 'Publication<br/>Suffix',
                index : 'pseudonyms.suffix',
                hidden : !settings['pub_suffix'],
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
                name : 'comments',
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
                name : 'lock_version',
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

            // ----------------------------------------------------------
            //
            // alert(settings['colModel']);
            var grid = this.jqGrid({
                url : url,
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
                colModel : colModel,
                multiselect : settings['multiselect'],
                pager : jQuery(settings['pager']),
                rowNum : 10,
                autowidth : true,
                shrinkToFit : true,
                height : "100%",
                rowList : [10, 20, 30],
                sortname : 'people.last_name',
                sortorder : "asc",
                viewrecords : true,
                imgpath : 'stylesheets/custom-theme/images', // TODO
                caption : settings['caption'],
                editurl : settings['root_url'] + "participants?plain=true",
                // postData : {"field":"acceptance_status_id","op":"eq","data":"8"},
                onSelectRow : function(ids) {
                    settings['selectNotifyMethod'](ids);
                    return false;
                }
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
                    // examine return for problem - look for errorExplanation in the returned HTML
                    var text = $(response.responseText).find(".errorExplanation");
                    if (text.size() > 0) {
                        text.css('font-size', '6pt');
                        text = $("<div></div>").append(text);
                        return [false, text.html()];
                    }
                    return [true, "Success", ""];
                },
                mtype : 'PUT',
                onclickSubmit : function(params, postdata) {
                    params.url = settings['root_url'] + "participants/" + postdata.participants_id;
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
                    // examine return for problem - look for errorExplanation in the returned HTML
                    var text = jQuery(response.responseText).find(".errorExplanation");
                    if (text.size() > 0) {
                        text.css('font-size', '6pt');
                        text = jQuery("<div></div>").append(text);
                        return [false, text.html()];
                    };

                    // get the id of the new entry and change the id of the
                    var id = jQuery(response.responseText).find("#personid");

                    return [true, "Success", id.text()];
                    // Last param is the id of the new item
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
                    params.url = settings['root_url'] + "participants/" + postdata;
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
        }
    };

    /*
     *
     */
    $.fn.cpParticipantTable = function(method) {
        if (methods[method]) {
            return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
        } else if ( typeof method === 'object' || !method) {
            return methods.init.apply(this, arguments);
        } else {
            $.error('Method ' + method + ' does not exist on jQuery.cpParticipantTable');
        }
    };
})(jQuery);
