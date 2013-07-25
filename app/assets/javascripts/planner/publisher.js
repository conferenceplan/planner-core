/**
 * @author balen
 */
jQuery(document).ready(function(){
    
    $("#items-publish").button({
    }).click(function(){
        $.ajax({
            type: 'GET',
            url: "/publisher/publish",
            dataType: "html",
            success: function(response) {
               $('#result').html(response);
            },
	        beforeSend: function() {
               $('#result').html("<p>Please wait, the system is processing your request...<p>");
            }
        });
    });
    
});
