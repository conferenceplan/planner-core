/**
 * @author rleibig
 */
    
jQuery(document).ready(function(){ 
	jQuery("#programmeItems_tabs").tabs({
		ajaxOptions: { async: false },
		cache: false
	}).tabs({
        load: function(event, ui){
            initDialog(event, ui);
        }
    });
	
  jQuery("#programmeItems").jqGrid({
    url:'programme_items/list',
    datatype: 'xml',
    mtype: 'POST',
    colNames:['Title','Format','Duration'],
    colModel :[ 
      {name:'programme_item[title]', 
	   index:'title', 
	   width:250,
       editable:true,
	   editoptions:{size:20}, 
	   formoptions:{ rowpos:1, label: "Title", elmprefix:"(*)"},
	   editrules:{required:true}
      }, 
	  {
			name:'programme_item[format_id]',
			index:'format_id',
			width: 100,
			editable: true, 
			edittype: "select", 
			search: true,
			stype: "select",
			searchoptions:{
				dataUrl:'/formats/listwithblank' 
			},
			editoptions:{
				dataUrl:'/formats/list',
				defaultValue:'1'
			}, 
			formoptions:{ 
				rowpos:2,
				elmprefix:"&nbsp;&nbsp;&nbsp;&nbsp;"
			} 
        },
//    		  First you need to make sure it is on a separate row - this is done via the rowpos attribute
      {name:'programme_item[duration]', 
	   index:'duration', 
	   width:250,
       editable:true,
	   editoptions:{size:20},
	   formoptions:{ rowpos:3, 
	   label: "Duration", 
	   elmprefix:"(*)"},
	   editrules:{required:true}
      } ],
	 
    pager: jQuery('#pager'),
    rowNum:10,
    autowidth: false,
	height: "100%",
    rowList:[10,20,30],
    pager: jQuery('#pager'),
    sortname: 'title',
    sortorder: "asc",
    viewrecords: true,
    imgpath: 'stylesheets/cupertino/images',
    caption: 'ProgrammeItems',
    editurl: '/programme_items', // need to ensure edit url is correct
     onSelectRow: function(ids){
			var data = jQuery("#programmeItems").jqGrid('getRowData',ids);
            $('#programmeItem_id').text(ids);
            var $tabs = $('#programmeItems_tabs').tabs();   
            $tabs.tabs('url', 0, 'programme_items/' + ids).tabs('load', 0); 
            return false;
        }
  }); 
  
  jQuery("#programmeItems").navGrid('#pager',
		  {view:false,
		   search: false
          }, //options
		  { // edit options
           height: 320,
           reloadAfterSubmit: true,
           jqModal: true,
           closeOnEscape: true,
		   closeAfterEdit: true, 
            bottominfo: "Fields marked with (*) are required",
            afterSubmit: processResponse,
            beforeSubmit: function(postdata, formid){
			   
               this.ajaxEditOptions = {
                   url: '/programme_items/'+postdata.programmeItems_id,
                   type: 'put'
             };
            return [true, "ok"];
            }
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

		
		  {height:150, jqModal:true, closeOnEscape:true} // view options
  );
  jQuery("#programmeItems").jqGrid('filterToolbar', {
        stringResult: true,
        searchOnEnter: false
    });
});


function initDialog(event, ui) {
    $('#edialog', ui.panel).jqm({
        ajax: '@href',
        trigger: 'a.entrydialog',
        onLoad: adjust,
        onHide: function(hash){
            var $tabs = $('#programmeItems_tabs').tabs();
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
            var $tabs = $('#programmeItems_tabs').tabs();
            var selected = $tabs.tabs('option', 'selected');
            $tabs.tabs('load', selected);
        }
    });
    
    $('.remove-form a', ui.panel).ajaxForm({
        target: '#tab-messages',
        success: function(response, status){
            var $tabs = $('#programmeItems_tabs').tabs();
            var selected = $tabs.tabs('option', 'selected');
            $tabs.tabs('load', selected);
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
