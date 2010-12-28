/*
 *
 */
jQuery(document).ready(function(){
    // The grid containing the list of users
    jQuery("#users").jqGrid({
        url: '/usersadmin/list',
        datatype: 'xml',
        colNames: ['Login Id', 'Count','Failed','Current', 'Last','IP','Created','Updated', 'Password', 'Password Confirm'],
        colModel: [
		{
            name: 'user[login]',
            index: 'login',
            width: 100,
            editable: true,
            editoptions: {
                size: 20
            },
            formoptions: {
                rowpos: 1,
                label: "Login",
                elmprefix: "(*)"
            },
            editrules: {
                required: true
            }
        },{
            name: 'user[login_count]',
            index: 'login_count',
            width: 50,
            editable: false,
            editoptions: {
                size: 20
            },
            formoptions: {
                rowpos: 1,
                label: "Login Count",
            },
            editrules: {
                required: false
            }
        },{
            name: 'user[failed_login_count]',
            index: 'failed_login_count',
            width: 50,
            editable: false,
        },{
            name: 'user[current_login_at]',
            index: 'current_login_at',
            width: 170,
            editable: false,
        },{
            name: 'user[last_login_at]',
            index: 'last_login_at',
            width: 170,
            editable: false,
        },{
            name: 'user[last_login_ip]',
            index: 'last_login_ip',
            width: 100,
            editable: false,
        },{
            name: 'user[created_at]',
            index: 'created_at',
            width: 170,
            editable: false,
        },{
            name: 'user[updated_at]',
            index: 'updated_at',
            width: 170,
        },{
            name: 'user[password]',
            index: 'password',
            width: 1,
            editable: true,
			hidden: true,
            editoptions: {
                size: 25
            },
            formoptions: {
                rowpos: 2,
                label: "Password",
                elmprefix: "(*)"
            },
            editrules: {
                required: true,
				edithidden:true
            }
        },{
            name: 'user[password_confirmation]',
            index: 'password_confirmation',
            width: 1,
            editable: true,
			hidden: true,
            editoptions: {
                size: 25
            },
            formoptions: {
                rowpos: 3,
                label: "Confirmation",
                elmprefix: "(*)"
            },
            editrules: {
                required: true,
				edithidden:true
            }
        }
		],
        pager: jQuery('#pager'),
        rowNum: 10,
        autowidth: false,
        rowList: [10, 20, 30],
        pager: jQuery('#pager'),
        sortname: 'login',
        sortorder: "asc",
        viewrecords: true,
        imgpath: 'stylesheets/cupertino/images',
        caption: 'Users',
        editurl: '/usersadmin',
        onSelectRow: function(ids){
            $('#user_id').text(ids);
            return false;
        }
    });
    
    // Set up the pager menu for add, delete, and search
    jQuery("#users").navGrid('#pager', {
        view: false,
        search: false // TODO - put search back in
    }, //options
    { // edit options
        height: 220,
        reloadAfterSubmit: false,
        jqModal: true,
        closeOnEscape: true,
        bottominfo: "Fields marked with (*) are required",
        afterSubmit: processResponse,
        beforeSubmit: function(postdata, formid){
            this.ajaxEditOptions = {
                url: '/usersadmin/' + postdata.users_id, // TODO
                type: 'put'
            };
            return [true, "ok"];
        }
    }, // edit options
    { // add options
        reloadAfterSubmit: false,
        jqModal: true,
        closeOnEscape: true,
        bottominfo: "Fields marked with (*) are required",
        afterSubmit: processResponse,
        closeAfterAdd: true
//		,
//        beforeSubmit: function(postdata, formid){
//            this.ajaxEditOptions = {
//                url: '/users/admin/new',
//                type: 'put'
//            };
//            return [true, "ok"];
//        }
    }, // add options
    { // del options
        reloadAfterSubmit: false,
        jqModal: true,
        closeOnEscape: true,
        beforeSubmit: function(postdata){
            this.ajaxDelOptions = {
                url: '/usersadmin/' + postdata,
                type: 'delete'
            };
            return [true, "ok"];
        },
    }, // del options
    {
        height: 150,
        jqModal: true,
        closeOnEscape: true
    } // view options
	);
    jQuery("#users").jqGrid('filterToolbar', {
        stringResult: true,
        searchOnEnter: false
    });
});

function processResponse(response, postdata){
    // examine return for problem - look for errorExplanation in the returned HTML
    var text = $(response.responseText).find(".errorExplanation");
    if (text.size() > 0) {
        text.css('font-size', '6pt');
        text = $("<div></div>").append(text);
        return [false, text.html()];
    }
    return [true, "Success"];
}
