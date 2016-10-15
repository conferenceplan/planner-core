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
            preCollapse: false,

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

function loadJSON() {

    // pid -> Parent ID
    //id -> Self ID
    
    $.getJSON('json/ultra.json', function(data){

        for (var x in data.ultra) {
            var temp = data.ultra[x].link;

            // Building Main Menu
            if(data.ultra[x].pid === 0) {
                    $('<li class="left-menu-parent">' +
                            '<a href="' + data.ultra[x].link + '" data-id='+ data.ultra[x].id +'>' +
                                '<span class="left-menu-link-icon">' +
                                    '<i class="' + data.ultra[x].linkIcon + '"></i>' +
                                '</span>' +
                                '<span class="left-menu-link-info">' +
                                    '<span class="link-name">' + data.ultra[x].name + '</span>' +
                                    '<span class="link-state"></span>' +
                                '</span>' +
                            '</a>' +
                    '</li>').appendTo(".left-menu-wrapper");
                    if(temp === "#") {
                        $('<ul class="left-menu-sub list-unstyled"></ul>').appendTo($('a[data-id="' + data.ultra[x].id + '"]').parent());
                    }
            }

            // Building Sub Menu (All Levels)
            else {
                $('<li>' +
                    '<a href="' + data.ultra[x].link + '" data-id='+ data.ultra[x].id +'>' +
                        '<span class="left-menu-link-info">' +
                            '<span class="link-name">' + data.ultra[x].name + '</span>' +
                            '<span class="link-state"></span>' +
                        '</span>' +
                    '</a>' +
                '</li>').appendTo($('a[data-id="' + data.ultra[x].pid + '"]').parent().find('ul:first'));
                if(temp === "#") {
                    $('<ul class="list-unstyled"></ul>').appendTo($('a[data-id="' + data.ultra[x].id + '"]').parent());
                }
            }
        }

        // Adding active class to first <li>
        $('.left-menu-wrapper .left-menu-parent:first').addClass('left-menu-active');

        // UltraMenu Init
        ultraMenuInit();
    });
    
}

$(document).ready(function() {

	//load json file
    loadJSON();
	
	// Adjust min height
	adjustParameter();

	// make code pretty
    window.prettyPrint && prettyPrint();

});
