var itemPage = 1;
var currentItem = false;
var currentItemName = "";

jQuery(document).ready(function(){
    loadItemWidget();
    
    jQuery('#item-name-search-text').change(function(){
        var name = jQuery('#item-name-search-text').val();
        currentItemName = name;
        itemPage = 1;
        loadItemWidget();
    });
    
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

function loadItemWidget(){
    urlStr = "/programme_items/list";
    if (typeof ignoreScheduled != 'undefined') {
        if (ignoreScheduled == true) {
            urlStr += "?igs=true";
        }
    }
    $.ajax({
        type: 'POST',
        url: urlStr,
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

