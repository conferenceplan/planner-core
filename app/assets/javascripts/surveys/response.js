            $(function(){
                
                if (!$('#pub_first_name').val() && !$('#pub_last_name').val()) {
                    $('div.pubname_toggle').parent().append("<a class='prefix_1 grid_4 toggle_pub_name'>Click to add Publication Name (if different from above)</a>");
                    $('a.toggle_pub_name').click(function(){
                        $('div.pubname_toggle').show();
                        $(this).hide();
                        return false;
                    });
                    $('div.pubname_toggle').hide();
                }
                
                // Prevent submit on return 
                $(window).keydown(function(event){
                    if (event.keyCode == 13 && event.target.tagName != "TEXTAREA") {
                        event.preventDefault();
                        return false;
                    }
                });
                
                function toggleQuestions(state){
                    $('div.timeselect > select').attr('disabled', state);
                    $('div.timeselect input').attr('disabled', state);
                };
                
                if (!$('#timeselect > input').attr("checked")) {
                    toggleQuestions('true');
                };
                
                $('#timeselect').click(function(){
                    $('div.timeselect > select').removeAttr('disabled');
                    $('div.timeselect input').removeAttr('disabled');
                });
                
                $('#timedisable').click(function(){
                    toggleQuestions('true');
                });
                
                // hide all of the elements with a class of 'toggle'
                $('.toggle').hide();
                
                $('a.toggleLink').click(function(){
                    // switch visibility
                    $(this).hide();
                    $(this).next('.toggle').show().next('.toggleLink').show();
                    // return false so link destination for pane is not followed
                    return false;
                });
                
                function split(val){
                    return val.split(/,\s*/);
                }
                function extractLast(term){
                    return split(term).pop();
                }
                
                $('.survey-help').tooltip();
                
                $('.cloud-popover').popover({
                                        html:true,
                                        placement:'left',
                                        content:function(){
                                            // return $(this).data('contentwrapper');
                                            return $($(this).data('contentwrapper')).html();
                                        }
                                    });
                $('.cloud-popover').on('click', function(e) {e.preventDefault(); return true;});

                // Iterate through all the elements in the page and assign the autocomplete to it
                // then make calls to the server to get the tags for each of the associated contexts
                $('div.taggable').each(function(index){ // for all divs that have the class taggable
                    var context = $(this).find('.context').text(); // get the context
                    var element = $(this).find('.' + context + '_text');
                    var $el = $("#" + context + "_cloud");
                    $el.jQCloud(window[context+"_array"], {
                        delayedMode : true,
                        shape : "rectangular"
                    }); // show the tag cloud
                    
                    $.ajax({
                        url: "/survey_respondents/tags/alltags.xml?context=" + context,
                        async: true,
                        dataType: "xml",
                        success: function(xmlResponse){
                            // Put all the tags into an array
                            var gtags = new Array();
                            $(xmlResponse).find("tag").each(function(){
                                gtags.push($(this).text());
                            });
                            
                            // and then use this array with the autocomplete functionality
                            element.autocomplete({
                                source: function(request, response){
                                    var re = $.ui.autocomplete.escapeRegex(extractLast(request.term));
                                    var matcher = new RegExp("^" + re, "i");
                                    var a = $.grep(gtags, function(item, index){
                                        return matcher.test(item);
                                    });
                                    response(a);
                                },
                                focus: function(){
                                    return false; // prevent value insertion on focus
                                },
                                select: function(event, ui){
                                    var terms = split(this.value);
                                    terms.pop(); // remove the current input
                                    terms.push(ui.item.value); // add the selected item
                                    terms.push(""); // add placeholder to get the comma-and-space at the end
                                    this.value = terms.join(", ");
                                    return false;
                                }
                            });
                        }
                    });
                });
                
            });
                