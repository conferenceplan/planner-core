var pendingItemPage = 1;
var currentPendingItem = false;
var currentPendingItemName = "";
var ignorePending = true;

/**
 * @author balen
 */
jQuery(document).ready(function(){
    loadPendingItemWidget();
    
    jQuery('#pending-item-name-search-text').change(function(){
        var name = jQuery('#pending-item-name-search-text').val();
        currentPendingItemName = name;
        itemPage = 1;
        loadPendingItemWidget();
    });

    jQuery('#current-pending-item-page').change(function(){
        // set the page to the one indicated and then do a load
        var np = parseInt(jQuery('#current-pending-item-page').val());
        if ((np >= 1) && (np <= pendingItemPageNbr)) {
            pendingItemPage = np;
            loadPendingItemWidget();
        }
    })

    $("#pending-item-beginning").button({
        text: false,
        icons: {
            primary: "ui-icon-seek-start"
        }
    }).click(function(){
        if (pendingItemPage > 1) {
            pendingItemPage = 1;
            loadPendingItemWidget();
        };
    });
    $("#pending-item-rewind").button({
        text: false,
        icons: {
            primary: "ui-icon-seek-prev"
        }
    }).click(function(){
        if (pendingItemPage > 1) {
            pendingItemPage -= 1;
            loadPendingItemWidget();
        } // TODO - disable button ...?
    });
    $("#pending-item-forward").button({
        text: false,
        icons: {
            primary: "ui-icon-seek-next"
        }
    }).click(function(){
        if (pendingItemPage < pendingItemPageNbr) {
            pendingItemPage += 1;
            loadPendingItemWidget();
        }
    });
    $("#pending-item-end").button({
        text: false,
        icons: {
            primary: "ui-icon-seek-end"
        }
    }).click(function(){
        if (pendingItemPage < pendingItemPageNbr) {
            pendingItemPage = pendingItemPageNbr;
            loadPendingItemWidget();
        }
    });

    $("#items-publish").button({
        text: false,
        icons: {
            primary: "ui-icon-arrowthick-1-e"
        }
    }).click(function(){
        var selected = $("#selectable-item").children(".ui-selected");
        var items = {};
        items['items'] = new Array();

        selected.each(function(idx) {
            items['items'].push( $(this).find('.itemid').text().trim() );
        });
        $.ajax({
            type: 'POST',
            url: "/pending_publication_item/add",
            data: items,
            dataType: "html",
            success: function(response){
                $("#selectable-item").children(".ui-selected").removeClass("ui-selected");
                loadPendingItemWidget();
                loadItemWidget();
            }
        });
    });
//publish_publisher POST   /publisher/:id/publish(.:format) {:controller=>"publisher", :action=>"publish"}
    
});

function makeItemWidgetSelectable() {
    $('#selectable-item > li').click(function(event){
        // highlight selected only
        if ($(this).hasClass('ui-selected')) {
            $(this).removeClass('ui-selected');            
        } else {
            $(this).addClass('ui-selected');
        }
    });
}

function loadPendingItemWidget(){
    $.ajax({
        type: 'POST',
        url: "/pending_publication_item/list",
        dataType: "html",
        data: {
            page: pendingItemPage,
            rows: 10,
            sidx: 'title',
            sord: 'asc',
            namesearch: currentPendingItemName
        },
        context: $('#pending-items-widget-content'),
        success: function(response){
            $(this).html(response);
//            makeItemWidgetSelectable();
             jQuery('#current-pending-item-page').val(pendingItemPage);
        }
    });
}
