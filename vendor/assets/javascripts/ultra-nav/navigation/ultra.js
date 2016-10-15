(function ($, window, document, undefined) {
	'use strict';

	/*
	 * Object extend function
	 */
	function extend(a, b){
		for(var key in b){ 
			if(b.hasOwnProperty(key)){
				a[key] = b[key];
			}
		}
		return a;
	}

	/*
	 * Ultra Menu function
	 */
	function ultra_menu(el, options){  
		
	 	this.el = el;
		this.obj = $(el);
		this.options = extend({}, this.options);
		extend(this.options, options);
		this.openClass = this.options.openClass.split(' ');
		this.closeClass = this.options.closeClass.split(' ');
		// GE -> Global Element
		this.ge = $(this.options.globalElement);
		this.speed = this.options.slideSpeed;
		this.parent = this.options.parent;
		// AC -> Active Class
		this.ac = this.options.activeClass;
		// CP -> Collapse panel
		this.cp = this.options.collapsePanel
		// OC -> Off canvas
		this.oc = this.options.offCanvas;
		// V1 -> Animation var 1
		this.v1 = this.options.animationVar1;
		// V2 -> Animation var 2
		this.v2 = this.options.animationVar2;
		// AS -> Animation speed
		this.as = this.options.animationSpeed;

		this.xs = this.options.screen_xs;

		this._init();
	}
	
	ultra_menu.prototype = {
	 	options: {

	 		// Global link parent selector
	 		parent : 'li.left-menu-parent',
	        
	        // Link UP/DOWN sliding speed
	        slideSpeed : 250,

	        // Panel Toggle Btn selector
	        toggleBtn : '.left-panel-toggle',

	        // Panel Class selectors
	        // Panel SlideDown Class Add
	        activeClass : 'active-state',
	        // Closed link state
	        closeClass : 'fa fa-caret-right',
	        // Open link state
	        openClass : 'fa fa-caret-down',

	        //Scren Breakpoints
	        screen_xs: 768,

	        //  Panel AJAX Settings
	        ajaxLoad : false,
	        ajaxContainer : '.content-panel',
	        defaultURL: '#ajax-data/data1.html',

	        // Global Element +/- Classes
	        globalElement: '#u-app-wrapper',

	        // Collapse Panel ON/OFF
	        collapsePanel: false,
	        preCollapse: false,

	        // Panel Width Settings
	        panelWidth: 240,
	        collapsePanelWidth: 50,

	        // JS based Offcanvas Effect
	        offCanvas: false,
	        offCanvasSpeed: 200,
	        offCanvasClass: 'offcanvas-mode',

	        // Horizontal Mode
	        horizontal: false,
	        horizontalClass: 'panel-horizontal',

	        // Opacity Animation
	        animation: false,
	        animationType: 'opacity',
	        animationVar1: false,
	        animationVar2: false,
	        animationSpeed: 150,

	        // Auto Focus
	        focusOffset: -150,
	        autoFocus: false,
	        focusSpeed: 'slow',

	        // Wide Panel
	        wide: false,
	        wideClass: 'panel-wide',

	        // Show on hover
	        showHover: false,

	        // RTL Mode
	        rtl: false
	 	},
	 	_init: function() {

	 		// Assign Var1 and Var2 Default Values
	 		if (this.options.animation) {
	 			this._animateDefault();
	 		}

	 		// If RTL is ON
	 		if(this.options.rtl){
	 			$('body').addClass('right-true');
	 		}

	 		// If wide screen is ON
	 		if (this.options.wide) {
	 			// PreCollapse is made ON to avoid fullscreen coverage on start
	 			this.options.preCollapse = true;
	 			this.ge.addClass(this.options.wideClass);
	 		}

	 		// IF Show on Hover is ON
	 		if(this.options.showHover && this.cp) {
	 			this.options.preCollapse = true;
	 			this._showOnHover();
	 		}

	 		// Add hiding classes for > self.xs
	 		if (this.options.preCollapse) {
	 			this.cp ? this.ge.addClass('panel-cp panel-lg') : this.ge.addClass('panel-lg');
	 		}

	 		//DOM for Close icon initially
	 		$.closeIconHtml = '<i class="' + this.options.closeClass + '"></i>';

	 		//Detecting and placing the icons
	 		this.obj.find('li').each(function() {
		        if($(this).find('> ul').length) {
		            $(this).find('> a[href="#"] .link-state').append(($.closeIconHtml).trim());
		        }
		    });

	 		// Switching Horizontal Mode
		    if (this.options.horizontal) {
		    	this.ge.addClass(this.options.horizontalClass);
		    }

		    // Adding Collapse class as to use certain CSS
		    if (this.cp) {
		    	this.ge.addClass('collapse-true');
		    }

		    this._handleMenu();
	 	},
	 	// Default Animation Config
	 	_animateDefault: function() {
	 		switch (this.options.animationType) {
	 			case 'explode' : {
	 				this.v1 = this.v1 || 16 ;
	 				this.as = this.as || 'slow';
	 				break;
	 			}
	 			case 'drop' : {
	 				this.v1 = this.v1 || 'left';
	 				this.as = this.as || 'slow';
	 				break;
	 			}
	 			case 'highlight' : {
	 				this.v1 = this.v1 || '#ffff99';
	 				this.as = this.as || 'slow';
	 				break;
	 			}
	 			case 'puff' : {
	 				this.v1 = this.v1 || 150;
	 				this.as = this.as || 'slow';
	 				break;
	 			}
	 			case 'clip' : {
	 				this.v1 = this.v1 || 'horizontal';
	 				this.as = this.as || 'slow';
	 				break;
	 			}
	 			case 'fold' : {
	 				this.v1 = this.v1 || '30%';
	 				this.v2 = this.v2 || false;
	 				this.as = this.as || 'slow';
	 				break;
	 			}
	 			case 'bounce' : {
	 				this.v1 = this.v1 || 55;
	 				this.v2 = this.v2 || 5;
	 				this.as = this.as || 'slow';
	 				break;
	 			}
	 			case 'shake' : {
	 				this.v1 = this.v1 || 20;
	 				this.v2 = this.v2 || 3;
	 				this.as = this.as || 'slow';
	 				break;
	 			}
	 			case 'pulsate' : {
	 				this.v1 = this.v1 || 5;
	 				this.as = this.as || 450;
	 				break;
	 			}
	 			case 'transfer' : {
	 				this.v1 = this.v1 || 'panel-effect-transfer';
	 				this.v2 = this.v2 || '.panel-transfer-temp';
	 				this.as = this.as || 500;
	 				break;
	 			}
	 			case 'opacity' : {
	 				this.v1 = this.v1 || 0;
	 				this.v2 = this.v2 || 1;
	 				self.as = self.as || 600;
	 			}
	 		}
	 	},
	 	// AutoFocus using Scroll Plugin
	 	_autoFocus: function(pos) {
	 		$('html,body').animate({
		        scrollTop: pos + this.options.focusOffset
		    }, this.options.focusSpeed);
	 	},
	 	// Show On Hover
	 	_showOnHover: function() {
	 		// Saving Reference
	 		var self = this;

	 		if (this.options.preCollapse) {
				self.ge.addClass('show-hover-true');
	 		}

	 		self.obj.closest('#u-left-panel').off('mouseenter').on('mouseenter', function() {
	 			if(self.ge.hasClass('panel-cp')) {
	 				self.ge.addClass(self.options.offCanvasClass);
					self.obj.css('width', self.options.collapsePanelWidth).animate({
					    width: self.options.panelWidth
					}, self.options.offCanvasSpeed, '', function () {
					    self.ge.removeClass('panel-cp');
					    self.ge.removeClass('panel-lg');
					    self.ge.removeClass(self.options.offCanvasClass);
					    self.obj.css('width', '');
					});
	 			}
	 		});

	 		self.obj.closest('#u-left-panel').off('mouseleave').on('mouseleave', function() {
	 			if(!self.ge.hasClass('panel-cp') && self.ge.hasClass('show-hover-true') && ($(window).width() > self.xs)) {
	 				// Resetting some menu classes
		            $(self.parent + ' .' + self.ac).each(function(){ $(this).removeClass(self.ac); });
		            $(self.parent + ' ul').each(function(){ $(this).css('display', ''); $(this).closest('li').find('.link-state i').removeClass(self.openClass[1]).addClass(self.closeClass[1]); });
	 				
	 				self.ge.addClass(self.options.offCanvasClass);
					self.obj.css('width', self.options.panelWidth).animate({
					    width: self.options.collapsePanelWidth
					}, self.options.offCanvasSpeed, '', function () {
					    self.ge.addClass('panel-cp');
					    self.ge.addClass('panel-lg');
					    self.ge.removeClass(self.options.offCanvasClass);
					    self.obj.css('width', '');
					});
	 			}
	 		});
	 	},
	 	// Menu Link Events
	 	_handleMenu: function() {

	 		//Saving the reference
	 		var self = this;
	 		
	 		// Handle parent menu
		    this.obj.find(this.parent + ' > a[href="#"]').click(function(e){
		        e.preventDefault();

		        var elm = $(this);
		        
		        var data = elm.parent().find('> ul');
		        
		        if(!self.ge.hasClass('panel-cp') && !(self.ge.hasClass(self.options.horizontalClass) && ($(window).width() > self.xs))) {

		        	if (self.options.autoFocus) {
			        	self._autoFocus(elm.offset().top);
			        }
		        	
		            if (data.is(':visible')){
		                data.slideUp(self.speed, function(){
		                    $(self.parent + '> .' + self.ac).removeClass(self.ac).find('.' + self.openClass[1]).removeClass(self.openClass[1]).addClass(self.closeClass[1]).closest(self.parent).find('ul.left-menu-sub:first').css('display','');
		                });
		            }
		            else {
		                $(self.parent + '> .' + self.ac).parent().find('ul.left-menu-sub').slideUp(self.speed, function(){
		                    $(self.parent + '> .' + self.ac).removeClass(self.ac).find('.' + self.openClass[1]).removeClass(self.openClass[1]).addClass(self.closeClass[1]).closest(self.parent).find('ul.left-menu-sub:first').css('display','');
		                });
		                
		                data.slideDown(self.speed, function(){
		                    elm.addClass(self.ac).find('.' + self.closeClass[1]).removeClass(self.closeClass[1]).addClass(self.openClass[1]);
		                }); 
		            }
		        }

		    });

			// Handle submenu
		    this.obj.find(this.parent + '> ul li a[href="#"]').click(function(e){
		        e.preventDefault();

		        var elm = $(this);
		        var data = elm.parent().find('ul:first');

		        if (!(self.ge.hasClass(self.options.horizontalClass) && ($(window).width() > self.xs))) {

		        	if (self.options.autoFocus) {
			        	self._autoFocus(elm.offset().top);
			        }

			        if (data.is(':visible')){
			            data.slideUp(self.speed, function(){
			                elm.removeClass(self.ac).find('.' + self.openClass[1]).removeClass(self.openClass[1]).addClass(self.closeClass[1]).closest('li').find('ul:first').css('display','');
			            });
			        }
			        else {
			            elm.closest('ul').find('> li > .' + self.ac).parent().find('> ul').slideUp(self.speed, function(){
			                elm.closest('ul').find('> li > .' + self.ac).removeClass(self.ac).find('.' + self.openClass[1]).removeClass(self.openClass[1]).addClass(self.closeClass[1]).closest('li').find('ul:first').css('display','');
			            });
			                
			            data.slideDown(self.speed, function(){
			                elm.addClass(self.ac).find('.' + self.closeClass[1]).removeClass(self.closeClass[1]).addClass(self.openClass[1]);
			            });
			        }
			    }
		    }); 
			this._handleToggle();
			if (self.options.ajaxLoad) {
				this._handleAJAX();
			}
	 	},
	 	// jQuery based OffCanvas Animation
	 	_handleOffcanvas: function(start, end) {
	 		var self = this;
	 		self.ge.addClass(self.options.offCanvasClass);
			self.obj.css('width', start).animate({
			    width: end
			}, self.options.offCanvasSpeed, '', function () {
			    self.ge.removeClass(self.options.offCanvasClass);
			    self.obj.css('width', '');
			});
		},
		_animate: function() {
			//Saving reference
			var self = this;
			
			switch (this.options.animationType) {

				// Opacity Animation
				case 'opacity' : {
					self.obj.closest('#u-left-panel').css('opacity', self.v1).animate({
						opacity: self.v2
					}, self.as, '', function () {
						self.obj.css('opacity', '');
					});
					break;
				}

				// Explode Animation
				case 'explode' : {
					if(!self.ge.hasClass('panel-lg') && !self.ge.hasClass('panel-sm')) {
						self.obj.closest('#u-left-panel').css('display', 'block').toggle("explode",{ pieces: self.v1}, self.as, function() {
							$(this).css('display', '');
						});
					}
					else if(self.ge.hasClass('panel-lg') && !self.ge.hasClass('panel-sm')){ 
						self.obj.closest('#u-left-panel').css('display', 'none').toggle("explode",{ pieces: self.v1}, self.as, function() {
							$(this).css('display', '');
						});
					}
					else { 
						self.obj.closest('#u-left-panel').css('display', 'none').toggle("explode",{ pieces: self.v1}, self.as, function() {
							$(this).css('display', '');
						});
					}
					break;
				}

				// Drop Animation
				case 'drop' : {
					if(!self.ge.hasClass('panel-lg') && !self.ge.hasClass('panel-sm')) {
						self.obj.closest('#u-left-panel').css('display', 'block').toggle("drop", {direction: self.v1}, self.as, function() {
							$(this).css('display', '');
						});
					}
					else if(self.ge.hasClass('panel-lg') && !self.ge.hasClass('panel-sm')){
						self.obj.closest('#u-left-panel').css('display', 'none').toggle("drop", {direction: self.v1}, self.as, function() {
							$(this).css('display', '');
						});
					}
					else {
						self.obj.closest('#u-left-panel').css('display', 'none').toggle("drop", {direction: self.v1}, self.as, function() {
							$(this).css('display', '');
						});
					}
					break;
				}

				// Transfer Animation
				case 'transfer' : {
					if(!self.ge.hasClass('panel-lg')) {
						self.obj.closest('#u-left-panel').effect( "transfer", { to: $(self.v2), className: self.v1 }, self.as );
					}
					else {
						self.obj.closest('#u-left-panel').css('visibility', 'hidden');
						$(self.v2).effect( "transfer", { to: self.obj.closest('#u-left-panel'), className: self.v1 }, self.as, function(){
							self.obj.closest('#u-left-panel').css('visibility', '');
						});
					}
					break;
				}
 
 				// Highlight Animation
				case 'highlight' : {
					if(!self.ge.hasClass('panel-lg') && !self.ge.hasClass('panel-sm')) {
						self.obj.closest('#u-left-menu').css('display', 'block').toggle("highlight", {color: self.v1}, self.as, function() {
							$(this).css('display', '');
						});
					}
					else if(self.ge.hasClass('panel-lg') && !self.ge.hasClass('panel-sm')) {
						self.obj.closest('#u-left-menu').css('display', 'none').toggle("highlight", {color: self.v1}, self.as, function() {
							$(this).css('display', '');
						});
					}
					else {
						self.obj.closest('#u-left-menu').css('display', 'none').toggle("highlight", {color: self.v1}, self.as, function() {
							$(this).css('display', '');
						});
					}
					break;
				}

				// Puff Animation
				case 'puff' : {
					if(!self.ge.hasClass('panel-lg') && !self.ge.hasClass('panel-sm')) {
						self.obj.closest('#u-left-panel').css('display', 'block').toggle("puff", {percent: self.v1}, self.as, function() {
							$(this).css('display', '');
						});
					}
					else if(self.ge.hasClass('panel-lg') && !self.ge.hasClass('panel-sm')){
						self.obj.closest('#u-left-panel').css('display', 'none').toggle("puff", {percent: self.v1}, self.as, function() {
							$(this).css('display', '');
						});
					}
					else {
						self.obj.closest('#u-left-panel').css('display', 'none').toggle("puff", {percent: self.v1}, self.as, function() {
							$(this).css('display', '');
						});
					}
					break;
				}

				// Clip Animation
				case 'clip' : {
					if(!self.ge.hasClass('panel-lg') && !self.ge.hasClass('panel-sm')) {
						self.obj.closest('#u-left-panel').css('display', 'block').toggle("clip", { direction: self.v1}, self.as, function() {
							$(this).css('display', '');
						});
					}
					else if(self.ge.hasClass('panel-lg') && !self.ge.hasClass('panel-sm')) {
						self.obj.closest('#u-left-panel').css('display', 'none').toggle("clip", { direction: self.v1}, self.as, function() {
							$(this).css('display', '');
						});
					}
					else {
						self.obj.closest('#u-left-panel').css('display', 'none').toggle("clip", { direction: self.v1}, self.as, function() {
							$(this).css('display', '');
						});
					}
					break;
				}

				// Fold Animation
				case 'fold' : {
					if(!self.ge.hasClass('panel-lg') && !self.ge.hasClass('panel-sm')) {
						self.obj.closest('#u-left-panel').css('display', 'block').toggle("fold", { size: self.v1, horizFirst: self.v2}, self.as, function() {
							$(this).css('display', '');
						});
					}
					else if(self.ge.hasClass('panel-lg') && !self.ge.hasClass('panel-sm')){
						self.obj.closest('#u-left-panel').css('display', 'none').toggle("fold", { size: self.v1, horizFirst: self.v2}, self.as, function() {
							$(this).css('display', '');
						});
					}
					else {
						self.obj.closest('#u-left-panel').css('display', 'none').toggle("fold", { size: self.v1, horizFirst: self.v2}, self.as, function() {
							$(this).css('display', '');
						});
					}
					break;
				}

				// Bounce Animation
				case 'bounce' : {
					if(!self.ge.hasClass('panel-lg') && !self.ge.hasClass('panel-sm')) {
						self.obj.closest('#u-left-panel').css('display', 'block').toggle("bounce", {distance: self.v1, times: self.v2}, self.as, function() {
							$(this).css('display', '');
						});
					}
					else if(self.ge.hasClass('panel-lg') && !self.ge.hasClass('panel-sm')){
						self.obj.closest('#u-left-panel').css('display', 'none').toggle("bounce", {distance: self.v1, times: self.v2}, self.as, function() {
							$(this).css('display', '');
						});
					}
					else {
						self.obj.closest('#u-left-panel').css('display', 'none').toggle("bounce", {distance: self.v1, times: self.v2}, self.as, function() {
							$(this).css('display', '');
						});
					}
					break;
				}

				// Shake Animation
				case 'shake' : {
					self.obj.closest('#u-left-panel').css('display', 'block').effect("shake", {distance: self.v1, times: self.v2}, self.as, function() {
						$(this).css('display', '');
					});
					break;
				}

				//Pulsate Animation
				case 'pulsate' : {
					self.obj.closest('#u-left-panel').css('display', 'block').css('opacity', 1).effect("pulsate", {times: self.v1}, self.as, function() {
						$(this).css('display', '').css('opacity', '');
					});
					break;
				}
			}
	 	},
	 	_closePanel: function() {

	 		//Saving reference
	 		var self = this;

	 		if (self.ge.hasClass('panel-sm')) {
	 			self.ge.removeClass('panel-sm');
	 		}
	 	},
	 	_handleToggle: function() {

	 		//Saving reference
	 		var self = this;

	 		$(this.options.toggleBtn).click(function(){

	 			//Window width (This scope is required)
	 			var width = $(window).width();
	 			var panelWidthTemp = 240;

	 			// External Mechanism (Clean Collapse Detection)
	 			if(!self.ge.hasClass('collapse-true')) {
	 				self.cp = false;
	 			}
	 			if(self.ge.hasClass('collapse-true') && !self.ge.hasClass('panel-lg')) {
	 				self.cp = true;
	 			}

	 			// Implementing and Extraction of wide Layout
	 			if (self.options.wide || self.ge.hasClass(self.options.wideClass)) {
		 			panelWidthTemp = $(window).width();
		 		}
		 		else {
		 			panelWidthTemp = self.options.panelWidth;
		 		}

		 		if (self.options.showHover) {
		 			self.ge.toggleClass('show-hover-true');
		 		}

	 			// For Large Screen devices
		 		if (width > self.xs) {
		 			self.ge.removeClass('panel-sm');
		 			if(self.options.animation && !self.ge.hasClass('panel-cp')){
		 				self._animate();
		 			}
		 			if(!self.ge.hasClass('panel-lg') && self.oc){
		 				self.cp ? self._handleOffcanvas(panelWidthTemp, self.options.collapsePanelWidth) : self._handleOffcanvas(self.options.panelWidth, 0);
			 		}
			 		else if (self.oc) {
			 			self.cp ? self._handleOffcanvas(self.options.collapsePanelWidth, panelWidthTemp) : self._handleOffcanvas(0, self.options.panelWidth);
			 		}
			 		if (self.cp) {
		 				self.ge.toggleClass('panel-cp');
		 			
		 				// Resetting some menu classes
		                $(self.parent + ' .' + self.ac).each(function(){ $(this).removeClass(self.ac); });
		                $(self.parent + ' ul').each(function(){ $(this).css('display', ''); $(this).closest('li').find('.link-state i').removeClass(self.openClass[1]).addClass(self.closeClass[1]); });
		 			}
		 			if(self.options.animation && !self.ge.hasClass('panel-cp') && self.cp){
		 				self._animate();
		 			}

		 			//Now making it BULLET PROOF(Sync)
		 			if(self.cp){
		 				if(self.ge.hasClass('panel-cp')) {
		 					self.ge.addClass('panel-lg');
		 				}
		 				else {
		 					self.ge.removeClass('panel-lg');
		 				}
		 			}
		 			else{
		 				self.ge.toggleClass('panel-lg');
		 			}
		 		}
		 		else{
		             
		        }

		        // For Small Screen devices
		        if (width <= self.xs) {
		        	self.ge.removeClass('panel-lg');
		            if (self.cp) {
		                self.ge.removeClass('panel-cp');
		            } 
		        	if(self.ge.hasClass('panel-sm') && self.oc){
		        		self._handleOffcanvas(self.options.panelWidth, 0);
			 		}
			 		else if (self.oc) {
			 			self._handleOffcanvas(0, self.options.panelWidth);
			 		}
		        	self.ge.toggleClass('panel-sm');
		        	if(self.options.animation && !self.ge.hasClass('panel-cp')){
		 				self._animate();
		 			}
		        }
		        else {
		            
		        }
		        $(self.options.ajaxContainer).trigger('resize');
		 	});
	 	},
	 	_handleAJAX: function() {

	 		//Saving reference
	 		var self = this;
	 		
	 		// Events for data-toggle="ajax"
		    this.obj.find('a[data-target="ajax"]').click(function(e){
		        e.preventDefault();

		        //Window width (This scope is required)
	 			var width = $(window).width();

		        if (self.options.ajaxLoad) {

		        	//Closing aside-panel on click if viewport < self.xs
			        if (width <= self.xs) {
			            if (self.ge.hasClass('panel-sm'))
			                self.ge.removeClass('panel-sm');
			        }

				    // Updating hash
				    if (window.location.search) {
				        //Setting location.href in case search data exists
				        window.location.href = window.location.href.replace(window.location.hash, "#" + $(this).attr("data-content-location")).replace(window.location.search, "");
				    } 
				    else {
				        //Updating location.hash in case search data donot exist
				        window.location.hash = $(this).attr("data-content-location");
				    }
				    //This must show URL              
			       	//console.log(window.location.hash.replace( /^#/, '' )); 
		        }
		    });

			// Ajax cache config!
			$.ajaxSetup({ cache: false });

			$(window).bind('hashchange', function(e){
			    var page_URL = window.location.hash.replace( /^#/, '' );

			    /*Some Layout Configuration*/
			    //Removing .nav-custom-active from aside-panel
			    $('#u-left-menu .left-menu-active').removeClass('left-menu-active'); 

			    //Adding .nav-custom-active to the clicked URL tag
			    $('#u-left-menu .left-menu-parent:has(a[data-content-location="' + page_URL + '"])').addClass('left-menu-active');

			    //Loading Content Via Ajax
			    self._loadContent(page_URL, $(self.options.ajaxContainer), false);
			});

			if(!window.location.hash){
			    //Setting location.hash if it doesnot exist
			    window.location.hash = self.options.defaultURL;          
			}
			else{
			    //Load the page if hash already exist
			    $(window).trigger('hashchange');
			}
	 	},
	 	_loadContent : function(contentURL, contentBox, callback) {
	 		$.ajax({
			    type: 'GET',
			    url: contentURL,
			    dataType: 'html',
			    cache: false,
		        beforeSend : function(){
		            contentBox.html('<div style="margin-top: 120px; text-align: center;"><i class="fa fa-spinner fa-spin" style="font-size:111px; color:#45484D;"></i></div>');
		        },
		        success : function(data){
		            //Load data in contentBox
		            contentBox.html(data);
		            if(callback)
		            callback();
		        },
		        error: function(){ 
		            //Error handle
		            contentBox.html('<h1><strong>ERROR 404</strong></h1>');
		        },
		        //Async boolean value
		        async: false    
		    });
	 	}
	};

	/*
	 * Extend the options further
	 */
	ultra_menu.options = ultra_menu.prototype.options;

	/*
	 * Ultra Menu Init function
	 */
	$.fn.ultraMenu = function(options){
		new ultra_menu(this, options);
	};

	/*
	 * Add to global namespace
	 */
	window.ultra_menu = ultra_menu;

})(jQuery, window, document);