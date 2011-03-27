jQuery(document).ready(function(){
    initialiseDayButtons();
    
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
//        if (itemPage > 1) {
//            itemPage = 1;
//            loadItemWidget();
//        };
    });
    $("#program-rewind").button({
        text: false,
        icons: {
            primary: "ui-icon-seek-prev"
        }
    }).click(function(){
//        if (itemPage > 1) {
//            itemPage -= 1;
//            loadItemWidget();
//        }
    });
    $("#program-forward").button({
        text: false,
        icons: {
            primary: "ui-icon-seek-next"
        }
    }).click(function(){
//        if (itemPage < itemPageNbr) {
//            itemPage += 1;
//            loadItemWidget();
//        }
    });
    $("#program-end").button({
        text: false,
        icons: {
            primary: "ui-icon-seek-end"
        }
    }).click(function(){
//        if (itemPage < itemPageNbr) {
//            itemPage = itemPageNbr;
//            loadItemWidget();
//        }
    });
}
