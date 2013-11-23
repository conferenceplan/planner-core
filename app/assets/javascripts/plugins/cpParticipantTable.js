/*
 *
 */

(function($) {    

$.widget( "cp.participantTable", $.cp.baseTable , {

        // TODO - we need a way to spefiy the column labels as parameters so that the i18n translations can be used
        createColModel : function(){
            return [{
                label : this.options.name[1], //'Name',
                index : 'people.last_name', // TODO - we need a way to tell back end to search on name(s)
                // hidden : false,
                hidden : !this.options.name[0],
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
                label : this.options.invite_status[1], //'Invite Status',
                index : 'invitestatus_id',
                hidden : !this.options.invite_status[0],
                editable : true,
                edittype : "select",
                search : true,
                stype : "select",
                width : 60,
                searchoptions : {
                    dataUrl: this.options.root_url + "participants/invitestatuslistwithblank"
                },
                editoptions : {
                    dataUrl: this.options.root_url + "participants/invitestatuslist",
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
                label : this.options.invite_category[1], //'Invitation<br/>Category',
                index : 'invitation_category_id',
                hidden : !this.options.invite_category[0],
                editable : true,
                edittype : "select",
                search : true,
                stype : "select",
                width : 60,
                searchoptions : {
                    dataUrl: this.options.root_url + "invitation_categories/list"
                },
                editoptions : {
                    dataUrl: this.options.root_url + "invitation_categories/list",
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
                label : this.options.acceptance_status[1], //'Acceptance',
                index : 'acceptance_status_id',
                hidden : !this.options.acceptance_status[0],
                editable : true,
                edittype : "select",
                search : true,
                stype : "select",
                width : 50,
                searchoptions : {
                    dataUrl: this.options.root_url + "participants/acceptancestatuslistwithblank"
                },
                editoptions : {
                    dataUrl: this.options.root_url + "participants/acceptancestatuslist",
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
                label : this.options.has_survey[1], //'Survey',
                hidden : !this.options.has_survey[0],
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
        },
        
    editUrl : function() {
        return this.options.root_url + "participants";
    },
    
    pageTo : function(mdl) {
        return mdl.get('last_name');
    },
    
    getPerson : function(id) {
        // get an object that represents the person from the underlying grid - just the id and names
        return {
            id : id,
            first_name : this.element.jqGrid('getCell', id, 'person[first_name]'),
            last_name : this.element.jqGrid('getCell', id, 'person[last_name]'),
            suffix : this.element.jqGrid('getCell', id, 'person[suffix]'),
            // TODO - put in the pseudonym
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
        if (this.options.onlySurveyRespondents) {
            if (urlArgs.length > 0) {
                urlArgs += "&";
            }
            urlArgs += "onlySurveyRespondents=true"; 
        }
        url += urlArgs;
        return url;
    },

    /*
     * 
     */
    mailingQuery : function(options) {
        var newUrl = this.options.root_url + this.options.baseUrl + this.options.getGridData + "?" + "mailing_id=" + options.mailingId;
        if (options.op) {
            newUrl += '&op=' + options.op; 
        }
            
        this.element.jqGrid('setGridParam', {
            url: newUrl
        }).trigger("reloadGrid");
    },

});
}(jQuery));
