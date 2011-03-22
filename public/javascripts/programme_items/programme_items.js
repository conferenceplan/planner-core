/**
 * @author rleibig
 */
var baseUrl = "programme_items/list";
var tagQueryList = {};
    
jQuery(document).ready(function(){ 
    /* Populate the tag cloud */
	populateTagCloud();
	
	createTabs();
	
	
	
  jQuery("#programmeItems").jqGrid({
    url:baseUrl,
    datatype: 'xml',
    mtype: 'POST',
    colNames:['Title','Format','Duration','lock'],
    colModel :[ 
      {name:'programme_item[title]', 
	   index:'title', 
	   width:500,
       editable:true,
	   editoptions:{size:20}, 
	   formoptions:{ rowpos:1, label: "Title", elmprefix:"(*)"},
	   editrules:{required:true}
      }, 
	  {
			name:'programme_item[format_id]',
			index:'format_id',
			width: 150,
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
	   width:80,
       editable:true,
	   editoptions:{size:20},
	   formoptions:{ rowpos:3, 
	   label: "Duration", 
	   elmprefix:"(*)"},
	   editrules:{required:true}
      }, {
            name: 'programme_items[lock_version]',
            width: 3,
            index: 'lock_version',
            hidden: true,
            editable: true,
            sortable: false,
            search: false,
            formoptions: {
                rowpos: 4,
                label: "lock"
            }
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
			loadTabs(ids);  
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

	$(".deletetag").click(function(event) {
		// do the action etc
		var a    = $(this),
		href = a.attr('href'),
		content  = $('.message');
		
		content.load(href);

		populateTagCloud();
            var $tabs = $('#programmeItems_tabs').tabs();
            var selected = $tabs.tabs('option', 'selected');
            $tabs.tabs('load', selected);
		
		event.preventDefault();
	});

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
			jQuery("#programmeItems").trigger("reloadGrid");
			populateTagCloud();
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

var currentDialog = null;
 
function adjust(dialog) {
	currentDialog = dialog;
    $('.layerform', dialog.w).ajaxForm({
        target: '#form-response',
        error: function(response, r) {
            var errText = $(response.responseText).find(".error"); // class error
            $('#form-response', currentDialog.w).append('ERROR: ' + errText.text());
        }
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
	
	var $tabs = $('#programmeItems_tabs').tabs();
	var selected = $tabs.tabs('option', 'selected');
	$tabs.tabs('load', selected);
			
	return [true, "Success"]; 
}


function populateTagCloud(){
    /* Populate the tag cloud */
    $.ajax({ // /tags?class=ProgrammeItem
        url: "/tags?class=ProgrammeItem",
        dataType: "html",
        success: function(response){
            jQuery("#programmeitem-tag-cloud").html(response);
            
            jQuery(".tag-select").click(function(event){
                var ctx = $(this).parents('.tag-group').find('.tag-context-title').text();
                var tag = $(this).text();
                
                if (!tagQueryList[ctx]) {
                    tagQueryList[ctx] = new Array();
                }
                
                if ($.inArray(tag, tagQueryList[ctx]) == -1) { // only push if it does not already exist
                    tagQueryList[ctx].push(tag);
                }
                issueTagQuery();
            });
        }
    });
}

function issueTagQuery(){
    var newUrl = baseUrl + "?" + createTagQuery();
	
    jQuery("#programmeItems").jqGrid('setGridParam', {
        url: newUrl
    }).trigger("reloadGrid");
    
    jQuery("#programmeitem-tag-facets").html(turnTagQueryToHTML());
    applyFilterEventHandler();
}

function createTagQuery() {
    // context='" + ctx + "'&tags='" + tag + "'"
    var posn = 0;
    var query = "";
    for (var key in tagQueryList) {
        query += "context[" + posn + "]=" + key + "&tags["+ posn + "]=";
        for (var i = 0; i < tagQueryList[key].length; i++) {
            query += tagQueryList[key][i] + ",";
        }
        query += "&";
		posn += 1;
    }
    return query;
}

function turnTagQueryToHTML(){
    var html = "<div class='tags'>";
    for (var key in tagQueryList) {
        html += "<div class='tag-group'>";
        html += "<div class='tag-context-title'>" + key + "</div>";
        html += "<div class='tag-area'>"
        html += "<div class='tag'>"
        for (var i = 0; i < tagQueryList[key].length; i++) {
            html += '<div class="tag-name">';
            html += tagQueryList[key][i];
            html += '</div>';
            html += '<a href="#context='+key+'&tag='+tagQueryList[key][i]+'" class="delete-filter-tag">';
            html += '<div class="ui-icon ui-icon-close" style="float: left;"/>';
            html += '</a>';
        }
        html += "</div>";
        html += "</div>";
        html += "</div>";
        html += "</div>";
    }
    html += "</div>";
    
    return html;
}

function applyFilterEventHandler() {
    jQuery(".delete-filter-tag").click(function(event){
        var q = $(this).attr('href');
        var strs = q.split('&');
        var ctx = strs[0].substr(9,strs[0].length);
        var tag = strs[1].substr(4,strs[1].length);
        // extract the context and tag and then remove these from the tag query collection
        // then force the elements to refresh
        var posn = $.inArray(tag, tagQueryList[ctx]);
        tagQueryList[ctx].splice(posn,1);
        if (tagQueryList[ctx].length == 0) {
            delete tagQueryList[ctx];
        }
        issueTagQuery();
    });
}


function loadTabs(ids){
	var data = jQuery("#programmeItems").jqGrid('getRowData', ids);
	$('#programmeItem_id').text(ids);
	var $tabs = $('#programmeItems_tabs').tabs();
	$tabs.tabs('url', 1, 'tags/' + ids + '?class=ProgrammeItem').tabs('load', 1);
    $tabs.tabs('url', 0, 'programme_items/' + ids).tabs('load', 0).tabs('select', 0);
}

/* Initialize the tags - load is called when a new participant/person is selected in the grid */
function createTabs() {
	
	jQuery("#programmeItems_tabs").tabs({
		ajaxOptions: { async: false },
		cache: false
	}).tabs({
        load: function(event, ui){
            initDialog(event, ui);
        }
    });
	
}
