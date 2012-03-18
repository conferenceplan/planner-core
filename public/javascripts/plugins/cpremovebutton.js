/*
 * 
 */
(function($) {
	var methods = {
		init : function(options) {
			var settings = $.extend( {
      			'target'        : 'body'
    		}, options);
    		
			return this.bind('click.cpRemoveButton', function(event) {
				$.ajax({
					type : 'POST',
					url : event.currentTarget.href,
					dataType : "html",
		            data: {
        		    	'_method' : 'delete' // TODO - would be good to have the authenticity token as well
           			},
		            success: function(data){
						//$('#group_list-'+ id).html(data);
						$(settings['target']).html(data);
						settings['success']();
						//init_group(id);
            		}
            	});
				event.preventDefault();
			});
		},
		destroy : function() {
			return this.unbind('.cpRemoveButton');
		}
	};

	$.fn.cpRemoveButton = function(method) {
		if(methods[method]) {
			return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
		} else if( typeof method === 'object' || !method) {
			return methods.init.apply(this, arguments);
		} else {
			$.error('Method ' + method + ' does not exist on jQuery.cpRemoveButton');
		}
	};
})(jQuery);
