﻿// Register a template definition set named "default".

var templateStyles = '' +
                    '<style>' +
                        '.grenadine-button, p.grenadine-button, td a.grenadine-button, td p.grenadine-button {' +
                            'border: 1px solid #C01F40;'+
                            'border-radius: 6px;'+
                            'padding: 13px 20px 13px 20px;'+
                            'width: auto;'+
                            'color: white;'+
                            'font-weight: bold;'+
                            'background-color: #C01F40;'+
                            'text-align: center;'+
                            'text-decoration: none;'+
                            'margin: 15px auto 15px auto;'+
                            'display: inline-block;'+
                            'min-width: 200px;'+
                        '}' +
                    '</style>'; 
var templateTop = '<div id="grenadine-email-template-div">' +
                    '<div contenteditable="false" width="100%" style="background-color: #EEE; padding: 50px; padding-top: 30px;">' +
                        '<table width="600" border="0" cellspacing="0" cellpadding="0" align="center">' +
                            '<tr>' +
                                '<td style="padding: 0px 15px 0px 15px; font-size: 16px; font-family: Arial, Helvetica, sans-serif;">' +
                                    '<center><h1 class="grenadine-editable" contenteditable="true"><strong>Your Event Name</strong></h1></center>' +                                    
                                '</td>' +
                            '</tr>' +
                        '</table>' +
                        '<table width="600" border="0" cellspacing="0" cellpadding="0" align="center" style="border-top-left-radius: 6px; border-top-right-radius: 6px; background-color: #FFF;">' +
                            '<tr>' +
                                '<td style="padding: 25px 15px 25px 15px; font-size: 16px; font-family: Arial, Helvetica, sans-serif;">';
                                /* Mail text contents go in here, for all templates */
var templateBottom =            '</td>' +
                            '</tr>' +
                        '</table>' +
                        '<table width="600" border="0" cellspacing="0" cellpadding="0" align="center" style="font-family: Arial, Helvetica, sans-serif; font-size: 11px; color: white; border-bottom-right-radius: 6px; border-bottom-left-radius: 6px; background-color: #CCC;">' +
                            '<tr>' +
                                '<td align="left" style="padding: 15px;">' +
                                    'Sent to you by <strong><a href=""><span contenteditable="true" class="grenadine-editable">YOUR EVENT NAME</span></a></strong><br>' +
                                    'using the <strong>Grenadine Event Planner</strong>.<br>' +
                                    '420 Beaubien West suite 203, Montreal QC Canada H2V 4S6<br>' +
                                    'http://events.grenadine.co' +
                                '</td>' +
                                '<td  align="right" style="padding: 15px; padding-right: 25px; padding-top: 20px;">' +
                                    '<img src="http://fastmedia.events.grenadine.co/html-email-templates/Grenadine-Event-Planner-Logo-350.png" width="175" style="opacity: 0.6;">' +
                                '</td>' +
                            '</tr>' +
                        '</table>' +
                    '</div>' +
                '</div>';
                    
                    
CKEDITOR.addTemplates( 'default',
{
    // The name of the subfolder that contains the preview images of the templates.
    imagesPath : CKEDITOR.getUrl( CKEDITOR.plugins.getPath( 'templates' ) + 'templates/images/' ),
 
    // Template definitions.
    templates :
        [
            {
                title: 'Invitation to Attend',
                image: 'template1.gif',
                description: 'A simple invitation to your event',
                html: templateStyles + 
                      templateTop +
                        '<h1 class="grenadine-editable" contenteditable="true">You\'re invited to our event!</h1>' +
                        '<p contenteditable="true"><span class="grenadine-editable">Dear</span><span contenteditable="false"> <strong><%= args[:person].first_name %> <%= args[:person].last_name %></strong></span>,</p>' +
                        '<p contenteditable="true" class="grenadine-editable">You\'re invited to our event, which will be held on this date at this place. Please add your text here.</p>' +
                        '<p contenteditable="false"><a href="" class="grenadine-button"><span contenteditable="true">Accept or Decline</span></a></p>' +
                        '<p contenteditable="false">Link doesn\'t work? Then paste this link <a href="">big link here</a> in your browser and type in your unique key code: <strong><%= args[:user].key %></strong></p>' +                                    
                      templateBottom        
            },
            {
                title: 'Invitation to Fill out a Survey',
                image: 'template1.gif',
                description: 'An invitation to fill out a survey',
                html: templateStyles + 
                      templateTop +
                        '<h1 class="grenadine-editable" contenteditable="true">Please Provide Your Feedback</h1>' +
                        '<p contenteditable="true"><span class="grenadine-editable">Dear</span><span contenteditable="false"> <strong><%= args[:person].first_name %> <%= args[:person].last_name %></strong></span>,</p>' +
                        '<p contenteditable="true" class="grenadine-editable">We would like to have your feed-back concerning our event. Please fill out the following survey by clicking on the link below. Thank you.</p>' +
                        '<p contenteditable="false"><a href="" class="grenadine-button"><span contenteditable="true">Fill Out Our Survey</span></a></p>' +
                        '<p contenteditable="false">Link doesn\'t work? Then paste this link <a href="">big link here</a> in your browser and type in your unique key code: <strong><%= args[:user].key %></strong></p>' +                                    
                      templateBottom        
            }
        ]
});