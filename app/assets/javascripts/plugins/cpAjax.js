/*
 * 
 */
var AjaxUtils = (function(){
    var pendingAjaxCalls = []; // collection of ajax calls

    return {
        addRequest : function (request) {
            pendingAjaxCalls.push(request);
        },
        
        removeRequest : function(request) {
            idx = _.indexOf(pendingAjaxCalls, request );
            if (typeof idx > -1) {
                pendingAjaxCalls.splice(idx,1);
            };
        },
        
        killRequests : function() { // when a page is unloaded kill any outstanding ajax calls
            _.invoke(pendingAjaxCalls, 'abort' );
            // empty the array
            pendingAjaxCalls = [];
        },
    };
})();

/*
 * Over-ride the jquery .ajax function
 */
jQuery(document).ready(function() {

    $.ajaxSetup({
        beforeSend: function( xhr ) {
            AjaxUtils.addRequest( xhr );
        },
        complete : function(arg) {
            AjaxUtils.removeRequest( arg );
        },
        error : function(response) {
            if (response.status > 0) {
                if (response.responseText) {
                    alertMessage(response.responseText);
                } else {
                    alertMessage("Error communicating with backend"); // TODO - change to translatable string
                };
            };
        }
    });

    window.addEventListener('beforeunload', function() { console.debug("kill requests");
        AjaxUtils.killRequests(); } , false);
});
