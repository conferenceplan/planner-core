/**
 * @author rleibig
 */
jQuery(document).ready(function(){ 
	jQuery("#programmeitemtabs").tabs({
		ajaxOptions: { async: false },
		cache: false
	}).
	tabs({load : initDialog});
	
  jQuery("#programmeItems").jqGrid({
    url:'programme_items/list',
    datatype: 'xml',
    colNames:['Title','Room','Duration'],
    colModel :[ 
      {name:'programmeItem[title]', index:'title', width:250,
    	  editable:true,editoptions:{size:20}, formoptions:{ rowpos:1, label: "Title", elmprefix:"(*)"},editrules:{required:true}
      }, 
      // We do not want the room to be editable here as it is a scheduling task....
      {name:'programmeItem[room.name]', index:'rooms.name', width:250,
          editable:false,editoptions:{size:20}, formoptions:{ rowpos:2, label: "Room", elmprefix:"(*)"},editrules:{required:false}
    		  },
//    		  First you need to make sure it is on a separate row - this is done via the rowpos attribute
      {name:'programmeItem[duration]', index:'duration', width:250,
        	  editable:true,editoptions:{size:20}, formoptions:{ rowpos:3, label: "Duration", elmprefix:"(*)"},editrules:{required:true}
      } ],
	 
    pager: jQuery('#pager'),
    rowNum:10,
    autowidth: false,
    rowList:[10,20,30],
    pager: jQuery('#pager'),
    sortname: 'title',
    sortorder: "asc",
    viewrecords: true,
    imgpath: 'stylesheets/cupertino/images',
    caption: 'ProgrammeItems',
    editurl: '/programme_items', // need to ensure edit url is correct
    onSelectRow: function(ids) {
      
      return false;
    }
  }); 
  
  jQuery("#programmeItems").navGrid('#pager',
		  {view:false }, //options

		  {	// edit options
			  height:320, reloadAfterSubmit:false, jqModal:true, closeOnEscape:true,
			  bottominfo:"Fields marked with (*) are required",
			  afterSubmit: processResponse,
			  beforeSubmit : function(postdata, formid) {
			  	this.ajaxEditOptions = {url : '/programme_items/'+postdata.programme_items_id, type: 'put'};
			  	return [true, "ok"]; }
		  }, // edit options

		  { // add options
			  reloadAfterSubmit:false, jqModal:true, closeOnEscape:true,
			  bottominfo:"Fields marked with (*) are required",
			  afterSubmit: processResponse,
			  closeAfterAdd: true
		  }, // add options

		  { // del options
			  reloadAfterSubmit:false,jqModal:true, closeOnEscape:true,
			  beforeSubmit : function(postdata) {
			  this.ajaxDelOptions = {url : '/programme_items/'+postdata, type: 'delete' };
			  return [true, "ok"]; },
		  }, // del options

		  { // search options
			  jqModal:true, closeOnEscape:true,
			  multipleSearch:true,
			  sopt:['eq','ne'],
			  odata: ['begins with', 'does not begin with'],
			  groupOps: [ { op: "AND", text: "all" }, { op: "OR", text: "any" } ]
		  }, // search options
		  
		  {height:150, jqModal:true, closeOnEscape:true} // view options
  );
});


function initDialog(event, ui) {
	$('#edialog', ui.panel).jqm({
		ajax: '@href', 
		trigger: 'a.entrydialog',
		onLoad: adjust,
		onHide: function(hash) {
		hash.w.fadeOut('2000',function(){ hash.o.remove(); });
		}
	});
	
	$('.remove-form form', ui.panel).ajaxForm({
		target: '#tab-messages',
		success: function(response, status) {
		}
	});
}

function adjust(dialog) {
	$('.programmeItemInfo', dialog.w).ajaxForm({
		target: '#form-response'
	});
}

function processResponse(response, postdata) { 
	// examine return for problem - look for errorExplanation in the returned HTML
	var text = $(response.responseText).find(".errorExplanation");
	if (text.size() > 0) {
		text.css('font-size','6pt');
		text = $("<div></div>").append(text);
		return [false, text.html() ];
	}
	return [true, "Success"]; 
}
