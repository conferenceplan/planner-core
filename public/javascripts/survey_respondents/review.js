/*
 *
 */
jQuery(document).ready(function(){
    // The grid containing the list of users
    jQuery("#respondents").jqGrid({
        url: '/survey_respondents/reviews/list',
        datatype: 'xml',
        colNames: ['First Name', 'Last Name'],
        colModel: [
		{
            name: 'respondent[first_name]',
            index: 'first_name',
            width: 250,
        },{
			name:'respondent[last_name]',
			index:'last_name',
			width: 250,
        }
		],
        pager: jQuery('#pager'),
        rowNum: 10,
        autowidth: false,
        rowList: [10, 20, 30],
        pager: jQuery('#pager'),
        sortname: 'last_name',
        sortorder: "asc",
        viewrecords: true,
        imgpath: 'stylesheets/cupertino/images',
        caption: 'Survey Respondents',
        onSelectRow: function(ids){
            $('#respondent_id').text(ids);

			$.ajax({
				url: "/survey_respondents/reviews/" + ids,
				context: $('#survey'),
				success: function(data){
					$(this).html(data);
				}
			});
            return false;
        }
    });
    jQuery("#respondents").jqGrid('filterToolbar', {
        stringResult: true,
        searchOnEnter: false
    });
});
