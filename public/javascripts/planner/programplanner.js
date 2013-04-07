var currentDay = 0;
var ignoreScheduled = true;
var roomList = '[]';
var leftPosn = 0;
var topPosn = 320;

jQuery(document).ready(function(){
    initialiseDayButtons();
    setUpRoomGrid();
    initialiseRoomSelection();
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
    }).repeatedclick(function(){
        $('#program-grid-rooms').scrollTo({top:'-=0px', left:'-=100'}, 0);
        $('#program-grid').scrollTo({top:'-=0px', left:'-=100'}, 0);
        leftPosn = $('#program-grid').scrollLeft();
    },{
        duration: 500,
        speed: 0.8,
        min: 100
    });
    $("#scroll-right").button({
        text: false,
        icons: {
            primary: "ui-icon-circle-arrow-e"
        }
    }).repeatedclick(function(){
        $('#program-grid-rooms').scrollTo({top:'-=0px', left:'+=100'}, 0);
        $('#program-grid').scrollTo({top:'-=0px', left:'+=100'}, 0);
        leftPosn = $('#program-grid').scrollLeft();
    },{
        duration: 500,
        speed: 0.8,
        min: 100
    });
    $("#scroll-up").button({
        text: false,
        icons: {
            primary: "ui-icon-circle-arrow-n"
        }
    }).repeatedclick(function(){
        $('#program-grid').scrollTo({top:'-=40px', left:'-=0'}, 0);
        $('#program-grid-times').scrollTo({top:'-=40px', left:'-=0'}, 0);
topPosn = $('#program-grid').scrollTop();
    },{
        duration: 500,
        speed: 0.8,
        min: 100
    });
    $("#scroll-down").button({
        text: false,
        icons: {
            primary: "ui-icon-circle-arrow-s"
        }
    }).repeatedclick(function(){
        $('#program-grid').scrollTo({top:'+=40px', left:'+=0'}, 0);
        $('#program-grid-times').scrollTo({top:'+=40px', left:'+=0'}, 0);
topPosn = $('#program-grid').scrollTop();
    }, {
        duration: 500,
        speed: 0.8,
        min: 100
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
            rooms: roomList
        },
        context: $('#program-grid-data'),
        success: function(response){
            roomSelector = $(response).find('#room-selection');
            titles = $(response).find('#room-titles');
            res = $(response).find('#room-timetable');
            currentDateString = $(response).find('#current-date');
            $('#program-room-data').html(titles);
            $(this).html(res);
            $('#program-grid-rooms').scrollTo({top:'0', left:leftPosn}, 0);
            $('#program-grid').scrollTo({top:topPosn, left:leftPosn}, 0);
            $('#program-grid-times').scrollTo({top:topPosn, left:leftPosn}, 0);
            makeDroppables();
            makeDraggables();
            jQuery('#current-day-page').val(currentDateString.text());
            initialiseRemoveButtons();
            loadConflictWidget();
        }
    });
}

function makeDraggables(){
    $(".item-draggable").draggable({
        helper: 'clone'
    });
}

function createDialog(itemid, roomid) {
    var url = "/program_planner/"+ roomid + "/edit?itemid="+itemid+'&day='+currentDay;
    initAddItemDialog(url);
    $('#edialog').jqmShow();
}

function initAddItemDialog(url) {
    $('#edialog').jqm({
        ajax: url,
        trigger: 'a.entrydialog',
        onLoad: function(dialog){
                // Put in the time selector
                $('#time-selection', dialog.w).timeEntry({show24Hours: true, showSeconds: false, timeSteps: [1, 15, 0], 
                    defaultTime: '09:00',
                    spinnerImage: 'images/spinnerDefault.png'});
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
        drop: function(event, ui){
            if (intersect($(ui.helper), $(".program-grid"))) {
                var itemid = ui.draggable.find('.itemid').text().trim();
                var roomid = $(this).find('.roomid').text().trim();
                
                createDialog(itemid, roomid); //, timeid, timestart.getHours(), duration);
                // Ask the user what the start time should be (dialog)
                // Then add the item to the room at the given time
            };
            return true;
        }
    });
}

function loadConflictWidget(){
    urlStr = "/program_planner/getConflicts?day=" + currentDay;
    $.ajax({
        type: 'GET',
        url: urlStr,
        dataType: "html",
        context: $('#conflict-widget-content'),
        success: function(response){
            $(this).html(response);
            makeConflictWidgetSelectable();
        }
    });
}

function initialiseRoomSelection() {
    $.ajax({
        type: 'GET',
        url: '/program_planner/getRoomControl',
        dataType: "html",
        context: $('#room-selector'),
        success: function(response){
            $(this).html(response);
            jQuery("#room-selection > .room-check > input").click(function(event){
                roomList = '';
                jQuery("#room-selection").find("input:checked").each( 
                    function() { 
                        if (roomList.length > 0) {
                            roomList += ',';
                        };
                       roomList +=  $(this).val();
                    } 
                );
                roomList = '[' + roomList + ']';
                // re-issue query for grid
                setUpRoomGrid();
            });
        }
    });
    
	$( "#room-selector" ).toggle( false ); // Initial hide the copy/edit menu
    
    $( "#room-selector-button" ).button({
    }).click(function() {
	    $( "#room-selector" ).toggle( "slide", {}, 500 );
		return false;
	});

}

function makeConflictWidgetSelectable(){
    $('#item-conflict-report > div').click(function(event){
        $("#item-conflict-report").children(".ui-selected").removeClass("ui-selected"); //make all unselected
        // highlight selected only
        $(this).addClass('ui-selected');
        var id = $(this).find('.itemid').text().trim();
        var roomid = $(this).find('.roomid').text().trim();
        var itemid = 'item-' + id;
        var roomidstr = 'room-title-' + roomid;
        var topPn = $('#' + itemid).position().top;
        $('#program-grid-times').scrollTo(topPn + 'px', 800, {axis: 'y'});
        $('#program-grid-rooms').scrollTo($('#' + roomidstr), 800);
        $('#program-grid').scrollTo($('#' + itemid), 800, {
            onAfter : function() {
                //topPosn = $('#' + itemid).position().top;
                topPosn = $('#program-grid').scrollTop();
                leftPosn = $('#program-grid').scrollLeft();
            }
        });
    });
}

function intersect(draggable, dropArea){

    var x1 = draggable.offset().left, 
        x2 = x1 + draggable.width(), 
        y1 = draggable.offset().top, 
        y2 = y1 + draggable.height();
    var l = dropArea.offset().left, 
        r = l + dropArea.width(), 
        t = dropArea.offset().top, 
        b = t + dropArea.height();

    return (l < x1 + (draggable.width() / 2) // Right Half
             && x2 - (draggable.width() / 2) < r // Left Half
             && t < y1 + (draggable.height() / 2) // Bottom Half
             && y2 - (draggable.height() / 2) < b);
}
