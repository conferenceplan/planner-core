/*
 *
 */

(function($) {    

$.widget( "cp.participantTable", $.cp.baseTable , {
    
    options : {
        includeMailings : false
    },

        createColModel : function(){
            var that = this;
            return [{
                name : 'identifier',
                label : this.options.name[1], //'Name',
                index : 'people.last_name',
                // hidden : false,
                hidden : !this.options.name[0],
                editable : false,
                clearSearch : false,
                searchoptions : {
                    clearSearch : false
                },
                formatter : function(cellvalue, options, rowObject) {
                    var res = "";
                    
                    if (typeof rowObject['person[pseudonym_attributes][prefix]'] != 'undefined') {
                        if (rowObject['person[pseudonym_attributes][prefix]']) {
                            res += rowObject['person[pseudonym_attributes][prefix]'];
                        }
                    };
                    if (typeof rowObject['person[pseudonym_attributes][first_name]'] != 'undefined') {
                        if (rowObject['person[pseudonym_attributes][first_name]']) {
                            if (res.length > 0) {
                                res += ' ';
                            }
                            res += rowObject['person[pseudonym_attributes][first_name]'];
                        }
                    };
                    if (typeof rowObject['person[pseudonym_attributes][last_name]'] != 'undefined') {
                        if (rowObject['person[pseudonym_attributes][last_name]']) {
                            if (res.length > 0) {
                                res += ' ';
                            }
                            res += rowObject['person[pseudonym_attributes][last_name]'];
                        }
                    };
                    if (typeof rowObject['person[pseudonym_attributes][suffix]'] != 'undefined') {
                        if (rowObject['person[pseudonym_attributes][suffix]']) {
                            if (res.length > 0) {
                                res += ' ';
                            }
                            res += rowObject['person[pseudonym_attributes][suffix]'];
                        }
                    };
                    var name = (rowObject['person[prefix]'] + ' ' + rowObject['person[first_name]'] + ' ' + rowObject['person[last_name]'] + ' ' + rowObject['person[suffix]']).trim();
                    
                    if (res.length > 0) {
                        res += " (" +  name + ")";
                    } else {
                        res = name;
                    };
                    
                    if (typeof rowObject['email_addresses'] != 'undefined') {
                        if (rowObject['email_addresses'].length > 0) {
                            res += " <span class='medium-text'>- ";
                            for (i = 0 ; i < rowObject['email_addresses'].length; i++) {
                                if (i > 0) {
                                    res += ",";
                                }
                                res += rowObject['email_addresses'][i];
                            }
                            res += "</span>";
                        }
                    }
                    
                    return res;
                }
            }, {
                name : 'emails',
                hidden : true,
                formatter : function(cellvalue, options, rowObject) {
                    var res = "";
                    if (typeof rowObject['email_addresses'] != 'undefined') {
                        if (rowObject['email_addresses'].length > 0) {
                            for (i = 0 ; i < rowObject['email_addresses'].length; i++) {
                                if (i > 0) {
                                    res += ",";
                                }
                                res += rowObject['email_addresses'][i];
                            }
                        }
                    }
                    return res;
                }
            }, {
                name : 'person[first_name]',
                label : 'First Name',
                // index : 'people.first_name',
                hidden : true, //!settings['first_name'],
                width : 225,
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
                name : 'person[prefix]',
                label : 'Prefis',
                index : 'people.prefix',
                hidden : true, //!settings['prefix'],
                editable : true,
                search : false,
                editoptions : {
                },
                formoptions : {
                    rowpos : 3,
                    label : "Prefix",
                },
                editrules : {
                    required : false,
                    edithidden : true
                }
            }, {
                name : 'person[invitestatus_id]',
                label : this.options.invite_status[1], //'Invite Status',
                index : 'person_con_states.invitestatus_id',
                hidden : !this.options.invite_status[0],
                editable : true,
                edittype : "select",
                search : true,
                stype : "select",
                width : 60,
                searchoptions : {
                    dataUrl: this.options.root_url + "participants/invitestatuslistwithblank",
                    clearSearch : false
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
                },
                formatter : function(cellvalue, options, rowObject) {
                    res = "";
                    if (typeof rowObject['person[invitestatus_id]'] != 'undefined') {
                        if (rowObject['person[invitestatus_id]'] == 'Not Set') {
                            res = "<span class='minor-text'>" + that.translate("invite_not_set") + "</span>";
                        } else {
                            res =  that.translate("invite_status_" + rowObject['person[invitestatus_id]'].toLowerCase().replace(/ /g,"_"));    
                        }
                    }
                    return res;
                }                
            }, {
                name : 'person[invitation_category_id]',
                label : this.options.invite_category[1], //'Invitation<br/>Category',
                index : 'person_con_states.invitation_category_id',
                hidden : !this.options.invite_category[0],
                editable : true,
                edittype : "select",
                search : true,
                stype : "select",
                width : 50,
                searchoptions : {
                    dataUrl: this.options.root_url + "invitation_categories/list",
                    clearSearch : false
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
                index : 'person_con_states.acceptance_status_id',
                hidden : !this.options.acceptance_status[0],
                editable : true,
                edittype : "select",
                search : true,
                stype : "select",
                width : 50,
                searchoptions : {
                    dataUrl: this.options.root_url + "participants/acceptancestatuslistwithblank",
                    clearSearch : false
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
                },
                formatter : function(cellvalue, options, rowObject) {
                    res = "";
                    if (typeof rowObject['person[acceptance_status_id]'] != 'undefined') {
                        if (rowObject['person[acceptance_status_id]'] == 'Unknown') {
                            res = "<span class='minor-text'>" + that.translate("acceptance_unknown") + "</span>";
                        } else if (rowObject['person[acceptance_status_id]'] == 'Accepted') {
                            res = "<span class='label label-success'><span class='glyphicon glyphicon-ok'></span> " + that.translate("acceptance_accepted") +  "</span>";
                        } else if (rowObject['person[acceptance_status_id]'] == 'Declined') {
                            res = "<span class='label label-danger'><span class='glyphicon glyphicon-remove'></span> " + that.translate("acceptance_declined") +  "</span>";
                        } else if (rowObject['person[acceptance_status_id]'] == 'Probable') {
                            res = "<span class='label label-warning'> " + that.translate("acceptance_probable") +  "</span>";
                        }
                        else {
                            res =  rowObject['person[acceptance_status_id]'];    
                        }
                    }
                    return res;
                }
            }, {
                name : 'person[mailings]',
                label : this.options.mailings[1], //'mailings',
                index : 'mailing_id',
                hidden : !this.options.mailings[0],
                editable : false,
                sortable : false,
                search : true,
                stype : "select",
                searchoptions : {
                    dataUrl: this.options.root_url + "communications/mailing/listWithBlank",
                    clearSearch : false
                },
                width : 100,
                formatter : function(cellvalue, options, rowObject) {
                    var res = "";
                    var numberOfEmailsSent = 0;
                    
                    if (typeof rowObject['person[mailings]'] != 'undefined') {
                        for (i = 0 ; i < rowObject['person[mailings]'].length; i++) {
                            numberOfEmailsSent +=1;
                            if (i > 0) {
                                res += ", ";
                            }
                            res += rowObject['person[mailings]'][i].mailing_number;
                            res += ' - ' + rowObject['person[mailings]'][i].mail_use;
                        }
                    }
                    
                   return res;
                }
            }, {
                name : 'person[mail_history]',
                label : this.options.mail_history[1], //'mailings',
                index : 'mailing_id',
                hidden : !this.options.mail_history[0],
                editable : false,
                sortable : false,
                search : true,
                stype : "select",
                searchoptions : {
                    dataUrl: this.options.root_url + "communications/mailing/listWithBlank",
                    clearSearch : false
                },
                width : 100,
                formatter : function(cellvalue, options, rowObject) {
                    var res = "";
                    var nbEmails = 0;
                    var emailDescString = "";
                    /*
                    if (typeof rowObject['person[mail_history]'] != 'undefined') {
                        for (i = 0 ; i < rowObject['person[mail_history]'].length; i++) {
                            if (i > 0) {
                                res += ",<br>";
                            }
                            res += rowObject['person[mail_history]'][i];
                        }
                    }
                    */
                   if (typeof rowObject['person[mail_history]'] != 'undefined') {
                        nbEmails = rowObject['person[mail_history]'].length;
                        if (nbEmails < 1) {
                            res = '';
                        } else if (nbEmails == 1) {
                            res = rowObject['person[mail_history]'][0];   
                        } else if (nbEmails > 1) {
                            emailDescString = rowObject['person[mail_history]'][nbEmails - 1]; // only display the most recent one sent
                            if (emailDescString.length > 25) { emailDescString = emailDescString.substr(0,25) + "..."; };
                            res = emailDescString + ' + ' + (nbEmails - 1) + ' ' + that.translate("participant_email_more");  
                        }
                   }
                   
                   return res;
                }
            }, {
                name : 'person[reg_type]',
                index : 'registration_details.registration_type',
                label : this.options.reg_type[1], //'Survey',
                hidden : !this.options.reg_type[0],
                editable : false,
                sortable : true,
                search : true,
                searchoptions : {
                    clearSearch : false
                },
                align : 'right',
                width : 50
            }, {
                name : 'person[has_survey]',
                label : this.options.has_survey[1], //'Survey',
                hidden : !this.options.has_survey[0],
                editable : false,
                sortable : false,
                search : false,
                align : 'center',
                width : 28,
                formatter : function(cellvalue, options, rowObject) {
                    if (typeof rowObject['person[has_survey]'] != 'undefined') {
                        if (rowObject['person[has_survey]'] == 'Y') {
                            res = "<span class='glyphicon glyphicon-ok'></span>";    
                        } else {
                            res = "";
                        }
                        
                    }
                    return res;
                }
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
                name : 'person[pseudonym_attributes][prefix]',
                label : 'Publication<br/>Prefix',
                index : 'pseudonyms.prefix',
                hidden : true, //!settings['pub_suffix'],
                editable : true,
                sortable : false,
                search : false,
                editoptions : {
                },
                formoptions : {
                    rowpos : 9,
                    label : "Pub Prefix"
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
            prefix : this.element.jqGrid('getCell', id, 'person[prefix]'),
            first_name : this.element.jqGrid('getCell', id, 'person[first_name]'),
            last_name : this.element.jqGrid('getCell', id, 'person[last_name]'),
            suffix : this.element.jqGrid('getCell', id, 'person[suffix]'),

            pub_prefix : this.element.jqGrid('getCell', id, 'person[pseudonym_attributes][prefix]'),
            pub_first_name : this.element.jqGrid('getCell', id, 'person[pseudonym_attributes][first_name]'),
            pub_last_name :this.element.jqGrid('getCell', id, 'person[pseudonym_attributes][last_name]'),
            pub_suffix :this.element.jqGrid('getCell', id, 'person[pseudonym_attributes][suffix]')
        };
    },
    
    createUrl : function () {
        var url = this.options.root_url + this.options.baseUrl + this.options.getGridData;
        var urlArgs = "";
        if (this.options.extraClause || this.options.onlySurveyRespondents || this.options.includeMailings || this.options.includeMailHistory || this.options.tagQuery) {
            urlArgs += '?';
        }
        if (this.options.extraClause) {
            urlArgs += this.options.extraClause; 
        }
        if (this.options.tagQuery) {
            if (urlArgs.length > 0) {
                urlArgs += "&";
            }
            urlArgs += this.options.tagQuery; 
        }
        if (this.options.includeMailings) {
            if (urlArgs.length > 1) {
                urlArgs += "&";
            }
            urlArgs += "includeMailings=true";
        }
        if (this.options.includeMailHistory) {
            if (urlArgs.length > 1) {
                urlArgs += "&";
            }
            urlArgs += "includeMailHistory=true";
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
    filterPeople : function(do_filter) {
        if (this.options.extraClause && (this.options.extraClause.length > 0)) {
            this.options.extraClause += "&only_relevent=" + do_filter;
        } else {
            this.options.extraClause = "only_relevent=" + do_filter;
        }

        if (!this.options.delayed) {
            var newUrl = this.createUrl();

            this.element.jqGrid('setGridParam', {
                url: newUrl,
                contentType : 'application/x-www-form-urlencoded; charset=UTF-8'
            }).trigger("reloadGrid");
        }
    },
    
    /*
     * 
     */
    emailQuery : function(email) {
        if (this.options.extraClause && (this.options.extraClause.length > 0)) {
            this.options.extraClause += "&email=" + email;
        } else {
            this.options.extraClause = "email=" + email;
        }

        if (!this.options.delayed) {
            var newUrl = this.createUrl();
                
            this.element.jqGrid('setGridParam', {
                url: newUrl,
                contentType : 'application/x-www-form-urlencoded; charset=UTF-8'
            }).trigger("reloadGrid");
        }
    },

    /*
     * 
     */
    mailingQuery : function(options) {
        this.options.extraClause = "mailing_id=" + options.mailingId;
        if (options.op) {
            this.options.extraClause += '&op=' + options.op; 
        }

        if (!this.options.delayed) {
            var newUrl = this.options.root_url + this.options.baseUrl + this.options.getGridData + "?" + this.options.extraClause;
                
            this.element.jqGrid('setGridParam', {
                url: newUrl
            }).trigger("reloadGrid");
        }
    },

});
}(jQuery));
