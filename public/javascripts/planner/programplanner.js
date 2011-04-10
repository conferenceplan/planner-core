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

//            createDialog(itemid, roomid, timeid, timestart, timeend);
//    @day = params[:day]
//    @time = params[:time]
//    @item_id = params[:itemid]
//    @room_id = params[:roomid]
//    @freetime_id = params[:timeid]
//             createDialog(itemid, roomid, timeid, timestart.getHours(), duration);
function createDialog(itemid, roomid, timeid, timestart, duration) {
    // TODO change the parameters
    var url = "/program_planner/"+ roomid + "/edit?itemid="+itemid+'timeid='+timeid+'&day='+currentDay;

    $('#edialog').jqm({
        ajax: url,
        trigger: 'a.entrydialog',
        onLoad: function(dialog){
                // Put the start time in the field - format as hh:ii
                // Put in the date selector
                $('#time-selection', dialog.w).timepicker({
                        timeSeparator: ':',
                        defaultTime: '12:00',
                        onHourShow: OnHourShowCallback,
                        onMinuteShow: OnMinuteShowCallback
                        });
                adjust(dialog);
            },
        onHide: function(hash){
            hash.w.fadeOut('2000', function(){
                hash.o.remove();
            });
        }
    });
    // TODO - move the setting of the ajax url to here and then we can move the dialog init out
    $('#edialog').jqmShow();
}

var currentDialog = null;
function adjust(dialog){
    // TODO - would like to display message, disable form, and only allow a close
    currentDialog = dialog;
    $('.layerform', dialog.w).ajaxForm({
        target: '#form-response',
        error: function(response, r) {
            var errText = $(response.responseText).find(".error"); // class error
            $('#form-response', currentDialog.w).append('ERROR: ' + errText.text());
        }
    });
}

function makeDroppables(){
    $(".droppable").droppable({
        hoverClass: "ui-state-hover",
        accept: ":not(.removeable)",
        drop: function(event, ui){
            var itemid = ui.draggable.find('.itemid').text().trim();
            var roomid = $(this).find('.roomid').text().trim();
            var timeid = $(this).find('.timeid').text().trim();
            var timestart = Date.strtodate( $(this).find('.timestart').text().trim(), 'yy-mm-dd hh:ii:ss O');
            var timeend = Date.strtodate( $(this).find('.timeend').text().trim(), 'yy-mm-dd hh:ii:ss O');
            startHour = timestart.getHours();
            startMinute = timestart.getMinutes();
            endHour = timeend.getHours(); // subtract the period from this
            endMinute = timeend.getMinutes();
            var one_min=1000*60*60;
            // to nearest 5 minutes period (one 12th)
            var duration = (Math.round(((timeend.getTime() - timestart.getTime())/one_min)*12))/12.0;
            
            // Calculate what the limits for the time picker
            
            createDialog(itemid, roomid, timeid, timestart.getHours(), duration);
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

var startHour = 0;
var endHour = 23;
function OnHourShowCallback(hour) {
    if ((hour >= startHour) && (hour <= endHour)) {
        return true; // valid
    }
    return false; // not valid
}

var startMinute = 0;
var endMinute = 60;
function OnMinuteShowCallback(hour, minute) {
    if ((hour == endHour ) && (minute >= endMinute)) { return false; } // not valid
    if ((hour == startHour) && (minute < startMinute)) { return false; }   // not valid
    return true;  // valid
}

