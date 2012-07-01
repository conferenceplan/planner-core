/*
 * 
 */
(function($) {
	var methods = {
		init : function(options) {
			var settings = $.extend( {
      			'target'        : 'body',
      			'form'			: '.form'
    		}, options);
    		
			return this.bind('click.cpDialog', function(event) {
				$.ajax({
					type : 'GET',
					url : event.currentTarget.href,
					dataType : "html",
					success : function(response) {
						var form = $(response);
						var submit = $(response).find("input[type='submit']");
						var buttons = {};
						if(submit.html() != null) {
							form.find(":submit").replaceWith("");
							buttons["Submit"] = function() {
								// collect the form and submit it to the server
								var myform = form.find('#layerform');
								var serializedForm = form.find('#layerform').serialize(); // TODO - test with hidden variables
								$.ajax({
									url : myform.attr('action'),
									type : myform.attr('method'),
									context : this,
									data : serializedForm,
									error : function(data) {
										var d = $(data.response);
										d.find(":submit").replaceWith("");
										form.find(settings['form']).replaceWith(d);
									},
									success : function(data) {
										$(this).dialog("close");
										$(settings['target']).html(data);
										settings['success']();
									}
								});
							};
						}

						buttons["Close"] = function() {
							$(this).dialog("close");
						};

						$("<div />").html(form).dialog({
							modal : true,
							buttons : buttons,
							width: 600
						});
					}
				});

				event.preventDefault();
				$(this).removeClass("ui-state-focus ui-state-hover");
			});
		},
		destroy : function() {
			return this.unbind('.cpDialog');
		}
	};

	$.fn.cpDialog = function(method) {
		if(methods[method]) {
			return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
		} else if( typeof method === 'object' || !method) {
			return methods.init.apply(this, arguments);
		} else {
			$.error('Method ' + method + ' does not exist on jQuery.cpDialog');
		}
	};
})(jQuery);
