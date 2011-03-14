var participantPage = 1;
var itemPage = 1;
var currentItem = false;
var currentParticipantName = "";
var currentItemName = "";
var placeHolder = '<div class="placeholder"><br/><em>Drag a participant here...</em><br/><br/></div>';

/*
 * TODO - get the upper range for the participants and the items
 *  - Put the list of participants in a collection for submission
 *  - Add save and reset buttons
 *  - Add select role for the participant
 */
jQuery(document).ready(function(){
    loadParticipantWidget();
    loadItemWidget();
    
    jQuery('#participant-name-search-text').change(function(){
        var name = jQuery('#participant-name-search-text').val();
        currentParticipantName = name;
        participantPage = 1;
        loadParticipantWidget();
    });
    
    jQuery('#item-name-search-text').change(function(){
        var name = jQuery('#item-name-search-text').val();
        currentItemName = name;
        itemPage = 1;
        loadItemWidget();
    });
    
    jQuery('#current-participant-page').change(function(){
        // set the age to the one indicated and then do a load
        var np = jQuery('#current-participant-page').val();
        if ((np >= 1) && (np <= participantPageNbr)) {
            participantPage = np;
            loadParticipantWidget();
        }
    })
    
    jQuery('#current-item-page').change(function(){
        // set the age to the one indicated and then do a load
        var np = jQuery('#current-item-page').val();
        if ((np >= 1) && (np <= itemPageNbr)) {
            itemPage = np;
            loadItemWidget();
        }
    })
    
    $("#item-reset").button({
        text: false,
        icons: {
            primary: "ui-icon-circle-close"
        }
    });
    $("#item-save").button({
        text: false,
        icons: {
            primary: "ui-icon-circle-check"
        }
    });
    $("#item-trash").button({
        text: false,
        icons: {
            primary: "ui-icon-trash"
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
    
    $("#item-beginning").button({
        text: false,
        icons: {
            primary: "ui-icon-seek-start"
        }
    }).click(function(){
        if (itemPage > 1) {
            itemPage = 1;
            loadItemWidget();
        }; // TODO - disable button ...?
            });
    $("#item-rewind").button({
        text: false,
        icons: {
            primary: "ui-icon-seek-prev"
        }
    }).click(function(){
        if (itemPage > 1) {
            itemPage -= 1;
            loadItemWidget();
        } // TODO - disable button ...?
    });
    $("#item-forward").button({
        text: false,
        icons: {
            primary: "ui-icon-seek-next"
        }
    }).click(function(){
        if (itemPage < itemPageNbr) {
            itemPage += 1;
            loadItemWidget();
        }
    });
    $("#item-end").button({
        text: false,
        icons: {
            primary: "ui-icon-seek-end"
        }
    }).click(function(){
        if (itemPage < itemPageNbr) {
            itemPage = itemPageNbr;
            loadItemWidget();
        }
    });
    
    $('#item-update-form').ajaxForm({
        target: '#item-update-messages', // area to update with messages
        success: function(response, status){
        }
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
            //            makeParticipantWidgetSelectable();
            if (currentItem == true) {
                makeDraggables();
            };
            // current-participant-page => participantPage
            jQuery('#current-participant-page').val(participantPage);
        }
    });
}

function makeParticipantWidgetSelectable(){
    $('#selectable-person > li').click(function(event){
        $("#selectable-person").find(".ui-selected").removeClass("ui-selected"); //make all unselected
        // highlight selected only
        $(this).addClass('ui-selected');
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

function loadItemWidget(){
    $.ajax({
        type: 'POST',
        url: "/programme_items/list",
        dataType: "html",
        data: {
            page: itemPage,
            rows: 10,
            sidx: 'title',
            sord: 'asc',
            namesearch: currentItemName
        },
        context: $('#items-widget-content'),
        success: function(response){
            $(this).html(response);
            makeItemWidgetSelectable();
            jQuery('#current-item-page').val(itemPage);
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
            url: "/programme_items/" + id + "?edit=false",
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

