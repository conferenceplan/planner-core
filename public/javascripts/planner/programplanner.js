var currentDay = 0;

jQuery(document).ready(function(){
    initialiseDayButtons();
    setUpRoomGrid();
});

    
function makeItemWidgetSelectable(){
    makeDraggables();
    //    $('#selectable-item > li').click(function(event){
    //        $("#selectable-item").children(".ui-selected").removeClass("ui-selected"); //make all unselected
    //        // highlight selected only
    //        $(this).addClass('ui-selected');
    //        var id = $(this).find('.itemid').text().trim();
    //        // To get the item context
    //        $.ajax({
    //            type: 'GET',
    //            url: "/programme_items/" + id + "?edit=false",
    //            dataType: "html",
    //            context: $('#current-item-content'),
    //            success: function(response){
    //                $(this).html(response).append('<input type="hidden" name="itemid" value ="' + id + '"/>');
    //                makeDraggables();
    //                makeRemoveables();
    //                currentItem = true;
    //                // change target of form - /programme_items/1/updateParticipants
    //                jQuery('#item-update-form').attr('action', '/programme_items/' + id + '/updateParticipants');
    //                // TODO - reset the participant and reserve areas
    //            }
    //        });
    //    });
}

function initialiseDayButtons(){
    $("#program-beginning").button({
        text: false,
        icons: {
            primary: "ui-icon-seek-start"
        }
    }).click(function(){
        if (currentDay > 0) {
            currentDay = 0;
            setUpRoomGrid();
        };
    });
    $("#program-rewind").button({
        text: false,
        icons: {
            primary: "ui-icon-seek-prev"
        }
    }).click(function(){
        if (currentDay > 0) {
            currentDay -= 1;
            setUpRoomGrid();
        }
    });
    $("#program-forward").button({
        text: false,
        icons: {
            primary: "ui-icon-seek-next"
        }
    }).click(function(){
        if (currentDay < numberOfDays) {
            currentDay += 1;
            setUpRoomGrid();
        }
    });
    $("#program-end").button({
        text: false,
        icons: {
            primary: "ui-icon-seek-end"
        }
    }).click(function(){
        if (currentDay < numberOfDays) {
            currentDay = numberOfDays;
            setUpRoomGrid();
        }
    });

    $("#scroll-left").button({
        text: false,
        icons: {
            primary: "ui-icon-circle-arrow-w"
        }
    }).click(function(){
        $('#program-grid-rooms').scrollTo({top:'-=0px', left:'-=100'}, 0);
        $('#program-grid').scrollTo({top:'-=0px', left:'-=100'}, 0);
    });
    $("#scroll-right").button({
        text: false,
        icons: {
            primary: "ui-icon-circle-arrow-e"
        }
    }).click(function(){
        $('#program-grid-rooms').scrollTo({top:'-=0px', left:'+=100'}, 0);
        $('#program-grid').scrollTo({top:'-=0px', left:'+=100'}, 0);
    });
    $("#scroll-up").button({
        text: false,
        icons: {
            primary: "ui-icon-circle-arrow-n"
        }
    }).click(function(){
        $('#program-grid').scrollTo({top:'-=40px', left:'-=0'}, 0);
        $('#program-grid-times').scrollTo({top:'-=40px', left:'-=0'}, 0);
    });
    $("#scroll-down").button({
        text: false,
        icons: {
            primary: "ui-icon-circle-arrow-s"
        }
    }).click(function(){
        $('#program-grid').scrollTo({top:'+=40px', left:'+=0'}, 0);
        $('#program-grid-times').scrollTo({top:'+=40px', left:'+=0'}, 0);
    });
}

function setUpRoomGrid(){
    $.ajax({
        type: 'POST',
        url: "/program_planner/list?day=" + currentDay,
        dataType: "html",
        data: {
            sidx: 'title',
            sord: 'asc',
        },
        context: $('#program-grid-data'),
        success: function(response){
            titles = $(response).find('#room-titles');
            res = $(response).find('#room-timetable');
            $('#program-room-data').html(titles);
            $(this).html(res);
            $('#program-grid').scrollTo(0);
            $('#program-grid-times').scrollTo(0);
            jQuery('#current-day-page').val(currentDay+1);
            makeDroppables();
        }
    });
}

function makeDraggables(){
    $(".item-draggable").draggable({
        helper: 'clone'
    });
}

function makeDroppables(){
    $(".droppable").droppable({
        hoverClass: "ui-state-hover",
        accept: ":not(.removeable)",
        drop: function(event, ui){
//            var type = $(this).attr('id');
//<div class="itemid" style="display: none;">2 </div>
            var itemid = ui.draggable.find('.itemid').text();
            var roomid = $(this).find('.roomid').text();
            var timeid = $(this).find('.timeid').text();
            var timestart = $(this).find('.timestart').text();
            var timeend = $(this).find('.timeend').text();
            var dt = Date.parse(timestart);
            alert("DROPPED " + itemid + " " + roomid + " "+ timeid + " " + timestart);
            // Ask the user what the start time should be (dialog)
            // Then add the item to the room at the given time
            
            // Add the item to the room
//            // Check to make sure that this has not already been added to the item
//            // 1. Find the .selectable-participant
//            var places = jQuery(".selectable-participant");
//            var doNotInsert = false;
//            places.each(function(index){
//                p = $(this).find("input");
//                p.each(function(ix){
//                    val = $(this).attr('value');
//                    if (val == id) {
//                        doNotInsert = true;
//                    }
//                });
//            });
//            if (!doNotInsert) {
//                $(this).find(".placeholder").remove();
//                // 2. check that none of them 
//                type += '[' + id + '][person_id]'; // TODO - insert the role
//                ui.draggable.find('input').attr('name', type);
//                $("<li class='ui-widget-content removeable'></li>").html(ui.draggable.html()).appendTo($(this).find("ol"));
//                makeRemoveables();
//            }
        }
    });
}
