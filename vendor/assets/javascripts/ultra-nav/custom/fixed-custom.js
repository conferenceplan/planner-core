/*------------------------------------------------------------
	ULTRA MENU INIT
	[Please read documentation for additional Information] 
--------------------------------------------------------------*/

// Strict Mode
'use strict';

// Ultra Menu Initialisation
function ultraMenuInit(){

	// Menu Init
	if($('.left-menu-wrapper').length){
		$('.left-menu-wrapper').ultraMenu({

			// Collapse Panel ON/OFF
            collapsePanel: true,

            // Panel Width Settings
            panelWidth: 240,
            collapsePanelWidth: 50,

            // JS based Offcanvas Effect
            offCanvas: true,
            offCanvasSpeed: 220,
            offCanvasClass: 'offcanvas-mode'

		});
	}
}

// Detect Most Mobiles
var isMobile = 'ontouchstart' in document.documentElement && navigator.userAgent.match(/Android|BlackBerry|iPhone|iPad|iPod|Opera Mini|IEMobile|WOW64/i);

// Slimscroll Selector
var wrapper = $('#u-app-wrapper');
var selector_fixed = $('#u-left-menu');
var user_height = $('.panel-user-wrapper').height();

if(isMobile) {
    wrapper.addClass('mobile-true');
}

// Min Height Adjustment on Start (Required for better animations)
function adjustParameter() {
    var height = $(document).height();
    var boxed_view_set = 29; // Same as set in LESS Variables
    
    // Setting min-height via CSS (reqired)
    $("<style type='text/css'> #u-left-panel{ min-height: " + height +"px; } .content-panel{ min-height: " + (height - 80) +"px;} </style>").appendTo("head");

    var top_width = $(window).width() - 2*29;
    // Setting topbar min-width for(boxed && fixed mode)--
    $('#u-topbar').css('min-width', top_width);
}

function handleScrollResize() {
    selector_fixed.css('height', $(window).height() - user_height - 80 + 'px');
}

// Fixed Panel Resizer (TO BE USED WITH SLIMSCROLL)
$('.content-panel').debounce_resize(function(){

    var top_width = $(window).width() - 2*29;
    // Setting topbar min-width for(boxed && fixed mode)--
    $('#u-topbar').css('min-width', top_width);

    if(wrapper.hasClass('panel-fixed')) {
        handleScrollResize();

        if(wrapper.hasClass('panel-cp')) {
            wrapper.removeClass('panel-fixed-custom');
        }
        else {
            wrapper.removeClass('panel-fixed-custom');
            wrapper.addClass('panel-fixed-custom');
        }
    }
});


$(document).ready(function() {
	//UltraMenu Init
	ultraMenuInit();

	// Adjust min height
	adjustParameter();

	// make code pretty
    window.prettyPrint && prettyPrint();

    if(wrapper.hasClass('panel-fixed')) {
        $('.content-panel').trigger('resize');
    }
});
