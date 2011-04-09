var currentDay = 0;

jQuery(document).ready(function(){
    initialiseDayButtons();
    setUpRoomGrid();
});

    
function makeItemWidgetSelectable(){
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
        }
    });
}

