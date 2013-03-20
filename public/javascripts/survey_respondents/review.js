/*
 *
 */

var currentPersonId = -1;

function copyFormSetup() {

	$('.copy-form form').ajaxForm({
		target: '#survey-states',
		success: function() {
			// TODO - on success refresh the participant area
			copyFormSetup();
			fillParticipantInfo();
		}
	});
	
};

function fillParticipantInfo() {

	// get the id of the participant, and change this to the comp view
	if (currentPersonId != -1) {
		$.ajax({
			url: "/participants/" + currentPersonId + "?comp=true",
			context: $('#participant'),
			success: function(data){
				$(this).html(data);
				$(".addressAccordian").accordion({
					header: 'h3',
	                collapsible: true,
	                autoHeight: false
				});
			}
		});
	}
}

jQuery(document).ready(function(){
		// run the currently selected effect
		function runEffect() {			
			// most effect types need no options passed by default
			var options = {
			};

			// run the effect
			$( "#editslider" ).toggle( "slide", options, 500 );
		};
		
		// set effect from select menu value
		$( "#copybutton" ).click(function() {
			runEffect();
			return false;
		});
		
		$( "#editslider" ).toggle( false ); // Initial hide the copy/edit menu

	
    // The grid containing the list of users
    jQuery("#respondents").jqGrid({
        url: '/survey_respondents/reviews/list',
        datatype: 'xml',
        colNames: ['First Name', 'Last Name', 'Update Date','part id'],
        colModel: [
		{
            name: 'respondent[first_name]',
            index: 'people.first_name',
            width: 250,
        },{
			name:'respondent[last_name]',
			index:'people.last_name',
			width: 250,
        },{
			name:'Update Date',
			index:'survey_respondents.updated_at',
			width: 100,
        },{
			name:'participant[id]',
			width: 30,
			hidden: true
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

			// get the id of the participant, and change this to the comp view
			var rowData = jQuery("#respondents").getRowData(ids);
			currentPersonId = rowData['participant[id]'];

			fillParticipantInfo();
			
			$.ajax({
				url: "/survey_respondents/reviews/" + ids + "/states",
				context: $('#survey-states'),
				success: function(data){
					$(this).html(data);
					
					copyFormSetup();
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
