/*
 *
 */
jQuery(document).ready(function(){

	/* Populate the tag cloud */
    $.ajax({
        url: "/participants/tags/index",
        dataType: "html",
        success: function(response){
            $(response).appendTo("#participant-tag-cloud");
        }
    });
    
	/* Initialize the tags - load is called when a new participant/person is selected in the grid */
    jQuery("#particpanttabs").tabs({
        ajaxOptions: {
            async: false
        },
        cache: false
    }).tabs({
        load: function(event, ui){
            initDialog(event, ui);
            initAutoComplete();
            $(".addressAccordian").accordion({
                header: 'h3',
                collapsible: true,
                autoHeight: false
            });
        }
    });
    
    // The grid containing the list of paricipants
    jQuery("#participants").jqGrid({
        url: 'participants/list',
        datatype: 'xml',
		mtype: 'POST',
        colNames: ['First Name', 'Last Name', 'Suffix', 'Mailing #','Invite Status','Invitation<br/>Category','Acceptance','Survey', 'Publication<br/>First Name', 'Publication<br/>Last Name', 'Pub<br/>Suffix'],
        colModel: [{
            name: 'person[first_name]',
            index: 'first_name',
            width: 150,
            editable: true,
            editoptions: {
                size: 20
            },
            formoptions: {
                rowpos: 1,
                label: "First Name",
                elmprefix: "(*)"
            },
            editrules: {
                required: true
            }
        }, {
            name: 'person[last_name]',
            index: 'last_name',
            width: 150,
            editable: true,
            editoptions: {
                size: 20
            },
            formoptions: {
                rowpos: 2,
                label: "Last Name",
                elmprefix: "(*)"
            },
            editrules: {
                required: true
            }
        }, {
            name: 'person[suffix]',
            index: 'suffix',
            width: 50,
            editable: true,
			search: false,
            editoptions: {
                size: 20
            },
            formoptions: {
                rowpos: 3,
                label: "Suffix",
                elmprefix: ""
            },
            editrules: {
                required: false
            }
        }, {
            name: 'person[mailing_number]',
            index: 'mailing_number',
            width: 60,
            editable: true,
			hidden: false,
            editoptions: {
                size: 20,
				defaultValue: 0
            },
            formoptions: {
                rowpos: 4,
                label: "Mailing Number",
                elmprefix: ""
            },
            editrules: {
                required: false,
				edithidden:true
            }
        },{
			name:'person[invitestatus_id]',
			index:'invitestatus_id',
			width: 100,
			editable: true, 
			edittype: "select", 
			search: true,
			stype: "select",
			searchoptions:{
				dataUrl:'/participants/invitestatuslistwithblank' 
			},
			editoptions:{
				dataUrl:'/participants/invitestatuslist',
				defaultValue:'Not Set'
			}, 
			formoptions:{ 
				rowpos:5,
				elmprefix:"&nbsp;&nbsp;&nbsp;&nbsp;"
			} 
        },{
			name:'person[invitation_category_id]',
			index:'invitation_category_id',
			width: 100,
			editable: true, 
			edittype: "select", 
			search: true,
			stype: "select",
			searchoptions:{
				dataUrl:'/invitation_categories/list' 
			},
			editoptions:{
				dataUrl:'/invitation_categories/list',
				defaultValue:'Not Set'
			}, 
			formoptions:{ 
				rowpos:6,
				elmprefix:"&nbsp;&nbsp;&nbsp;&nbsp;"
			} 
        },{
			name:'person[acceptance_status_id]',
			index:'acceptance_status_id',
			width: 100,
			editable: true, 
			edittype: "select", 
			search: true,
			stype: "select",
			searchoptions:{
				dataUrl:'/participants/acceptancestatuslistwithblank' 
			},
			editoptions:{
				dataUrl:'/participants/acceptancestatuslist',
				defaultValue:'Not Set'
			}, 
			formoptions:{ 
				rowpos:7,
				elmprefix:"&nbsp;&nbsp;&nbsp;&nbsp;"
			} 
        },{
            name: 'person[hasSurvey]',
            width: 50,
            editable: false,
			sortable: false,
			search: false,
			hidden: false
        },{
            name: 'person[pseudonym_attributes][first_name]',
            width: 150,
			index: 'pseudonyms.first_name',
            editable: true,
			sortable: false,
            editoptions: {
                size: 20
            },
            formoptions: {
                rowpos: 8,
                label: "Pub First Name"
            }
        },{
            name: 'person[pseudonym_attributes][last_name]',
            width: 150,
			index: 'pseudonyms.last_name',
            editable: true,
			sortable: false,
            editoptions: {
                size: 20
            },
            formoptions: {
                rowpos: 9,
                label: "Pub Last Name"
            }
        },{
            name: 'person[pseudonym_attributes][suffix]',
            width: 50,
			index: 'pseudonyms.suffix',
            editable: true,
			sortable: false,
			search: false,
            editoptions: {
                size: 20
            },
            formoptions: {
                rowpos: 10,
                label: "Pub Suffix"
            }
		}
		],
        pager: jQuery('#pager'),
//        rowNum: 10,
        rowNum: 2,
        autowidth: false,
		height: "100%",
        rowList: [2, 10, 20, 30],
        pager: jQuery('#pager'),
        sortname: 'last_name',
        sortorder: "asc",
        viewrecords: true,
        imgpath: 'stylesheets/cupertino/images',
        caption: 'Participants',
        editurl: '/participants',
        onSelectRow: function(ids){
			var data = jQuery("#participants").jqGrid('getRowData',ids);
            $('#participant_id').text(ids);
            $('#participant_name').text(data['person[first_name]'] + ' ' + data['person[last_name]'] + ' ' + data['person[suffix]']);
            var $tabs = $('#particpanttabs').tabs();
            
            $tabs.tabs('url', 0, 'participants/' + ids + '/registrationDetail').tabs('load', 0).tabs('select', 0);
            $tabs.tabs('url', 1, 'participants/' + ids + '/addresses').tabs('load', 1);
            $tabs.tabs('url', 2, 'participants/' + ids).tabs('load', 2);
			$tabs.tabs('url', 3, 'participants/' + ids + '/edited_bio').tabs('load',3);
            
            return false;
        }
//		,
//		afterInsertRow: function(rowid, rowdata, rowelem) {
//			alert('New Row');
//			// do a refresh of the grid with the new data in the currect pages (and highlight it)...
//			// jQuery("#bigset").jqGrid('setGridParam',{url:"bigset.php?nm_mask="+nm_mask+"&cd_mask="+cd_mask,page:1}).trigger("reloadGrid"); 
//			jQuery("#participants").jqGrid().trigger("reloadGrid"); 
//		}
    });
    
    // Set up the pager menu for add, delete, and search
    jQuery("#participants").navGrid('#pager', {
        view: false,
        search: false
    }, //options
    { // edit options
        height: 320,
        reloadAfterSubmit: true,
        jqModal: true,
        closeOnEscape: true,
        bottominfo: "Fields marked with (*) are required",
        afterSubmit: processResponse,
        beforeSubmit: function(postdata, formid){
            this.ajaxEditOptions = {
                url: '/participants/' + postdata.participants_id,
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
    }, // add options
    { // del options
        reloadAfterSubmit: false,
        jqModal: true,
        closeOnEscape: true,
        beforeSubmit: function(postdata){
            this.ajaxDelOptions = {
                url: '/participants/' + postdata,
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
    jQuery("#participants").jqGrid('filterToolbar', {
        stringResult: true,
        searchOnEnter: false
    });
});

function addToTagList(value){
    $("<div/>").text(value).prependTo("#tags-list");
    $("#tags-list").attr("scrollTop", 0);
    $("#tags").val('');
}

function initAutoComplete(){
    // TODO - change so that tags already used by person are not in the autocomplete list
    $.ajax({
        url: "/participants/tags/list",
        async: false,
        dataType: "xml",
        success: function(xmlResponse){
            var gtags = new Array();
            $(xmlResponse).find("tag").each(function(){
                gtags.push($(this).text());
            });
            
            $("#tags").autocomplete({
                source: gtags,
                minLength: 2
                // The select call back causes a double entry...
                //				select: function(event, ui) {
                //					addToTagList(ui.item.value); // make sure this does not do a double entry
                //				}
            });
        }
    });
    
    // bind to the change event, so that the tag is sent to the server
    $("#tags").bind("change", function(event){
        var newTag = $("#tags").val();
        var personId = $('#participant_id').text(); // get the id of the person
        $.ajax({
            url: "/participants/" + personId + "/tags/add",
            type: "POST",
            data: {
                "tag": newTag
            },
            success: function(){
                addToTagList(newTag);
            }
        });
    });
    
}

function initDialog(event, ui){
    $('#edialog', ui.panel).jqm({
        ajax: '@href',
        trigger: 'a.entrydialog',
        onLoad: adjust,
        onHide: function(hash){
            var $tabs = $('#particpanttabs').tabs();
            var selected = $tabs.tabs('option', 'selected');
            $tabs.tabs('load', selected);
            hash.w.fadeOut('2000', function(){
                hash.o.remove();
            });
        }
    });
    
    $('.remove-form form', ui.panel).ajaxForm({
        target: '#tab-messages',
        success: function(response, status){
            var $tabs = $('#particpanttabs').tabs();
            var selected = $tabs.tabs('option', 'selected');
            $tabs.tabs('load', selected);
        }
    });
    
    $('.remove-form a', ui.panel).ajaxForm({
        target: '#tab-messages',
        success: function(response, status){
            var $tabs = $('#particpanttabs').tabs();
            var selected = $tabs.tabs('option', 'selected');
            $tabs.tabs('load', selected);
        }
    });
}

function adjust(dialog){
    $('.particpantInfo', dialog.w).ajaxForm({
        target: '#form-response'
    });
}

function processResponse(response, postdata){
    // examine return for problem - look for errorExplanation in the returned HTML
    var text = $(response.responseText).find(".errorExplanation");
    if (text.size() > 0) {
        text.css('font-size', '6pt');
        text = $("<div></div>").append(text);
        return [false, text.html()];
    }
    return [true, "Success", ""];
}
