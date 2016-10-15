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

            // Animation
            animation: true,
            animationType: 'fold',
            // Set false to use default value
            animationVar1: '25%',
            // Set false to use default value
            animationVar2: false,
            // Set false to use default value
            animationSpeed: false
		});
	}
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

$(document).ready(function() {
	//UltraMenu Init
	ultraMenuInit();

	//Adjust min-height
	adjustParameter();

	// make code pretty
    window.prettyPrint && prettyPrint();
});
