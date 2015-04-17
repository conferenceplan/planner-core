/*
 * 
 */
(function($) {
$.widget( "cp.pendingPeopleImportTable", $.cp.baseBootstrapTable , {

    createColModel : function(){
        return [
        {
            field: 'pending_type',
            title: this.options.pending_type,
            align: 'left',
            valign: 'middle',
            sortable: true,
            formatter : function(value, row) {
                return row.pending_type ? row.pending_type : '';
            }
        }, {
            field: 'name',
            title: this.options.name,
            align: 'left',
            valign: 'middle',
            sortable: true,
            formatter : function(value, row) {
                return (row.first_name + ' ' + row.last_name + ' ' + row.suffix).trim();
            }
        }, {
            field: 'email',
            title: this.options.email,
            align: 'left',
            valign: 'middle',
            sortable: false,
            formatter : function(value, row) {
                return row.email ? row.email : '';
            }
        }, {
            field: 'registration_number',
            title: this.options.registration_number,
            align: 'left',
            valign: 'middle',
            sortable: false,
            formatter : function(value, row) {
                return row.registration_number ? row.registration_number : '';
            }
        }, {
            field: 'registration_type',
            title: this.options.registration_type,
            align: 'left',
            valign: 'middle',
            sortable: false,
            formatter : function(value, row) {
                return row.registration_type ? row.registration_type : '';
            }
        }, {
            field: 'job_title',
            title: this.options.job_title,
            align: 'left',
            valign: 'middle',
            sortable: false,
            formatter : function(value, row) {
                return row.job_title ? row.job_title : '';
            }
        }, {
            field: 'company',
            title: this.options.company,
            align: 'left',
            valign: 'middle',
            sortable: false,
            formatter : function(value, row) {
                return row.company ? row.company : '';
            }
        }, {
            field: 'address',
            title: this.options.address,
            align: 'left',
            valign: 'middle',
            sortable: false,
            formatter : function(value, row) {
                return ''; // TODO
            }
        }, {
            field: 'phone',
            title: this.options.phone,
            align: 'left',
            valign: 'middle',
            sortable: false,
            formatter : function(value, row) {
                return row.phone ? row.phone : '';
            }
        }];
    }

});

})(jQuery);

