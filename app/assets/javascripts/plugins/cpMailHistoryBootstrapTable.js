/*
 * 
 */
(function($) {
$.widget( "cp.mailHistoryBootstrapTable", $.cp.baseBootstrapTable , {

    createColModel : function(){
        that = this;
        return [{
            field: 'Mailing',
            title: this.options.mailing,
            align: 'left',
            valign: 'middle',
            sortable: false,
            formatter : function(value, row) {
                if (typeof row.mailing.mail_use === 'undefined') {
                    return "";
                } else {
                    return '<a href="#"><b>' + row.mailing.mailing_number + ' - ' + row.mailing.title + '</b></a>';
                }
            }
        },
        {
            field: 'date_sent',
            title: this.options.date_sent,
            align: 'left',
            valign: 'middle',
            sortable: false,
            formatter : function(value, row) {
                if (typeof row.date_sent === 'undefined') {
                    return "";
                } else {
                    return moment(row.date_sent).format("dddd, D MMM YYYY");
                }
            }
        },
        {
            field: 'email_status',
            title: this.options.email_status,
            align: 'left',
            valign: 'middle',
            sortable: false,
            formatter : function(value, row) {
                if (typeof row.email_status === 'undefined') {
                    return "";
                } else if (row.email_status == 'Sent') {
                    return that.translate("email_sent");
                } else {
                    return row.email_status;
                }
            }
        }
        ];
    },

    /*
     * 
     */
    personHistory : function(options) {
        this.options.extraClause = "person_id=" + options.person_id;

        if (!this.options.delayed) {
            this.reset();
        } else {
            this.render();
        }
    },


});

})(jQuery);
