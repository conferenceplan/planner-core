
jQuery(document).ready(function(){
    loadParticipantWidget();
    loadItemWidget();
});

function loadParticipantWidget() {
    $.ajax({
        type: 'POST',
        url: "/participants/list",
        dataType: "html",
        data: "page=1&rows=10&sidx=last_name&sord=asc",
        context: $('#participant-widget-content'),
        success: function(response){
            $(this).html(response);
            makeParticipantWidgetSelectable();
        }
    });
}

function makeParticipantWidgetSelectable() {
    $('#selectable-person > li').click(function(event) {
        $("#selectable-person").find(".ui-selected").removeClass("ui-selected"); //make all unselected
        // highlight selected only
        $(this).addClass('ui-selected');
    });
}

function makeDraggables() {
    $( ".draggable" ).draggable({
            helper: 'clone'
        }); // TODO - only make draggable when there is a current item to drag to
    $( ".droppable" ).droppable({
//            activeClass: "ui-state-highlight",
            hoverClass: "ui-state-hover",
            accept: ":not(.ui-sortable-helper)",
            drop: function( event, ui ) {
                //$( this ).find( ".placeholder" ).remove();
                $( "<li class='ui-widget-content'></li>" ).html( ui.draggable.html() ).appendTo( $(this).find("ol") );
            }
        })
}

function loadItemWidget() {
    $.ajax({
        type: 'POST',
        url: "/programme_items/list",
        dataType: "html",
        data: "page=1&rows=10&sidx=title&sord=asc",
        context: $('#items-widget-content'),
        success: function(response){
            $(this).html(response);
            makeItemWidgetSelectable();
        }
    });
}

function makeItemWidgetSelectable() {
    $('#selectable-item > li').click(function(event) {
        $("#selectable-item").children(".ui-selected").removeClass("ui-selected"); //make all unselected
        // highlight selected only
        $(this).addClass('ui-selected');
        var id = $(this).find('.itemid').text();
        // To get the item context
        // /programme_items/1
        $.ajax({
            type: 'GET',
            url: "/programme_items/" + id,
            dataType: "html",
            context: $('#current-item-content'),
            success: function(response){
                $(this).html(response);
                makeDraggables();
            }
        });
    });
}
