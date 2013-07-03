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
        url: baseUrl,
        datatype: 'xml',
        mtype: 'POST',
        ajaxGridOptions: {
            beforeSend: function(jqXHR, settings) {
//                alert(unescape(this.data));
            }
        },
        colNames: ['Title', 'Format', 'Duration', 'Room', 'Day','Start', 'RefNum','lock'],
        colModel: [{
            name: 'programme_item[title]',
            index: 'title',
            width: 500,
            editable: true,
            editoptions: {
                size: 20
            },
//            searchoptions: {
//                dataEvents: [{
//                    type: 'keyup',
//                    fn: function(e){
//                        //alert('query: ' + this.value );
//                        this.value = escape(this.value); //.replace(/"/g, '');
//                    }
//                }]
//            },
            formoptions: {
                rowpos: 1,
                label: "Title",
                elmprefix: "(*)"
            },
            editrules: {
                required: true
            }
        }, {
            name: 'programme_item[format_id]',
            index: 'format_id',
            width: 150,
            editable: true,
            edittype: "select",
            search: true,
            stype: "select",
            searchoptions: {
                dataUrl: '/formats/listwithblank'
            },
            editoptions: {
                dataUrl: '/formats/list',
                defaultValue: '1'
            },
            formoptions: {
                rowpos: 2,
                elmprefix: "&nbsp;&nbsp;&nbsp;&nbsp;"
            }
        },        //    		  First you need to make sure it is on a separate row - this is done via the rowpos attribute
        {
            name: 'programme_item[duration]',
            index: 'duration',
            width: 60,
            editable: true,
            editoptions: {
                size: 20
            },
            formoptions: {
                rowpos: 3,
                label: "Duration",
                elmprefix: "(*)"
            },
            editrules: {
                required: true
            }
        }, {
            name: 'room',
            sortable: false,
            search: false,
            width: 80,
            editable: false,
            edittype: "select",
            editoptions: {
                dataUrl: '/rooms/listwithblank'
            },
            formoptions: {
                rowpos: 4,
                label: "Room",
            },
            editrules: {
                required: false
            }
        }, {
            name: 'start_day',
            sortable: false,
            search: false,
            width: 100,
            editable: false,
            edittype: "select",
            editoptions: {
                value: "-1:;0:Wednesday;1:Thursday;2:Friday;3:Saturday;4:Sunday"
            },
            formoptions: {
                rowpos: 5,
                label: "Day",
            },
            editrules: {
                required: false
            }
        }, {
            name: 'start_time',
            sortable: false,
            search: false,
            width: 60,
            editable: false,
            editoptions: {
                size: 20
            },
            formoptions: {
                rowpos: 6,
                label: "Start Time",
            },
            editrules: {
                required: false
            }
        }, {
            name: 'programme_item[pub_reference_number]',
            index: 'pub_reference_number',
            width: 60,
            editable: false,
            formoptions: {
                rowpos: 7,
                label: "Ref Number",
				elmprefix: "(*)"
            },
           
        },{
            name: 'programme_items[lock_version]',
            width: 3,
            index: 'lock_version',
            hidden: true,
            editable: true,
            sortable: false,
            search: false,
            formoptions: {
                rowpos: 8,
                label: "lock"
            }
        }],
        
        pager: jQuery('#pager'),
        rowNum: 10,
        autowidth: false,
        height: "100%",
        rowList: [10, 20, 30],
        pager: jQuery('#pager'),
        sortname: '',
        sortorder: "",
        viewrecords: true,
        imgpath: 'stylesheets/cupertino/images',
        caption: 'ProgrammeItems',
        editurl: '/programme_items?plain=true', // need to ensure edit url is correct
        onSelectRow: function(ids){
            loadTabs(ids);
            return false;
        }
    });
    
    jQuery("#programmeItems").navGrid('#pager', {
        view: false,
        search: false,
        edit: false
    }, //options
    { // edit options
        view: false,
        height: 320,
        reloadAfterSubmit: true,
        jqModal: true,
        closeOnEscape: true,
        closeAfterEdit: true,
        bottominfo: "Fields marked with (*) are required",
        afterSubmit: processResponse,
        mtype: 'PUT',
        onclickSubmit : function(params, postdata) {
            params.url = '/programme_items/' + postdata.programmeItems_id;
        },
        // beforeSubmit: function(postdata, formid){
            // this.ajaxEditOptions = {
                // url: '/programme_items/' + postdata.programmeItems_id,
                // type: 'put'
            // };
            // return [true, "ok"];
        // },
        beforeShowForm: function(frm) {
            $('#start_time').timeEntry({show24Hours: true, showSeconds: false, timeSteps: [1, 15, 0], defaultTime: '09:00', spinnerImage: 'images/spinnerDefault.png'});
        }
    }, // edit options
    { // add options
        reloadAfterSubmit: false,
        jqModal: true,
        closeOnEscape: true,
        bottominfo: "Fields marked with (*) are required",
        afterSubmit: processAddResponse,
        closeAfterAdd: true,
        beforeShowForm: function(frm) {
            $('#start_time').timeEntry({show24Hours: true, showSeconds: false, timeSteps: [1, 15, 0], spinnerImage: 'images/spinnerDefault.png'});
        }
    }, // add options
    { // del options
        reloadAfterSubmit: false,
        jqModal: true,
        closeOnEscape: true,
        mtype: 'DELETE',
        onclickSubmit : function(params, postdata) {
            params.url = '/programme_items/' + postdata;
        },
        // beforeSubmit: function(postdata){
            // this.ajaxDelOptions = {
                // url: '/programme_items/' + postdata,
                // type: 'delete'
            // };
            // return [true, "ok"];
        // },
    }, // del options
    {
        height: 150,
        jqModal: true,
        closeOnEscape: true
    } // view options
);
    jQuery("#programmeItems").jqGrid('filterToolbar', {
        stringResult: true,
        searchOnEnter: false
    });
});

function initDialog(event, ui){

    $(".deletetag").click(function(event){
        // do the action etc
        var a = $(this), href = a.attr('href'), content = $('.message');
        
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

var defaultDiacriticsRemovalMap = {
    '\x80' : '\u20AC', // EURO SIGN
    '\x82' : '\u201A', // SINGLE LOW-9 QUOTATION MARK
    '\x83' : '\u0192', // LATIN SMALL LETTER F WITH HOOK
    '\x84' : '\u201E', // DOUBLE LOW-9 QUOTATION MARK
    '\x85' : '\u2026', // HORIZONTAL ELLIPSIS
    // \x86 : \u2020, // DAGGER
    // \x87 : \u2021, // DOUBLE DAGGER
    // \x88 : \u02C6, // MODIFIER LETTER CIRCUMFLEX ACCENT
    // \x89 : \u2030, // PER MILLE SIGN
    // \x8A : \u0160, // LATIN CAPITAL LETTER S WITH CARON
    // \x8B : \u2039, // SINGLE LEFT-POINTING ANGLE QUOTATION MARK
    // \x8C : \u0152, // LATIN CAPITAL LIGATURE OE
    // \x8E : \u017D, // LATIN CAPITAL LETTER Z WITH CARON
    // \x91 : \u2018, // LEFT SINGLE QUOTATION MARK
    // \x92 : \u2019, // RIGHT SINGLE QUOTATION MARK
    // \x93 : \u201C, // LEFT DOUBLE QUOTATION MARK
    // \x94 : \u201D, // RIGHT DOUBLE QUOTATION MARK
    // \x95 : \u2022, // BULLET
    '\x96' : '\u2013', // EN DASH
    // \x97 : \u2014, // EM DASH
    // \x98 : \u02DC, // SMALL TILDE
    // \x99 : \u2122, // TRADE MARK SIGN
    // \x9A : \u0161, // LATIN SMALL LETTER S WITH CARON
    // \x9B : \u203A, // SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
    // \x9C : \u0153, // LATIN SMALL LIGATURE OE
    // \x9E : \u017E, // LATIN SMALL LETTER Z WITH CARON
    // \x9F : \u0178, // LATIN CAPITAL LETTER Y WITH DIAERESIS
};
    // // {'base':'AA','letters':/[\uA732]/g},
// ];

function mapString(str) {
    var s = str.replace(/[\x80-\x9F]/g ,function(m) {
        return ' '; //defaultDiacriticsRemovalMap[m];
    });
    
    return s;
}

function adjust(dialog){
    currentDialog = dialog;
    $('.layerform', dialog.w).ajaxForm({
        beforeSubmit : function(arr, $form, options) {
            // alert("hh");
            for (var key in arr) {
                // // var bytelike= unescape(encodeURIComponent(arr[key].value));
                // // var characters= decodeURIComponent(escape(bytelike));
                // var re1 = /(?![\x00-\x7F]|[\xC0-\xDF][\x80-\xBF]|[\xE0-\xEF][\x80-\xBF]{2}|[\xF0-\xF7][\x80-\xBF]{3})./g;
//                 
                // var re = /(?![\x09\x0A\x0D\x20-\x7E]|[\xC2-\xDF][\x80-\xBF]|\xE0[\xA0-\xBF][\x80-\xBF]|[\xE1-\xEC\xEE\xEF][\x80-\xBF]{2}|\xED[\x80-\x9F][\x80-\xBF]|\xF0[\x90-\xBF][\x80-\xBF]{2}|[\xF1-\xF3][\x80-\xBF]{3}|\xF4[\x80-\x8F][\x80-\xBF]{2})./g;
//                 
                arr[key].value = mapString(arr[key].value);
                
                // alert(key);
                // .replace(re, "")
// 
                // // alert(bytelike);
                // // arr[key].value = characters;
            }
        },
        target: '#form-response',
        error: function(response, r){
            var errText = $(response.responseText).find(".error"); // class error
            $('#form-response', currentDialog.w).append('ERROR: ' + errText.text());
        }
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
    
    var $tabs = $('#programmeItems_tabs').tabs();
    var selected = $tabs.tabs('option', 'selected');
    $tabs.tabs('load', selected);
    
    return [true, "Success", ""];
}

function processAddResponse(response, postdata) {
    // examine return for problem - look for errorExplanation in the returned HTML
    var text = jQuery(response.responseText).find(".errorExplanation");
    if (text.size() > 0) {
        text.css('font-size', '6pt');
        text = jQuery("<div></div>").append(text);
        return [false, text.html()];
    }
    
    // get the id of the new entry and change the id of the 
    var id = jQuery(response.responseText).find("#progitemid");

    return [true, "Success", id.text()]; // Last param is the id of the new item
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

function createTagQuery(){
    // context='" + ctx + "'&tags='" + tag + "'"
    var posn = 0;
    var query = "";
    for (var key in tagQueryList) {
        query += "context[" + posn + "]=" + key + "&tags[" + posn + "]=";
        for (var i = 0; i < tagQueryList[key].length; i++) {
            query += escape(tagQueryList[key][i]) + ",";
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
            html += '<a href="#context=' + key + '&tag=' + tagQueryList[key][i] + '" class="delete-filter-tag">';
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

function applyFilterEventHandler(){
    jQuery(".delete-filter-tag").click(function(event){
        var q = $(this).attr('href');
        var strs = q.split('&');
        var ctx = strs[0].substr(9, strs[0].length);
        var tag = strs[1].substr(4, strs[1].length);
        // extract the context and tag and then remove these from the tag query collection
        // then force the elements to refresh
        var posn = $.inArray(tag, tagQueryList[ctx]);
        tagQueryList[ctx].splice(posn, 1);
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
	$tabs.tabs('url', 3, 'programme_items/' + ids + '/equipment_needs').tabs('load', 3);
    $tabs.tabs('url', 2, 'programme_items/' + ids + '/excluded_items_survey_maps').tabs('load', 2);
    $tabs.tabs('url', 1, 'tags/' + ids + '?class=ProgrammeItem').tabs('load', 1);
	$tabs.tabs('url', 0, 'programme_items/' + ids + '?plain=true').tabs('load', 0).tabs('select', 0);

}

/* Initialize the tags - load is called when a new participant/person is selected in the grid */
function createTabs(){

    jQuery("#programmeItems_tabs").tabs({
        ajaxOptions: {
            async: false
        },
        cache: false
    }).tabs({
        load: function(event, ui){
            initDialog(event, ui);
        }
    });
    
}
