/**
 * @author rleibig
 */
jQuery(document).ready(function(){ 
  jQuery("#programme_itemtabs").tabs({
	ajaxOptions: { async: false },
	cache: false
  });
});

jQuery(document).ready(function(){ 
  jQuery("#programme_items").jqGrid({
    url:'programme_items/list',
    datatype: 'xml',
    colNames:['Title'],
    colModel :[ 
      {name:'title', index:'title', width:300}],
    pager: jQuery('#pager'),
    rowNum:10,
    autowidth: false,
    rowList:[10,20,30],
    pager: jQuery('#pager'),
    sortname: 'title',
    sortorder: "asc",
    viewrecords: true,
    imgpath: 'stylesheets/cupertino/images',
    caption: 'Programme Items',
    onSelectRow: function(ids) {
      var $tabs = $('#programme_itemtabs').tabs();

      $tabs.
          tabs( 'url' , 0 , 'programme_items/'+ids+'/description' ).tabs( 'load' , 0 ).tabs('select', 0).
          tabs( 'url' , 1 , 'programme_items/'+ids ).tabs( 'load' , 1 );
      return false;
    }
  }); 
}).navGrid('#pager',{edit:false,add:false,del:false});
