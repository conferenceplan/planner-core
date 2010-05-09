jQuery(document).ready(function(){ 
  jQuery("#particpanttabs").tabs({
	ajaxOptions: { async: false },
	cache: false
  });
});

jQuery(document).ready(function(){ 
  jQuery("#participants").jqGrid({
    url:'participants/list',
    datatype: 'xml',
    colNames:['First Name','Last Name'],
    colModel :[ 
      {name:'first_name', index:'first_name', width:200}, 
      {name:'last_name', index:'last_name', width:250} ],
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
    onSelectRow: function(ids) {
      var $tabs = $('#particpanttabs').tabs();

      $tabs.
          tabs( 'url' , 0 , 'participants/'+ids+'/addresses' ).tabs( 'load' , 0 ).tabs('select', 0).
          tabs( 'url' , 1 , 'participants/'+ids ).tabs( 'load' , 1 );
      return false;
    }
  }); 
}).navGrid('#pager',{edit:false,add:false,del:false});
