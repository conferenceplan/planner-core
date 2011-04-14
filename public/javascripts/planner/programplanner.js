var currentDay = 0;
var ignoreScheduled = true;

jQuery(document).ready(function(){
    initialiseDayButtons();
    setUpRoomGrid();
});

    
function makeItemWidgetSelectable(){
    makeDraggables();
}

function initialiseRemoveButtons(){
    jQuery(".remove-item").click(function(event){
        var q = $(this).attr('href');
        var strs = q.split('&');
        var item = strs[0].substr(8, strs[0].length);
        var room = strs[1].substr(7, strs[1].length);
        // extract the context and tag and then remove these from the tag query collection
        // then force the elements to refresh
        $.ajax({
            type: 'GET',
            url: "/program_planner/removeItem?roomid=" + room + "&itemid=" + item + "",
            dataType: "html",
            success: function(response){
                setUpRoomGrid();
                loadItemWidget();
            }
        });
        
    });
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
            currentDateString = $(response).find('#current-date');
            $('#program-room-data').html(titles);
            $(this).html(res);
            $('#program-grid').scrollTo({top:'-=400px', left:'+=0'}, 0); // position in middle of day (approximately)
            $('#program-grid').scrollTo({top:'320px', left:'0'}, 0);
            $('#program-grid-times').scrollTo({top:'320px', left:'0'}, 0);
            makeDroppables();
            makeDraggables();
            jQuery('#current-day-page').val(currentDateString.text());
            initialiseRemoveButtons();
        }
    });
}

function makeDraggables(){
    $(".item-draggable").draggable({
        helper: 'clone'
    });
}

function createDialog(itemid, roomid, timeid, timestart, duration) {
    var url = "/program_planner/"+ roomid + "/edit?itemid="+itemid+'&timeid='+timeid+'&day='+currentDay;
    initAddItemDialog(url);
    $('#edialog').jqmShow();
}

function initAddItemDialog(url) {
    $('#edialog').jqm({
        ajax: url,
        trigger: 'a.entrydialog',
        onLoad: function(dialog){
                // Put the start time in the field - format as hh:ii
                // Put in the date selector
                startHour = parseInt($('#firsthour', dialog.w).text().trim());
                startMinute= parseInt($('#firstminute', dialog.w).text().trim());
                endHour = parseInt($('#lasthour', dialog.w).text().trim());
                endMinute= parseInt($('#lastminute', dialog.w).text().trim());
                $('#time-selection', dialog.w).timepicker({
                        timeSeparator: ':',
                        defaultTime: startHour + ":" + startMinute,
                        onHourShow: OnHourShowCallback,
                        onMinuteShow: OnMinuteShowCallback
                        });
                adjust(dialog);
            },
        onHide: function(hash){
            hash.w.fadeOut('2000', function(){
                hash.o.remove();
            });
           setUpRoomGrid();
           loadItemWidget();
        }
    });
}

var currentDialog = null;
function adjust(dialog){
    currentDialog = dialog;
    $('.layerform', dialog.w).ajaxForm({
        target: '#form-response',
        success : function() {
                $('#edialog').jqmHide();
        },
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

