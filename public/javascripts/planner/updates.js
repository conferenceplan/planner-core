/**
 * @author balen
 */
jQuery(document).ready(function(){
    $("#review-updates").button({
    }).click(function(){
    var dateid = $("#date-choice").val();
        var urlstr = "/program/updates"
        if (dateid) {
            urlstr += "?pubidx=" + dateid;
        }
        $.ajax({
            type: 'GET',
            url: urlstr,
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
