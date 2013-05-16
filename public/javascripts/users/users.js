/*
 *
 */
jQuery(document).ready(function(){
    // The grid containing the list of users
    jQuery("#users").jqGrid({
        url: '/usersadmin/list',
        datatype: 'xml',
        colNames: ['Login Id', 'Roles', 'Count','Failed','Current', 'Last','IP','Created','Updated', 'Password', 'Password Confirm'],
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
			name:'userrole[roles]',
			index:'roles',
			width:80,
			editable: true, 
			edittype: "select", 
			search: false,
			editoptions:{
				dataUrl:'/roles/list',
				defaultValue:'Planner'
			}, 
			formoptions:{ 
				rowpos:2,
				elmprefix:"&nbsp;&nbsp;&nbsp;&nbsp;"
			} 
        },{
            name: 'user[login_count]',
            index: 'login_count',
            width: 50,
            editable: false,
			search: false,
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
			search: false,
        },{
            name: 'user[current_login_at]',
            index: 'current_login_at',
            width: 170,
            editable: false,
			search: false,
        },{
            name: 'user[last_login_at]',
            index: 'last_login_at',
            width: 170,
            editable: false,
			search: false,
        },{
            name: 'user[last_login_ip]',
            index: 'last_login_ip',
            width: 100,
            editable: false,
			search: false,
        },{
            name: 'user[created_at]',
            index: 'created_at',
            width: 170,
            editable: false,
			search: false,
        },{
            name: 'user[updated_at]',
            index: 'updated_at',
            width: 170,
			search: false,
        },{
            name: 'user[password]',
            index: 'password',
            width: 1,
            editable: true,
			search: false,
			hidden: true,
			edittype: "password", 
            editoptions: {
                size: 25
            },
            formoptions: {
                rowpos: 3,
                label: "Password",
            },
            editrules: {
//                required: true,
				edithidden:true
            }
        },{
            name: 'user[password_confirmation]',
            index: 'password_confirmation',
            width: 1,
            editable: true,
			search: false,
			edittype: "password", 
			hidden: true,
            editoptions: {
                size: 25
            },
            formoptions: {
                rowpos: 4,
                label: "Confirmation",
            },
            editrules: {
//                required: true,
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
        view: false
    }, //options
    { // edit options
        height: 220,
        reloadAfterSubmit: false,
        jqModal: true,
        closeOnEscape: true,
        bottominfo: "Fields marked with (*) are required",
        afterSubmit: processResponse,
        mtype: 'PUT',
        onclickSubmit : function(params, postdata) {
            params.url = '/usersadmin/' + postdata.users_id;
        },
    }, // edit options
    { // add options
        reloadAfterSubmit: false,
        jqModal: true,
        closeOnEscape: true,
        bottominfo: "Fields marked with (*) are required",
        afterSubmit: processResponse,
        closeAfterAdd: true
    }, // add options
    { // del options
        reloadAfterSubmit: false,
        jqModal: true,
        closeOnEscape: true,
        mtype: 'DELETE',
        onclickSubmit : function(params, postdata) {
            params.url = '/usersadmin/' + postdata;
        },
    }, // del options
	{ // search options
		jqModal:true, closeOnEscape:true,
//		multipleSearch:true,
		sopt:['eq','ne'],
		odata: ['begins with', 'does not begin with'],
		groupOps: [ { op: "AND", text: "all" }, { op: "OR", text: "any" } ]
	} // search options
	);
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
