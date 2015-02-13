/*
 * 
 */
(function($) {
$.widget( "cp.mailHistoryTable", $.cp.baseTable , {

    createColModel : function() {
        return [{
                name : 'item[name]',
                label : this.options.name[1], //'Name',
                index : 'people.last_name',
                hidden : !this.options.name[0],
                editable : false,
                formatter : function(cellvalue, options, rowObject) {
                    var res = "";
                    
                    if (typeof rowObject['item[person][pseudonym_attributes][first_name]'] != 'undefined') {
                        res += rowObject['item[person][pseudonym_attributes][first_name]'];
                    };
                    if (typeof rowObject['item[person][pseudonym_attributes][last_name]'] != 'undefined') {
                        res += ' ';
                        res += rowObject['item[person][pseudonym_attributes][last_name]'];
                    };
                    if (typeof rowObject['item[person][pseudonym_attributes][suffix]'] != 'undefined') {
                        res += ' ';
                        res += rowObject['item[person][pseudonym_attributes][suffix]'];
                    };
                    
                    if (res.length > 0) {
                        res += "<br/>(" + rowObject['item[person][first_name]'] + ' ' + rowObject['item[person][last_name]'] + ' ' + rowObject['item[person][suffix]'] + ")";
                    } else {
                        res = rowObject['item[person][first_name]'] + ' ' + rowObject['item[person][last_name]'] + ' ' + rowObject['item[person][suffix]'];
                    }
                    
                    return res;
                }
            }, {
                name : 'item[mailing]',
                label : this.options.mailing[1],
                index : 'mailing_id',
                hidden : !this.options.mailing[0],
                editable : false,
                sortable : true,
                search : true,
                stype : "select",
                searchoptions : {
                    dataUrl: this.options.root_url + "communications/mailing/listWithBlank"
                },
                width : 100,
                formatter : function(cellvalue, options, rowObject) {
                    var res = "";
                    res += rowObject['item[mailing][mailing_number]'];
                    res += ' - ' + rowObject['item[mailing][mail_use]'];
                    return res;
                }
            }, {
                name : 'item[content]',
                label : this.options.content[1],
                hidden : !this.options.content[0],
                editable : false,
                sortable : false,
                search : false,
                width : 200
            }, {
                name : 'item[email_status]',
                label : this.options.status[1],
                hidden : !this.options.status[0],
                editable : false,
                sortable : false,
                search : false,
                width : 50
            }, {
                name : 'item[date_sent]',
                index : 'created_at',
                label : this.options.date_sent[1],
                hidden : !this.options.date_sent[0],
                editable : false,
                sortable : true,
                search : false,
                width : 70
            }, {
                name : 'item[testrun]',
                label : this.options.testrun[1],
                hidden : !this.options.testrun[0],
                align : 'center',
                editable : false,
                sortable : false,
                search : false,
                width : 50
            }];
    },
    
    createUrl : function () {
        var url = this.options.root_url + this.options.baseUrl + this.options.getGridData;
        var urlArgs = "";
        if (this.options.extraClause) {
            urlArgs += '?';
        }
        if (this.options.extraClause) {
            urlArgs += this.options.extraClause; 
        }
        url += urlArgs;
        return url;
    },
    
    personQuery : function(options) {
        this.options.extraClause = "person_id=" + options.personId;
        if (options.op) {
            this.options.extraClause += '&op=' + options.op; 
        }

        if (!this.options.delayed) {
            var newUrl = this.options.root_url + this.options.baseUrl + this.options.getGridData + "?" + this.options.extraClause;
                
            this.element.jqGrid('setGridParam', {
                url: newUrl
            }).trigger("reloadGrid");
        }
    }
    
});
})(jQuery);
