// Register a template definition set named "default".

var emailTemplateStyles = '' +
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
var emailTemplateTop = '<div id="grenadine-email-template-div">' +
                    '<div width="100%" style="background-color: #EEE; padding: 50px; padding-top: 30px;">' +
                        '<table width="600" border="0" cellspacing="0" cellpadding="0" align="center">' +
                            '<tr>' +
                                '<td style="padding: 0px 15px 0px 15px; font-size: 16px; font-family: Arial, Helvetica, sans-serif;">' +
                                    '<div contenteditable="false">' +
                                        '<center>' +
                                            '<h1 contenteditable="false"><span class="grenadine-editable" contenteditable="true">Your Event Name</span></h1>' +
                                        '</center>' +  
                                    '</div>' +                                 
                                '</td>' +
                            '</tr>' +
                        '</table>' +
                        '<table width="600" border="0" cellspacing="0" cellpadding="0" align="center" style="border-top-left-radius: 6px; border-top-right-radius: 6px; background-color: #FFF;">' +
                            '<tr>' +
                                '<td style="padding: 25px 15px 25px 15px; font-size: 16px; font-family: Arial, Helvetica, sans-serif;">';
                                /* Mail text contents go in here, for all templates */
var emailTemplateBottom =            '</td>' +
                            '</tr>' +
                        '</table>' +
                        '<table width="600" border="0" cellspacing="0" cellpadding="0" align="center" style="font-family: Arial, Helvetica, sans-serif; font-size: 11px; color: white; border-bottom-right-radius: 6px; border-bottom-left-radius: 6px; background-color: #CCC;">' +
                            '<tr>' +
                                '<td align="left" style="padding: 15px;">' +
                                    'Sent to you by <strong><span contenteditable="true" class="grenadine-editable">YOUR EVENT NAME</span></strong><br>' +
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
                    
var mobilePageTemplateStyles = '' +
                    '<style>' +
                        'li { margin-top: 10px; }' +
                        'h1 { font-size: 24px; border-bottom: 1px solid gray; padding-bottom: 10px; margin-bottom: 15px; }' +
                    '</style>';                     

var mobilePageTemplateTop =  '' +
                    '<div style="margin:0px;font-family:Roboto, Helvetica, sans-serif;">';

                    
var mobilePageTemplateBottom =  '' +
                    '</div>';
                    
CKEDITOR.timeStamp = '12334s67d689'; // change this string to whatever every time you want 
                               // CKEditor to force reload of this JS instead of super aggressively using cache as it always annoyingly does!
                               
CKEDITOR.addTemplates( 'default',
{
    // The name of the subfolder that contains the preview images of the templates.
    imagesPath : CKEDITOR.getUrl( CKEDITOR.plugins.getPath( 'templates' ) + 'templates/images/' ),
 
    // Template definitions.
    templates :
        [
            {
                title: 'Generic Email',
                image: 'general-purpose-template.png',
                description: 'General-purpose email template. Send informational messages, thank you notes, etc.',
                html: emailTemplateStyles + 
                      emailTemplateTop +
                        '<h1><span class="grenadine-editable" contenteditable="true">My Email Subject</span></h1>' +
                        '<p><span contenteditable="true" class="grenadine-editable">Dear</span><span contenteditable="false"> <strong><%= args[:person].first_name %> <%= args[:person].last_name %></strong></span>,</p>' +
                        '<div contenteditable="true" class="grenadine-editable"><p>We have a message for you and I\'m going to write it here.</p></div>' +                                    
                      emailTemplateBottom        
            },   
            {
                title: 'Invitation to Attend',
                image: 'invitation-template.png',
                description: 'A simple email invitation to your event, includes a button where you can put a link',
                html: emailTemplateStyles + 
                      emailTemplateTop +
                        '<h1><span class="grenadine-editable" contenteditable="true">You\'re invited to attend!</span></h1>' +
                        '<p><span contenteditable="true" class="grenadine-editable">Dear</span><span contenteditable="false"> <strong><%= args[:person].first_name %> <%= args[:person].last_name %></strong></span>,</p>' +
                        '<div contenteditable="true" class="grenadine-editable"><p>We would like to invite you to our event which will take place at this date and time and will be located here.</p></div>' +
                        '<p><span contenteditable="true" class="grenadine-editable"><a href="" class="grenadine-button">Accept or Decline</a></span></p>' +
                        '<div contenteditable="true" class="grenadine-editable"><p>Link doesn\'t work? Then paste this link <a href="">big link here</a> in your browser and type in your unique key code: <strong><%= args[:key] %></strong></p></div>' +                                        
                      emailTemplateBottom        
            },
            {
                title: 'Invitation to Fill out a Survey',
                image: 'survey-template.png',
                description: 'An email invitation to fill out a survey, includes a button where you can link the survey',
                html: emailTemplateStyles + 
                      emailTemplateTop +
                        '<h1><span class="grenadine-editable" contenteditable="true">Please give us your opinion</span></h1>' +
                        '<p><span contenteditable="true" class="grenadine-editable">Dear</span><span contenteditable="false"> <strong><%= args[:person].first_name %> <%= args[:person].last_name %></strong></span>,</p>' +
                        '<div contenteditable="true" class="grenadine-editable"><p>We would love to get your feed-back. Please take a few moments to fill out the following survey:</p></div>' +
                        '<p><span contenteditable="true" class="grenadine-editable"><a href="" class="grenadine-button">Link To Survey</a></span></p>' +
                        '<div contenteditable="true" class="grenadine-editable"><p>Link doesn\'t work? Then paste this link <a href="">big link here</a> in your browser and type in your unique key code: <strong><%= args[:key] %></strong></p></div>' +                                    
                      emailTemplateBottom        
            },
            {
                title: 'Courriel Générique (FR)',
                image: 'general-purpose-template-fr.png',
                description: 'Gabarit général pour l\'envoi de courriels d\'information.',
                html: emailTemplateStyles + 
                      emailTemplateTop +
                        '<h1><span class="grenadine-editable" contenteditable="true">Sujet</span></h1>' +
                        '<p><span contenteditable="true" class="grenadine-editable">Cher</span><span contenteditable="false"> <strong><%= args[:person].first_name %> <%= args[:person].last_name %></strong></span>,</p>' +
                        '<div contenteditable="true" class="grenadine-editable"><p>Nous avons un message bien intéressant pour vous et je vais l\'écrire ici dans ce texte.</p></div>' +                                    
                      emailTemplateBottom        
            },
            {
                title: 'Invitation à votre événement (FR)',
                image: 'invitation-template-fr.png',
                description: 'Une invitation qui inclut un lien/bouton pouvant être utilisé pour diriger vers votre page d\'enregistrement.',
                html: emailTemplateStyles + 
                      emailTemplateTop +
                        '<h1><span class="grenadine-editable" contenteditable="true">Vous êtes invité!</span></h1>' +
                        '<p><span contenteditable="true" class="grenadine-editable">Cher</span><span contenteditable="false"> <strong><%= args[:person].first_name %> <%= args[:person].last_name %></strong></span>,</p>' +
                        '<div contenteditable="true" class="grenadine-editable"><p>Je suis très heureux de vous inviter à notre événement qui se tiendra à cette date et heure et aura lieu à l\'endroit suivant.</p></div>' +
                        '<p><span contenteditable="true" class="grenadine-editable"><a href="" class="grenadine-button">Accepter ou Refuser</a></span></p>' +                                        
                      emailTemplateBottom        
            },
            {
                title: 'Invitation à remplir un sondage (FR)',
                image: 'survey-template-fr.png',
                description: 'Une invitation à remplir un sondage, incluant un bouton qui peut accueillir un lien vers le sondage.',
                html: emailTemplateStyles + 
                      emailTemplateTop +
                        '<h1><span class="grenadine-editable" contenteditable="true">Votre opinion nous importe!</span></h1>' +
                        '<p><span contenteditable="true" class="grenadine-editable">Cher</span><span contenteditable="false"> <strong><%= args[:person].first_name %> <%= args[:person].last_name %></strong></span>,</p>' +
                        '<div contenteditable="true" class="grenadine-editable"><p>Nous aimerions avoir votre opinion. Veuillez remplir le sondage suivant:</p></div>' +
                        '<p><span contenteditable="true" class="grenadine-editable"><a href="" class="grenadine-button">Lien vers le sondage</a></span></p>' +
                        '<div contenteditable="true" class="grenadine-editable"><p>Le lien ne fonctionne pas dans votre lecteur de courriel? Alors copiez le lien suivant et collez-le directement dans votre navigateur: <a href="">lien</a>. Votre code unique est: <strong><%= args[:key] %></strong></p></div>' +                                    
                      emailTemplateBottom        
            },
            {
                title: 'Typical Mobile Content Page',
                image: 'mobile-template.png',
                description: 'A typical mobile page that has text contents',
                html: mobilePageTemplateStyles + 
                      mobilePageTemplateTop +
                        '<h1 contenteditable="false"><span class="grenadine-editable" contenteditable="true">Page Title</span></h1>' +
                        '<div contenteditable="false">' +
                            '<div contenteditable="true" class="grenadine-editable">Write the contents of your page here.</div>' + 
                        '</div>'+                                     
                      mobilePageTemplateBottom        
            },
            {
                title: 'Mobile Page With Title Image',
                image: 'mobile-plus-image-template.png',
                description: 'A mobile page with a title image and contents',
                html: mobilePageTemplateStyles + 
                      mobilePageTemplateTop +
                        '<style type="text/css">.mobile-div-class { padding: 0px; }</style>' +
                        '<img src="/assets/mobile-template-dummy-image.jpg" width="100%"></img>' +
                        '<h1 contenteditable="true" class="grenadine-editable">An Optional Page Title</h1>' +
                        '<div contenteditable="false">' +
                            '<div contenteditable="true" class="grenadine-editable">Write the contents of your page here.</div>' + 
                        '</div>'+                                     
                      mobilePageTemplateBottom        
            }
        ]
});