/*
 * 
 */
jQuery(document).ready(function(){ 
  
	$.ajax({
		url : "/participants/tags/index",
		dataType : "html",
		success: function(response) {
		  $(response).appendTo("#participant-tag-cloud");
		}
	});
	
  jQuery("#particpanttabs").tabs({
		ajaxOptions: { async: false },
		cache: false
  }).tabs({load : function(event, ui) { initDialog(event, ui);  initAutoComplete(); } }); // TODO - init dialog and autocomplete

  // The grid containing the list of paricipants
  jQuery("#participants").jqGrid({
    url:'participants/list',
    datatype: 'xml',
    colNames:['First Name','Last Name'],
    colModel :[ 
      {name:'person[first_name]', index:'first_name', width:250,
    	  editable:true,editoptions:{size:20}, formoptions:{ rowpos:1, label: "First Name", elmprefix:"(*)"},editrules:{required:true}
    	  }, 
      {name:'person[last_name]', index:'last_name', width:250,
        	  editable:true,editoptions:{size:20}, formoptions:{ rowpos:2, label: "Last Name", elmprefix:"(*)"},editrules:{required:true}
    		  } ],
    pager: jQuery('#pager'),
    rowNum:10,
    autowidth: false,
    rowList:[10,20,30],
    pager: jQuery('#pager'),
    sortname: 'last_name',
    sortorder: "asc",
    viewrecords: true,
    imgpath: 'stylesheets/cupertino/images',
    caption: 'Participants',
    editurl: '/participants',
    onSelectRow: function(ids) {
	  $('#participant_id').text(ids);
      var $tabs = $('#particpanttabs').tabs();

      $tabs.tabs( 'url' , 0 , 'participants/'+ids+'/registrationDetail' ).tabs( 'load' , 0 ).tabs('select', 0);
      $tabs.tabs( 'url' , 1 , 'participants/'+ids+'/addresses').tabs( 'load' , 1 );
	  $tabs.tabs( 'url' , 2, 'participants/'+ids).tabs('load', 2)
      $tabs.tabs( 'url' , 3 , 'participants/'+ids+'/tags').tabs( 'load' , 3 );
      
      return false;
    }
  }); 
  
  // Set up the pager menu for add, delete, and search
  jQuery("#participants").navGrid('#pager',
		  {view:false }, //options

		  {	// edit options
			  height:220, reloadAfterSubmit:false, jqModal:true, closeOnEscape:true,
			  bottominfo:"Fields marked with (*) are required",
			  afterSubmit: processResponse,
			  beforeSubmit : function(postdata, formid) {
			  	this.ajaxEditOptions = {url : '/participants/'+postdata.participants_id, type: 'put'};
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
			  this.ajaxDelOptions = {url : '/participants/'+postdata, type: 'delete' };
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

function addToTagList(value) {
	$("<div/>").text(value).prependTo("#tags-list");
	$("#tags-list").attr("scrollTop", 0);
	$("#tags").val('');
}

function initAutoComplete() {
	// TODO - change so that tags already used by person are not in the autocomplete list
	$.ajax({
		url : "/participants/tags/list",
		async : false,
		dataType : "xml",
		success: function(xmlResponse) {
			var gtags = new Array();
			$(xmlResponse).find("tag").each( function() {
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
	$("#tags").bind("change",
			function(event) {
				var newTag = $("#tags").val();
				var personId = $('#participant_id').text(); // get the id of the person
				$.ajax({
						url : "/participants/" + personId + "/tags/add",
						type : "POST",
						data : { "tag" : newTag },
						success : function() {
							addToTagList(newTag);
						}
				});
			}
		);

}

function initDialog(event, ui) {
	$('#edialog', ui.panel).jqm({
		ajax: '@href', 
		trigger: 'a.entrydialog',
		onLoad: adjust,
		onHide: function(hash) {
		var $tabs = $('#particpanttabs').tabs();
		var selected = $tabs.tabs('option', 'selected');
		$tabs.tabs('load', selected);
		hash.w.fadeOut('2000',function(){ hash.o.remove(); });
		}
	});
	
	$('.remove-form form', ui.panel).ajaxForm({
		target: '#tab-messages',
		success: function(response, status) {
			var $tabs = $('#particpanttabs').tabs();
			var selected = $tabs.tabs('option', 'selected');
			$tabs.tabs('load', selected);
		}
	});
}

function adjust(dialog) {
	$('.particpantInfo', dialog.w).ajaxForm({
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
