/*
 * 
 */
(function($) {
	var methods = {
		init : function(options) {
			var settings = $.extend( {
				'append'		: false,
      			'target'        : 'body',
      			'form'        	: '#layerform',
      			'form-target'   : 'body',
      			'idprefix'      : '#id-',
      			'init'			: function() {}
    		}, options);
    		
			return this.bind('click.cpDynamicArea', function(event) {
				$.ajax({
					url : event.currentTarget.href,
					dataType : "html",
		            success: function(data){
		            	var form = $(data);
						$(settings['target']).html(data);
						$(settings['target']).find("input[type='submit']").click(function(event) {
								var myform = $(settings['target']).find(settings['form']);
								var serializedForm = $(settings['target']).find(settings['form']).serialize(); // TODO - test with hidden variables
								$.ajax({
									url : myform.attr('action'),
									type : myform.attr('method'),
									context : this,
									data : serializedForm,
									error : function(data) {
										var d = $(data.response);
										$(settings['target']).find(settings['form']).replaceWith(d);
									},
									success : function(response) {
										$(settings['form-target']).html(response);
										settings['success']();
									}
								});
								event.preventDefault();
						});
						// convert cancel to ajax call
						$(settings['target']).find('.cancel-link').click(function(event) {
							var url = $(settings['target']).find('.cancel-link').attr('href');
								$.ajax({
									url : url,
									type : 'GET',
									context : this,
									success : function(response) {
										$(settings['form-target']).html(response);
										settings['success']();
									}
									// TODO - add error handling, i.e., server is down
								});
								event.preventDefault();
						})
						settings['init']($(settings['target']));
            		}
            	});

				event.preventDefault();
				$(this).removeClass("ui-state-focus ui-state-hover");
			});
		},
		destroy : function() {
			return this.unbind('.cpDynamicArea');
		}
	};

	$.fn.cpDynamicArea = function(method) {
		if(methods[method]) {
			return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
		} else if( typeof method === 'object' || !method) {
			return methods.init.apply(this, arguments);
		} else {
			$.error('Method ' + method + ' does not exist on jQuery.cpDynamicArea');
		}
	};
})(jQuery);
