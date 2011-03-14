/*
 *
 */
jQuery(document).ready(function(){
    // The grid containing the list of rooms
    jQuery("#rooms").jqGrid({
        url: '/rooms/list',
        datatype: 'xml',
        colNames: ['Room Name', 'Venue', 'Capacity','Purpose','Comment'],
        colModel: [
		{
            name: 'room[name]',
            index: 'name',
            width: 125,
            editable: true,
            editoptions: {
                size: 20
            },
            formoptions: {
                rowpos: 1,
                label: "Name",
                elmprefix: "(*)"
            },
            editrules: {
                required: true
            },
        },{
            name: 'room[venue_id]',
            index: 'venue_id',
            width: 125,
            editable: true,
	    search: true,
            sortable: true,
            edittype: "select",
            editoptions: {
                dataUrl:'/venue/list'
            },
            formoptions: {
                rowpos: 2,
                label: "Venue",
                elmprefix: "(*)"
            },
            editrules: {
                required: true
            },
        },{
            name: 'room[capacity]',
            index: 'capacity',
            width: 75,
            editable: true,
	    search: true,
            sortable: true,
            editoptions: {
                size: 20
            },
            formoptions: {
                rowpos: 3,
                label: "Capacity",
            },
            editrules: {
                required: false
            },
        },{
            name: 'room[purpose]',
            index: 'purpose',
            width: 170,
            editable: true,
	    search: true,
            editoptions: {
                size: 20
            },
            formoptions: {
                rowpos: 4,
                label: "Purpose",
            },
            editrules: {
                required: false
            },
        },{
            name: 'room[comment]',
            index: 'comment',
            width: 170,
            editable: true,
	    search: true,
            edittype: "textarea",
            editoptions: {
                size: 20
            },
            formoptions: {
                rowpos: 5,
                label: "Comment",
            },
            editrules: {
                required: false
            },
        }
		],
        pager: jQuery('#pager'),
        rowNum: 10,
        autowidth: false,
        rowList: [10, 20, 30],
        pager: jQuery('#pager'),
        sortname: 'name',
        sortorder: "asc",
        viewrecords: true,
        imgpath: 'stylesheets/cupertino/images',
        caption: 'Rooms',
        editurl: '/rooms',
        onSelectRow: function(ids){
            $('#room_id').text(ids);
            return false;
        }
    });
    
    // Set up the pager menu for add, delete, and search
    jQuery("#rooms").navGrid('#pager', {
        view: false
    }, //options
    { // edit options
        height: 250,
        reloadAfterSubmit: false,
        closeAfterEdit: true,
        jqModal: true,
        closeOnEscape: true,
        bottominfo: "Fields marked with (*) are required",
        afterSubmit: processResponse,
        beforeSubmit: function(postdata, formid){
            this.ajaxEditOptions = {
                url: '/rooms/' + postdata.rooms_id, // TODO
                type: 'put'
            };
            return [true, "ok"];
        }
    }, // edit options
    { // add options
        height: 250,
        reloadAfterSubmit: true,
        jqModal: true,
        closeOnEscape: true,
        bottominfo: "Fields marked with (*) are required",
        afterSubmit: processResponse,
        closeAfterAdd: true
    }, // add options
    { // del options
        reloadAfterSubmit: true,
        jqModal: true,
        closeOnEscape: true,
        beforeSubmit: function(postdata){
            this.ajaxDelOptions = {
                url: '/rooms/' + postdata,
                type: 'delete'
            };
            return [true, "ok"];
        },
    }, 
	{ // search options
		jqModal:true, closeOnEscape:true,
		multipleSearch:true,
		sopt:['eq','ne','le','ge'],
		//odata: ['begins with', 'does not begin with'],
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
 jQuery("#rooms").trigger("reloadGrid");
    return [true, "Success"];
}
