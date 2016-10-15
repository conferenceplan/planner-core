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
            collapsePanel: false,

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

// Slimscroll Selector
var selector_slim = $('#u-left-menu');
// Slimscroll Handlers
function handleScrollResize(){
    var color1;
    if($('body').hasClass('skin-light')){
        color1 = '#000';
    }
    else {
        color1 = '#fff';
    }

    if(selector_slim.parent('.slimScrollDiv').length === 1){
        $('#u-left-menu').slimScroll({
            destroy: true
        });
    }

    selector_slim.slimScroll({
        height: ($(window).height() - 190 + 'px'), // Value 190 is measured by Hit and Trial (Caliberation required) 
        color: color1,
        size: '7px',
        opacity: '0.4',
        alwaysVisible: true,
        allowPageScroll: false,
        disableFadeOut: true,
        wheelStep: 15.0
    });
}

// Fixed Panel Resizer (TO BE USED WITH SLIMSCROLL)
$('.content-panel').debounce_resize(function(){

    var top_width = $(window).width() - 2*29;
    // Setting topbar min-width for(boxed && fixed mode)--
    $('#u-topbar').css('min-width', top_width);

    if($('#u-app-wrapper').hasClass('panel-fixed')) {
        if(!$('#u-app-wrapper').hasClass('panel-cp')){
            handleScrollResize();
        }
        else{
            if(selector_slim.parent('.slimScrollDiv').length === 1){
                selector_slim.css({'overflow':''});
                $('.slimScrollDiv').css({'overflow':''});
                selector_slim.css({'height':''});
                selector_slim.slimScroll({
                    destroy: true
                });
            }
        }
    }
});

// Fixed Panel Resizer (TO BE USED WITH SLIMSCROLL)
$('.content-panel').debounce_resize(function(){

    var top_width = $(window).width() - 2*29;
    // Setting topbar min-width for(boxed && fixed mode)--
    $('#u-topbar').css('min-width', top_width);

    if($('#u-app-wrapper').hasClass('panel-fixed')) {
        if(!$('#u-app-wrapper').hasClass('panel-cp')){
            handleScrollResize();
        }
        else{
            if(selector_slim.parent('.slimScrollDiv').length === 1){
                selector_slim.css({'overflow':''});
                $('.slimScrollDiv').css({'overflow':''});
                selector_slim.css({'height':''});
                selector_slim.slimScroll({
                    destroy: true
                });
            }
        }
    }
});


$(document).ready(function() {
    //UltraMenu Init
    ultraMenuInit();

    if($('#u-app-wrapper').hasClass('panel-fixed')) {
        handleScrollResize();
    }

    // Adjust min height
    adjustParameter();

    // make code pretty
    window.prettyPrint && prettyPrint();
});
