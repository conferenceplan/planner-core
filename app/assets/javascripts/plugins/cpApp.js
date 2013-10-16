/*
 * 
 */

var AppUtils = (function(){
    var eventAggregator = new Backbone.Wreqr.EventAggregator(); // Event aggregator - global


    /*
     * 
     */
    GenericModal = Backbone.View.extend({
        tagName: "div",
        className: "modal hide fade",
        events: {
            "submit": "submit",
            "hidden": "close",
        },
        
        initialize : function() {
            this.template = _.template($('#modal-edit-template').html()); //_.template(_model_html); //
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
            // console.debug("submit");
            if (e && e.type == "submit") {
                e.preventDefault();
                e.stopPropagation();
            };
            
            var errors = this.submitData();
            
            if (! errors ) {
                if (e.type != "hide") this.$el.modal("hide");
            }
        },
        
        close: function (e) {
            this.form.$el.find('textarea').each(function() { // TODO - we need the correct seletor
                try {
                    if(CKEDITOR.instances[$(this)[0].id] != null) {
                        CKEDITOR.instances[$(this)[0].id].destroy(true);
                    }
                } catch(e){
                    console.error(e);
                }
            });
            
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
    
    /*
     * 
     */
    ModelModal = GenericModal.extend({
        renderBody : function() {
            this.form = new Backbone.Form({
                    model: this.model
            }).render();
        },

        // over-ride for the actual data submission        
        submitData : function() {
            // console.debug("SUBMIT");
            // gather the data and update the underlying model etc.
            var errors = this.form.commit(); // To save the values from the form back into the model
            
            if (!errors) { // save if there are no errors
                var refreshFn = this.options.refresh;
            
                // accept-charset="UTF-8"
                this.model.save(null, { 
                    success : function(mdl) {
                        // Refresh the view if there is a refresh method
                        if (refreshFn) {
                            refreshFn(mdl); // cause problem with templates used ???
                        };
                    },
                    error : function() {
                        alertMessage("Error saving the instance");
                    }
                }); // save the model to the server
            }
            
            return errors; // if there are any errors
        }
    });
    
    // TODO - we need a new View in which we put the selected item (and it's edit info)
    ItemDetailView = Marionette.ItemView.extend({
        events : {
            // "click .model-edit-button"   : "editModel", // flip to an edit view??? TODO
            // "click .model-new-button"    : "newModel",
            // "click .model-delete-button" : "deleteModal",
            "submit"                     : "submit"
        },
        
        submit  : function(e) {
            if (e && e.type == "submit") {
                e.preventDefault();
                e.stopPropagation();
            };
            // alert("Submitted");
            var errors = this.submitData();

            // if (! errors ) {
            // }
        },
        
        submitData : function() {
            // console.debug("SUBMIT");
            // gather the data and update the underlying model etc.
            var errors = this.form.commit(); // To save the values from the form back into the model
            
            if (!errors) { // save if there are no errors
                var refreshFn = this.options.refresh;
            
                // accept-charset="UTF-8"
                this.model.save(null, { 
                    success : function(mdl) {
                        // Refresh the view if there is a refresh method
                        if (refreshFn) {
                            refreshFn(mdl); // cause problem with templates used ???
                        };
                    },
                    error : function() {
                        alertMessage("Error saving the instance");
                    }
                }); // save the model to the server
            }
            
            return errors; // if there are any errors
        },
        
        initialize : function() {
            this.listenTo(this.model, 'change', this.render);
            
            this.template = _.template($('#item-edit-template').html()); //_.template(_model_html); //

            this.model.on("sync", this.options.syncCallback ); // when the modal does the update and second after the update to the server
        },
        
        render : function() {
            this.$el.html($(this.template({
                // title : this.options.title
            })));
            
            // create the form
            this.form = new Backbone.Form({
                    model: this.model
            }).render();
            
            // the render it in the area
            this.$el.find(".modal-body").append(this.form.el);
        }
    });
    
    /*
     * 
     */
    ItemView = Marionette.ItemView.extend({

        events : {
            "click .model-select-button"        : "select",
            "click .model-drill-down-button"    : "drillDown",
            "click .model-edit-button"          : "editModel",
            "click .model-delete-button"        : "deleteModel",
            // "click .model-new-button"    : "newModel",
            // "submit"                     : "submit"
        },
        
        initialize : function() {
            this.listenTo(this.model, 'change', this.render);
            
            if (this.options.url) {
                this.model.urlRoot = this.options.url;
            };

            this.model.on("sync", this.options.syncCallback ); // when the modal does the update and second after the update to the server
        },
        
        select : function(event) {
            if (this.options.selectFn) {
                this.$el.parent().find('tr').removeClass('info');
                this.$el.addClass('info');
                this.options.selectFn(this.model.id);
            }
        },
              
        drillDown : function(event) {
            if (this.options.drillDownFn) {
                this.$el.parent().find('tr').removeClass('info');
                this.$el.addClass('info');
                this.options.drillDownFn(this.model.id);
            }
        },
        
        showModel : function() {
            alert("show");
            this.editModel();
        },
        
        editModel : function() {
            var v = new ItemDetailView({
                model : this.model
                // place : this.options.itemArea
            });
            
            v.render();
            $(this.options.itemArea).html(v.$el);
        },
        
        deleteModel : function() {
            this.model.destroy({
                wait  : true,
                error : function(mdl, response) {
                    alertMessage(response.responseText);
                }
            });
        },
        
        // onRender : function() {
            // this.$el.addClass('XXXX');
        // }
    });

    /*
     * 
     */    
    CollectionView = Backbone.Marionette.CollectionView.extend({
        itemView: ItemView,

        initialize : function() {
            eventAggregator.on(this.options.view_refresh_event, this.refreshList, this);
        },
        
        refreshList : function() {
            this.collection.fetch({});
        }
    });
    
    /*
     * 
     */
    function renderCollection(collection, options) {
        viewType = CollectionView.extend({
                        attributes : options.collection_attributes,
                        itemViewOptions : {
                            template        : options.template,
                            newTitle        : options.newTitle,
                            editTitle       : options.editTitle,
                            attributes      : options.view_attributes,
                            syncCallback    : options.updateCallback,
                            tagName         : typeof options.tagName != 'undefined'  ? options.tagName : 'div',
                            url             : options.modelURL,
                            selectFn        : options.selectFn,
                            drillDownFn     : options.drillDownFn,
                            itemArea        : options.itemArea
                        },
                    });
                    
        var collectionView = new viewType({
                                    collection          : collection,
                                    view_refresh_event  : options.view_refresh_event,
                                    tagName             : typeof options.collection_tagName != 'undefined'  ? options.collection_tagName : 'div' 
                    });

        if (options.place) {
            collectionView.render();
            $(options.place).html(collectionView.el);
        } else {
            options.region.show(collectionView);
        }
    };
    
    /*
     * 
     */
    return {
        eventAggregator : eventAggregator,
        
        GenericModal : GenericModal,
        
        ModelModal : ModelModal,
        
        createCollectionView : function(options) {
            if (!options.collection) {
                collection = new options.collectionType();
                collection.url = options.url;
                collection.fetch({
                    error : function(model, response) {
                        alertMessage("Error communicating with backend"); // TODO - change to translatable string
                    },
                    success : function(col) {
                        renderCollection(col, options);
                    }
                });
            } else {
                renderCollection(options.collection, options);
            };

            return collection;
        }
    };
})();
