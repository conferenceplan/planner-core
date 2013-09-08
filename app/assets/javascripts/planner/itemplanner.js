var participantPage = 1;
var currentParticipantName = "";
var placeHolder = '<div class="placeholder"><br/><em>Drag a participant here...</em><br/><br/></div>';

jQuery(document).ready(function(){
    loadParticipantWidget();
    
    jQuery('#participant-name-search-text').change(function(){
        var name = jQuery('#participant-name-search-text').val();
        currentParticipantName = name;
        participantPage = 1;
        loadParticipantWidget();
    });
    
    jQuery('#current-participant-page').change(function(){
        // set the page to the one indicated and then do a load
        var np = jQuery('#current-participant-page').val();
        if ((np >= 1) && (np <= participantPageNbr)) {
            participantPage = np;
            loadParticipantWidget();
        }
    });
    
    $("#participant-beginning").button({
        text: false,
        icons: {
            primary: "ui-icon-seek-start"
        }
    }).click(function(){
        if (participantPage > 1) {
            participantPage = 1;
            loadParticipantWidget();
        }; // TODO - disable button ...?
            });
    $("#participant-rewind").button({
        text: false,
        icons: {
            primary: "ui-icon-seek-prev"
        }
    }).click(function(){
        if (participantPage > 1) {
            participantPage -= 1;
            loadParticipantWidget();
        }; // TODO - disable button ...?
            });
    $("#participant-forward").button({
        text: false,
        icons: {
            primary: "ui-icon-seek-next"
        }
    }).click(function(){
        if (participantPage < participantPageNbr) {
            participantPage += 1; // up to the max
            loadParticipantWidget();
        }
    });
    $("#participant-end").button({
        text: false,
        icons: {
            primary: "ui-icon-seek-end"
        }
    }).click(function(){
        if (participantPage < participantPageNbr) {
            participantPage = participantPageNbr;
            loadParticipantWidget();
        }; // TODO - disable button ...?
    });
    
});

function loadParticipantWidget(){
    $.ajax({
        type: 'POST',
        url: "/participants/list",
        dataType: "html",
        data: {
            page: participantPage,
            rows: '10',
            sidx: 'last_name',
            sord: 'asc',
            namesearch: currentParticipantName,
            filters: '{"groupOp":"OR","rules":[{"field":"acceptance_status_id","op":"eq","data":"8"},{"field":"acceptance_status_id","op":"eq","data":"7"}]}'
        },
        
        context: $('#participant-widget-content'),
        success: function(response){
            $(this).html(response);
            makeParticipantWidgetSelectable();
            if (currentItem == true) {
                makeDraggables();
            };
            // current-participant-page => participantPage
            jQuery('#current-participant-page').val(participantPage);
            $('#current-items-content').html('');
        }
    });
}

function makeRemoveables(){
    $(".removeable").draggable({
        revert: true
    });
}

function makeDraggables(){
    $(".draggable").draggable({
        helper: 'clone'
    }); // TODO - only make draggable when there is a current item to drag to
    $(".droppable").droppable({
        hoverClass: "ui-state-hover",
        accept: ":not(.removeable)",
        drop: function(event, ui){
            var type = $(this).attr('id');
            var id = ui.draggable.find('input').attr('value');
            // Check to make sure that this has not already been added to the item
            // 1. Find the .selectable-participant
            var places = jQuery(".selectable-participant");
            var doNotInsert = false;
            places.each(function(index){
                p = $(this).find("input");
                p.each(function(ix){
                    val = $(this).attr('value');
                    if (val == id) {
                        doNotInsert = true;
                    }
                });
            });
            if (!doNotInsert) {
                $(this).find(".placeholder").remove();
                // 2. check that none of them 
                type += '[' + id + '][person_id]'; // TODO - insert the role
                ui.draggable.find('input').attr('name', type);
                $("<li class='ui-widget-content removeable'></li>").html(ui.draggable.html()).appendTo($(this).find("ol"));
                makeRemoveables();
            }
        }
    });
    $("#trashcan").droppable({
        hoverClass: "ui-state-hover",
        accept: ".removeable",
        drop: function(event, ui){
            // if we have it then we get rid of it!
            ui.draggable.remove();
            fixPlaceHolders();
        }
    });
}

function fixPlaceHolders(){
    var places = jQuery(".selectable-participant");
    places.each(function(index){
        if ($(this).text().trim() == "") {
            $(this).html(placeHolder);
        }
    });
}

function makeItemWidgetSelectable(){
    $('#selectable-item > li').click(function(event){
        $("#selectable-item").children(".ui-selected").removeClass("ui-selected"); //make all unselected
        // highlight selected only
        $(this).addClass('ui-selected');
        var id = $(this).find('.itemid').text().trim();
        // To get the item context
        $.ajax({
            type: 'GET',
            url: "/programme_items/" + id + "?edit=false&plain=true",
            dataType: "html",
            context: $('#current-item-content'),
            success: function(response){
                $(this).html(response).append('<input type="hidden" name="itemid" value ="' + id + '"/>');
                makeDraggables();
                makeRemoveables();
                currentItem = true;
                // change target of form - /programme_items/1/updateParticipants
                jQuery('#item-update-form').attr('action', '/programme_items/' + id + '/updateParticipants');
                // TODO - reset the participant and reserve areas
            }
        });
    });
}

function makeParticipantWidgetSelectable(){
    $('#selectable-person > li').click(function(event){
        var id = $(this).find('.personid').text().trim();
        $("#selectable-person").find(".ui-selected").removeClass("ui-selected"); //make all unselected
        // highlight selected only
        $(this).addClass('ui-selected');
        $.ajax({
            type: 'GET',
            url: "/participants/" + id + "/programme_items",
            dataType: "html",
            context: $('#current-items-content'),
            success: function(response){
                $(this).html(response);
            }
        });
    });
}

