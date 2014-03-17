/*
 * 
 */
var TabUtils = (function(){
    var tabModule = {};

    var eventAggregator = AppUtils.eventAggregator;

    TagModal = AppUtils.GenericModal.extend({
        renderBody : function() {
            this.form = new Backbone.Form({
                template : _.template('\
                        <form class="form-horizontal" data-fieldsets onsubmit="return false;"></form>\
                '),
                
                schema: {
                    tags: 'Text',
                },
            }).render();
        },

        // over-ride for the actual data submission        
        submitData : function() {
            var data = this.form.getValue();
            $.ajax({
                url : this.options.tagUrl,
                type : 'POST',
                data : { 'tag' : data.tags, 'context' : this.options.tagContext },
                success : function() {
                    eventAggregator.trigger("refreshTagList");
                }
            });
        }
    });
    
    TabView = Marionette.ItemView.extend({
        options : { // The titles should be over-ridden
            newTitle  : "NEW",
            editTitle : "EDIT",
            addTitle : "ADD",
        },
        
        events : {
            "click .model-edit-button"   : "editModel",
            "click .model-new-button"    : "newModel",
            "click .model-delete-button" : "deleteModal",
            "click .model-add-tag-button" : "addTag",
            "click .model-select-button" : "select",
            "click .model-csv-button"    : "select_csv",
            "click .select-tag-button" : "selectTag",
            "click .filter-remove-button" : "removeFilter",
        },
        
       select : function(event) {
            if (this.options.selectFn) {
                this.options.selectFn(this.model.id);
            }
        },
        
        select_csv : function(event) {
            if (this.options.selectCsvFn) {
                this.options.selectCsvFn(this.model.id);
            }
        },
        
        initialize : function() {
            this.listenTo(this.model, 'change', this.render);
            
            // syncCallback            
            if (this.options.url) {
                this.model.urlRoot = this.options.url;
            };

            this.model.on("sync", this.options.syncCallback ); // when the modal does the update and second after the update to the server
            
            // Add extra events
            if (this.options.extra_events) {
                $.extend(this.events, this.options.extra_events);
            }
        },
        
        removeFilter : function(event) {
            var ctx = $(event.target).attr('tagcontext');
            var name = $(event.target).attr('tagname');
            this.model.destroy();
            if (this.options.tagremove) {
                this.options.tagremove(ctx,name);
            }
        },
        
        selectTag : function(event) {
            var ctx = $(event.target).attr('tagcontext');
            var name = $(event.target).attr('tagname');

            if (this.options.tagselect) {
                this.options.tagselect(ctx,name);
            }
        },
        
        addTag : function(event) {
            var ctx = $(event.target).attr('tagcontext');
            // Put up a modal dialog to edit the reg details
            mdl = new TagModal({
                title : this.options.addTitle,
                tagUrl :  this.options.tagUrl,
                tagContext : ctx
            });
            mdl.render();
        },
        editModel : function() {
            // Put up a modal dialog to edit the reg details
            mdl = new AppUtils.ModelModal({
                model : this.model,
                title : this.options.editTitle,
                modal_template : this.options.modal_template
            });
            mdl.render();
            
            if (this.options.form_event) {
                mdl.form.on(this.options.form_event, this.options.form_event_fn );
            }
        },
        
        newModel : function() {
            this.model.set(this.options.id_name, this.options.id);
            mdl = new AppUtils.ModelModal({
                model : this.model,
                title : this.options.newTitle,
                modal_template : this.options.modal_template
            });
            mdl.render();
            
            if (this.options.form_event) {
                mdl.form.on(this.options.form_event, this.options.form_event_fn );
            }
        },
        
        deleteModal : function() {
            this.model.destroy({
                wait: true
            });
        }
    });
    
    TabCollectionView = Backbone.Marionette.CollectionView.extend({
        itemView: TabView,

        initialize : function() {
            eventAggregator.on(this.options.view_refresh_event, this.refreshList, this);
            // this.itemView.set('newTitle', options.newTitle);
            // this.itemView.set('editTitle', options.editTitle);
        },
        
        refreshList : function() {
            this.collection.fetch({});
        }
    });
    
    tabModule.TabControlView = Backbone.Marionette.ItemView.extend({
        events : {
            "click .add-model-button" : "createMdl", //"createAddress",
        },
        
        initialize : function() {
            // Add extra events
            if (this.options.extra_events) {
                $.extend(this.events, this.options.extra_events);
            }
        },
        
        createMdl : function() {
            var mdl = new this.options.modelType({});
            if (this.options.id) {
                mdl.set(this.options.id_name, this.options.id);
            }
            if (this.options.modelURL) {
                mdl.url = this.options.modelURL;
            }
            
            var refreshEvent = this.options.view_refresh_event;
            var callback = this.options.view_callback;
            
            var modal = new AppUtils.ModelModal({
                model : mdl,
                title : this.options.modal_create_title,
                modal_template : this.options.modal_template,
                
                refresh : function(m) {
                    if (refreshEvent) {
                        eventAggregator.trigger(refreshEvent); 
                    }
                    if (callback) {
                        callback(m);
                    }
                }
            });
            modal.render();
                if (this.options.form_event_fn) {
                    modal.form.on(this.options.form_event, this.options.form_event_fn );
                }
            
            return true;
        }
    });
    
    /*
     * modelType
     * URL
     * template
     * place
     */
    tabModule.createTabContent = function createTabContent(options) {
        if (!options.model) {
            showSpinner(options.place);
            
            detail = new options.modelType();
            detail.fetch({
                url : options.url,
                async:false,
                success : function(model) {
                    var tabView = new TabView({
                        template : options.template,
                        id : options.id,
                        id_name : options.id_name, 
                        model : model,
                        newTitle  : options.newTitle,
                        editTitle : options.editTitle,
                        selectFn : options.selectFn,
                        clearFn         : options.clearFn,
                        selectCsvFn : options.selectCsvFn,
                        form_event : options.form_event,
                        form_event_fn : options.form_event_fn,
                        modal_template : options.modal_template,
                        extra_events : options.events
                    });
                    tabView.render();
                    $(options.place).html(tabView.el);
                }
            });
            detail.on("sync", options.updateCallback ); // when the modal does the update and second after the update to the server
        } else {
            detail = options.model;
            var tabView = new TabView({
                template : options.template,
                id : options.id,
                id_name : options.id_name, 
                model : options.model,
                newTitle  : options.newTitle,
                editTitle : options.editTitle,
                selectFn : options.selectFn,
                clearFn         : options.clearFn,
                form_event : options.form_event,
                form_event_fn : options.form_event_fn,
                modal_template : options.modal_template,
                extra_events : options.events
                });
            tabView.render();
            if (options.region) {
                options.region.show(tabView);
            } else {
                $(options.place).html(tabView.el);
            }
            detail.on("sync", options.updateCallback );
        }
        
        return detail;
    };

    
    tabModule.createTabControl = function createTabControl(options) {
        if (options.place) {
            control = new TabUtils.TabControlView({
                template : options.template,
                id : options.id,
                id_name : options.id_name,
                view_refresh_event : options.view_refresh_event,
                modal_create_title : options.modal_create_title,
                modelType : options.modelType,
                view_callback : options.callback,
                modelURL : options.modelURL,
                form_event      : options.form_event,
                form_event_fn   : options.form_event_fn,
                modal_template : options.modal_template,
                extra_events : options.events
            });
            control.render();
            $(options.place).html(control.el);
        } else {
            control = new TabUtils.TabControlView({
                template : options.template,
                id : options.id,
                id_name : options.id_name,
                view_refresh_event : options.view_refresh_event,
                modal_create_title : options.modal_create_title,
                modelType : options.modelType,
                view_callback : options.callback,
                modelURL : options.modelURL,
                form_event      : options.form_event,
                form_event_fn   : options.form_event_fn,
                modal_template : options.modal_template,
                extra_events : options.events
            });
            options.region.show(control);
        }
        
        return control;
    };
    
    tabModule.createTagListContent = function createTagListContent(options) {
        if (!options.collection) {
            collection = new options.collectionType();
            collection.url = options.url;
            collection.fetch({
                success : function(col) {
                    viewType = TabCollectionView.extend({
                        initialize : function() {
                            eventAggregator.on("refreshTagList", this.refreshList, this);
                        },

                        itemViewOptions : {
                            template : options.template,
                            newTitle  : options.newTitle,
                            editTitle : options.editTitle,
                            tagUrl : options.tagUrl
                        },
                        events : {
                            "click .tag-remove-link"   : "removeTag",
                        },
                        removeTag : function(event) {
                            event.preventDefault();
                            $.ajax({
                                url : event.currentTarget,
                                success : function() {
                                    eventAggregator.trigger("refreshTagList");
                                }
                            });
                            
                        }
                    });
                    var collectionView = new viewType({
                        collection : col,
                        view_refresh_event : options.view_refresh_event,
                    });
                    if (options.place) {
                        collectionView.render();
                        $(options.place).html(collectionView.el);
                    } else {
                        options.region.show(collectionView);
                    }
                }
            });
        };
        
        return collection;
    };
    
    tabModule.createTagCloudContent = function createTagCloudContent(options) {
        collection = new options.collectionType();
        collection.url = options.url;
        collection.fetch({
            success : function(col) {
                viewType = TabCollectionView.extend({
                    attributes : options.collection_attributes,
                    itemViewOptions : {
                        template : options.template,
                        newTitle  : options.newTitle,
                        editTitle : options.editTitle,
                        attributes : options.view_attributes,
                        tagselect : options.tagselect,
                        tagremove : options.tagremove
                    },
                });
                var collectionView = new viewType({
                    collection : col,
                    view_refresh_event : options.view_refresh_event,
                });
                if (options.place) {
                    collectionView.render();
                    $(options.place).html(collectionView.el);
                } else {
                    options.region.show(collectionView);
                }
            }
        });
        
        return collection;
    };
    
    tabModule.createTabListContent = function createTabListContent(options) {
        if (!options.collection) {
            collection = new options.collectionType();
            collection.url = options.url;
            collection.fetch({
                success : function(col) {
                    viewType = TabCollectionView.extend({
                        attributes : options.collection_attributes,
                        itemViewOptions : {
                            template : options.template,
                            newTitle  : options.newTitle,
                            editTitle : options.editTitle,
                            attributes : options.view_attributes,
                            tagremove : options.tagremove,
                            syncCallback : options.updateCallback,
                            tagName : typeof options.tagName != 'undefined'  ? options.tagName : 'div',
                            selectFn : options.selectFn,
                            url : options.modelURL,
                            modal_template : options.modal_template
                        },
                    });
                    var collectionView = new viewType({
                        collection : col,
                        tagName : typeof options.collection_tagName != 'undefined'  ? options.collection_tagName : 'div',
                        view_refresh_event : options.view_refresh_event,
                    });
                    if (options.place) {
                        collectionView.render();
                        $(options.place).html(collectionView.el);
                    } else {
                        options.region.show(collectionView);
                    }
                }
            });
        } else {
                viewType = TabCollectionView.extend({
                    attributes : options.collection_attributes,
                    itemViewOptions : {
                        template : options.template,
                        newTitle  : options.newTitle,
                        editTitle : options.editTitle,
                        attributes : options.view_attributes,
                        tagremove : options.tagremove,
                        syncCallback : options.updateCallback,
                        tagName : typeof options.tagName != 'undefined'  ? options.tagName : 'div',
                        selectFn : options.selectFn,
                        url : options.modelURL,
                        modal_template : options.modal_template
                    },
                });
                var collectionView = new viewType({
                    collection : options.collection,
                    tagName : typeof options.collection_tagName != 'undefined'  ? options.collection_tagName : 'div' 
                });
                if (options.place) {
                    collectionView.render();
                    $(options.place).html(collectionView.el);
                } else {
                    options.region.show(collectionView);
                }
        };
        
        return collection;
    };

    return tabModule;
}());
    
