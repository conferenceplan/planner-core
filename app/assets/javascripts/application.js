// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

//= require jquery-1.9.1.min
//= require jquery_ujs
//= require jquery-migrate-1.1.1

//= require jquery-ui-1.9.2.custom
//= require jquery.timers-1.2
//= require jquery.timeentry.min

//= require i18n/grid.locale-en
//= require jquery.jqGrid.min

//= require jquery.easy-pie-chart
//= require jquery.mousewheel
//= require jqcloud-1.0.4
//= require colorpicker/jquery.colorpicker
//= require jQuery.download

//= require ckeditor-jquery

//= require bootstrap

//= require backbone/underscore-min
//= require backbone/backbone
//= require backbone/deep-model
//= require backbone/backbone.marionette
//= require backbone/extensions/backbone-relational
//= require backbone/extensions/backbone.paginator
//= require backbone/extensions/backbone-pageable

//= require backbone-forms/distribution/backbone-forms
//= require backbone-forms/distribution/editors/list
//= require backbone-forms/distribution/adapters/backbone.bootstrap-modal
//= require backbone-forms/distribution/templates/bootstrap3

//= require moment/moment+langs

//= require d3/d3.v3

// ---------------
//= require plugins/cpApp
//= require plugins/cpBaseTable
//= require plugins/cpItemTable
//= require plugins/cpParticipantTable
//= require plugins/cpMailHistoryTable
//= require plugins/cpVenueTable
//= require plugins/cpRoomTable
//= require plugins/timeEditor
//= require plugins/htmlEditor
//= require plugins/colorEditor
//= require plugins/DependentEditors
//= require plugins/cpReportBase

//= require TabViews

// TODO - check these
//  require plugins/cpdialog
//  require plugins/cpDynamicArea
//  require plugins/cpremovebutton

//= require_self

jQuery(document).ready(function() {
    _.templateSettings = {
        interpolate : /\{\{\=(.+?)\}\}/g,
        evaluate : /\{\{(.+?)\}\}/g
    };
});

function alertMessage(message) {
    $('#alert-area').html("<div class=\"alert alert-warning fade in\"><button class=\"close\" data-dismiss=\"alert\">×</button>"+ message +"</div>");
};

function infoMessage(message) {
    $('#alert-area').html("<div class=\"alert alert-success alert-block fade in\"><button class=\"close\" data-dismiss=\"alert\">×</button>"+ message +"</div>");
};

// TODO - move these to a component
/****
    Conflict = Backbone.RelationalModel.extend({});
    ConflictCollection = Backbone.Collection.extend({
        model : Conflict
    });
    
    Conflicts = Backbone.RelationalModel.extend({
        relations : [{
            type           : Backbone.HasMany,
            key            : 'schedule',
            relatedModel   : 'Conflict',
            collectionType : 'ConflictCollection',
            // collectionKey  : false, // cause there is no reference from the collection back to the containiing model
        }, {
            type           : Backbone.HasMany,
            key            : 'room',
            relatedModel   : 'Conflict',
            collectionType : 'ConflictCollection',
            // collectionKey  : false, // cause there is no reference from the collection back to the containiing model
        }, {
            type           : Backbone.HasMany,
            key            : 'excluded_item',
            relatedModel   : 'Conflict',
            collectionType : 'ConflictCollection',
            // collectionKey  : false, // cause there is no reference from the collection back to the containiing model
        }, {
            type           : Backbone.HasMany,
            key            : 'excluded_time',
            relatedModel   : 'Conflict',
            collectionType : 'ConflictCollection',
            // collectionKey  : false, // cause there is no reference from the collection back to the containiing model
        }, {
            type           : Backbone.HasMany,
            key            : 'availability',
            relatedModel   : 'Conflict',
            collectionType : 'ConflictCollection',
            // collectionKey  : false, // cause there is no reference from the collection back to the containiing model
        }, {
            type           : Backbone.HasMany,
            key            : 'back_to_back',
            relatedModel   : 'Conflict',
            collectionType : 'ConflictCollection',
            // collectionKey  : false, // cause there is no reference from the collection back to the containiing model
        }]
    });
    
    ConflictView = Marionette.ItemView.extend({
        events: {
            "click .conflict": "selectConflict",
        },
        
        selectConflict : function(ev) {
            // console.debug(this.model.get('item_name'));
            // TODO - scroll to the problem item
            room_name = this.model.get('room_name');
            time = this.model.get('item_start');
            item_id = this.model.get('item_id'); // g id
            
            DailyGrid.scrollTo(room_name, time);
        }
    });
    
    ConflictCollectionView = Backbone.Marionette.CollectionView.extend({
        itemView : ConflictView,
        
        // build the view using a dynamic template based on itemViewTemplate
        buildItemView: function(item, ItemViewType, itemViewOptions){
            var options = _.extend({
                model    : item,
                template : this.options.itemViewTemplate
                }, itemViewOptions);
            
            var view = new ItemViewType(options);

            return view;
        },
    });
    
    function createConflictCollectionView(collection, viewTemplate, region) {
        var collectionView = new ConflictCollectionView({
            collection : collection,
            itemViewTemplate : viewTemplate,
        });
        region.show(collectionView);
    };
    
    ConflictLayout = Backbone.Marionette.Layout.extend({
        regions : {
            scheduleRegion     : "#schedule-region-div",
            roomRegion         : "#room-region-div",
            excludedItemRegion : "#excluded-item-region-div",
            excludedTimeRegion : "#excluded-time-region-div",
            availabilityRegion : "#availability-region-div",
            backToBackRegion   : "#back-to-back-region-div",
        },
    });
***/
