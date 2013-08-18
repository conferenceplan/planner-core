/*
 * 
 */
var TabUtils = (function(){
    var tabModule = {};

    var eventAggregator = new Backbone.Wreqr.EventAggregator();
    
    GenericModal = Backbone.View.extend({
        tagName: "div",
        className: "modal hide fade",
        events: {
            "submit": "submit",
            "hidden": "close",
        },
        
        initialize : function() {
            this.template = _.template($('#modal-edit-template').html())
        },

        modalOptions: {
            backdrop: false,
        },

        render: function () {
            this.$el.html($(this.template({
                title : this.options.title
            })));

            this.delegateEvents();
            
            this.renderBody();
            
            this.$el.find(".modal-body").append(this.form.el);
            
            this.$el.modal(this.modalOptions);

            return this;
        },
        
        submit : function(e) {
            if (e && e.type == "submit") {
                e.preventDefault();
                e.stopPropagation();
            };
            
            this.submitData();
                        
            if (e.type != "hide") this.$el.modal("hide");
            
            // Refresh the view if there is a refresh method
            if (this.options.refresh) {
                this.options.refresh(); // cause problem with templates used ???
            };
        },
        
        close: function (e) {
            this.remove();
            this.unbind();
            this.views = [];  
        },
        
        // over-ride this for the body of the form        
        renderBody : function() {
        },

        // over-ride for the actual data submission        
        submitData : function() {
        }
        
    });

    TabModal = GenericModal.extend({
        renderBody : function() {
            this.form = new Backbone.Form({
                    model: this.model
            }).render();
        },

        // over-ride for the actual data submission        
        submitData : function() {
            // gather the data and update the underlying model etc.
            var errors = this.form.commit(); // To save the values from the form back into the model
            // TODO - check for validation errors (client side???)
            
            this.model.save(null, { 
                wait: true,
                error : function() {
                    alertMessage("Error saving the instance");
                }
            }); // save the model to the server
            
            return errors; // if there are any errors
        }
    });
    
    TagModal = GenericModal.extend({
        renderBody : function() {
            this.form = new Backbone.Form({
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
                },
                error : function() {
                    alertMessage("Error communicating with backend");
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
        },
        
        initialize : function() {
            this.listenTo(this.model, 'change', this.render);
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
            mdl = new TabModal({
                model : this.model,
                title : this.options.editTitle
            });
            mdl.render();
        },
        
        newModel : function() {
            this.model.set('person_id', this.options.person_id);
            mdl = new TabModal({
                model : this.model,
                title : this.options.newTitle
            });
            mdl.render();
        },
        
        deleteModal : function() {
            this.model.destroy();
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
        // template : "#address-control-template",
        events : {
            "click .add-model-button" : "createMdl", //"createAddress",
        },
        
        createMdl : function() {
            var mdl = new this.options.modelType ({ //Address({
                person_id : this.options.person_id
            });
            
            var refreshEvent = this.options.view_refresh_event;

            var modal = new TabModal({
                model : mdl,
                title : this.options.modal_create_title,
                
                refresh : function() {
                    eventAggregator.trigger(refreshEvent);
                }
            });
            modal.render();
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
            detail = new options.modelType();
            detail.fetch({
                url : options.url,
                error : function(model, response) {
                    alertMessage("Error communicating with backend");
                },
                success : function(model) {
                    var tabView = new TabView({
                        template : options.template,
                        person_id : options.id,
                        model : model,
                        newTitle  : options.newTitle,
                        editTitle : options.editTitle,
                    });
                    tabView.render();
                    $(options.place).html(tabView.el);
                }
            });
        } else {
            detail = options.model;
            var tabView = new TabView({
                template : options.template,
                person_id : options.id,
                model : options.model,
                newTitle  : options.newTitle,
                editTitle : options.editTitle,
                });
            tabView.render();
            if (options.region) {
                options.region.show(tabView);
            } else {
                $(options.place).html(tabView.el);
            }
        }
        
        return detail;
    };

    
    tabModule.createTabControl = function createTabControl(options) {
        control = new TabUtils.TabControlView({
            template : options.template,
            person_id : options.id,
            view_refresh_event : options.view_refresh_event,
            modal_create_title : options.modal_create_title,
            modelType : options.modelType
        });
        options.region.show(control);
        
        return control;
    };
    
    tabModule.createTagListContent = function createTagListContent(options) {
        if (!options.collection) {
            collection = new options.collectionType();
            collection.url = options.url
            collection.fetch({
                    error : function(model, response) {
                    alertMessage("Error communicating with backend");
                },
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
    
    tabModule.createTabListContent = function createTabListContent(options) {
        if (!options.collection) {
            collection = new options.collectionType();
            collection.url = options.url
            collection.fetch({
                    error : function(model, response) {
                    alertMessage("Error communicating with backend");
                },
                success : function(col) {
                    viewType = TabCollectionView.extend({
                        attributes : options.collection_attributes,
                        itemViewOptions : {
                            template : options.template,
                            newTitle  : options.newTitle,
                            editTitle : options.editTitle,
                            attributes : options.view_attributes
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
        } else {
            collection = options.collection;
                viewType = TabCollectionView.extend({
                    itemViewOptions : {
                        template : options.template,
                        newTitle  : options.newTitle,
                        editTitle : options.editTitle,
                    },
                });
                var collectionView = new viewType({
                    collection : options.collection,
                });
                options.region.show(collectionView);
        };
        
        return collection;
    };

    return tabModule;
}());
    
