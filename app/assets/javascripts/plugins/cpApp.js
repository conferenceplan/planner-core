/*
 * 
 */

var AppUtils = (function(){
    var eventAggregator = new Backbone.Wreqr.EventAggregator(); // Event aggregator - global
    
   /*
    * 
    */
    InfoModal = Backbone.View.extend({
        tagName: "div",
        className: "modal",
        
        initialize : function() {
            this.template = _.template($('#modal-info-template').html());
        },
        
        modalOptions: {
            backdrop: 'static',
        },

        render: function () {
            Backbone.BootstrapModal.count++;

            this.$el.html($(this.template({
                title : this.options.title
            })));

            this.$el.modal(this.modalOptions);

            if (this.options.content) {
                this.$el.find(".modal-body").append(this.options.content);
            }
            
            this.delegateEvents();
            
            return this;
        },
        
        close: function (e) {
            this.remove();
            this.unbind();
            this.views = [];
            Backbone.BootstrapModal.count--;
        }
    });

    /*
     * 
     */
    GenericModal = Backbone.View.extend({
        tagName: "div",
        className: "modal",
        events: {
            "submit": "submit",
            "hidden": "close",
            "keypress" : "swallow"
        },
        
        swallow : function(e) {
            console.debug("swallow");
                e.stopPropagation();
        },
        
        initialize : function() {
            this.template = _.template($('#modal-edit-template').html());
        },

        modalOptions: {
            backdrop: 'static',
            keyboard : false
        },

        render: function () {
            Backbone.BootstrapModal.count++;

            this.$el.html($(this.template({
                title : this.options.title
            })));

            this.$el.modal(this.modalOptions);

            this.renderBody();
            this.$el.find(".modal-body").append(this.form.el);
            
            this.delegateEvents();
            
            return this;
        },
        
        submit : function(e) {
            console.debug("submit");
            if (e && e.type == "submit") {
                e.preventDefault();
                e.stopPropagation();
            };
            
            var errors = this.submitData();
            
            if (! errors ) {
                if (e.type != "hide") this.$el.modal("hide");
            }
        },
        
        removeCK : function() {

            this.form.$el.find('.cke').each(function() { // TODO - CHECK
                try {
                    if(CKEDITOR.instances[$(this)[0].id] != null) {
                        CKEDITOR.instances[$(this)[0].id].destroy(true);
                    }
                } catch(e){
                    console.error(e);
                }
            });
            
        },
        
        close: function (e) {
            this.removeCK();
            this.remove();
            this.unbind();
            this.views = [];
            Backbone.BootstrapModal.count--;
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
                template : _.template('\
                        <form class="form-horizontal" data-fieldsets onsubmit="return false;"></form>\
                '),
                
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
                    error : function(mdl, response) {
                        alertMessage(response.responseText);
                    }
                }); // save the model to the server
            }
            
            return errors; // if there are any errors
        }
    });
    
    /*
     * 
     */
    ItemEditView = Marionette.ItemView.extend({
        events : {
            "click .model-edit-button"   : "editModel", // flip to an edit view ...
            "click .model-cancel-button" : "cancelEdit", // flip to an edit view ...
            "click .model-submit-button" : "submit"
        },
        
        formEvents : {
        },
        
        editModel : function(e) {
            e.preventDefault();
            e.stopPropagation();
            // flip to the edit view
            this.renderForm();
        },
        
        cancelEdit : function(e) {
            e.preventDefault();
            e.stopPropagation();
            // flip back to the read view
            this.renderModel();
            if (this.options.resetFn) {
                this.options.resetFn(this);
            }
        },
        
        submit  : function(e) {
            e.preventDefault();
            e.stopPropagation();

            var errors = this.submitData();

            if (! errors ) {
                // flip back to the read view
                this.renderModel();
            }
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
                    error : function(mdl, response) {
                        alertMessage(response.responseText);
                    }
                }); // save the model to the server
            };
            
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
            
            this.renderModel();
        },
        
        renderModel : function() {
            // display : none
            this.$el.find('.model-cancel-button').addClass('hidden-button');
            this.$el.find('.model-submit-button').addClass('hidden-button');
            this.$el.find('.model-edit-button').removeClass('hidden-button');
            
            if (this.options.readTemplate) {
                html = _.template($(this.options.readTemplate).html(), this.model.toJSON());
                
                // alert("we have a read template");
                this.$el.find(".model-body").html(html);
            } else {
                this.$el.find(".model-body").html("");
            };
        },
        
        renderForm : function() {
            this.$el.find('.model-cancel-button').removeClass('hidden-button');
            this.$el.find('.model-submit-button').removeClass('hidden-button');
            this.$el.find('.model-edit-button').addClass('hidden-button');
            // display : none
            this.form = new Backbone.Form({
                    model: this.model
            }).render();
            
            var form = this.form;
            // iterate through the form events and add to the form
            _.each(this.formEvents, function(value, key, list) {
                form.on(key, value);
            });
            
            // the render it in the area
            this.$el.find(".model-body").html(this.form.el);
        },
        
        onEvent : function(eventname, func) {
            this.formEvents[eventname] = func;
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
            "click .model-preview-button"       : "preview",
            "click .model-copy-button"          : "copy"
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
            this.editModel();
        },
        
        copy : function(event) {
            if (this.options.copyFn) {
                this.options.copyFn(this.model);
            }
        },
        
        preview : function(event) {
            if (this.options.previewFn) {
                this.options.previewFn(this.model);
            }
        },
              
        drillDown : function(event) {
            if (this.options.drillDownFn) {
                this.$el.parent().find('tr').removeClass('info');
                this.$el.addClass('info');
                this.options.drillDownFn(this.model.id);
            }
        },
        
        editModel : function() {
            // If there is no template then we use a modal
            if (this.options.readTemplate) {
                var v = new ItemEditView({
                    model           : this.model,
                    readTemplate    : this.options.readTemplate
                });
                
                v.render();
                $(this.options.itemArea).html(v.$el);
            } else {
                var modal = new ModelModal({
                    model : this.model,
                    title : this.options.modal_edit_title
                });
                modal.render();
            }
            
        },
        
        deleteModel : function() {
            var clearFn = this.options.clearFn;
            this.model.destroy({
                wait  : true,
                success : function(mdl) {
                    //
                    if (clearFn) {
                        clearFn();
                    }
                },
                error : function(mdl, response) {
                    alertMessage(response.responseText);
                }
            });
        },
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
                        attributes          : options.collection_attributes,
                        itemViewOptions     : {
                            template        : options.template,
                            newTitle        : options.newTitle,
                            editTitle       : options.editTitle,
                            attributes      : options.view_attributes,
                            syncCallback    : options.updateCallback,
                            tagName         : typeof options.tagName != 'undefined'  ? options.tagName : 'div',
                            url             : options.modelURL,
                            selectFn        : options.selectFn,
                            clearFn         : options.clearFn,
                            copyFn          : options.copyFn,
                            previewFn       : options.previewFn,
                            drillDownFn     : options.drillDownFn,
                            itemArea        : options.itemArea,
                            readTemplate    : options.readTemplate,
                            modal_edit_title : options.modal_edit_title
                        }
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
        
    /*
     * 
     */
    return {
        
        partial : function(part, data) {
            return _.template( $('#' + part ).html(), data);
        },
        
        eventAggregator : eventAggregator,
        
        InfoModal : InfoModal,
        
        GenericModal : GenericModal,
        
        ModelModal : ModelModal,
        
        createEditItemView : function(options) {
            var view = new ItemEditView({
                            model           : options.model,
                            template        : options.template,
                            newTitle        : options.newTitle,
                            editTitle       : options.editTitle,
                            attributes      : options.view_attributes,
                            syncCallback    : options.updateCallback,
                            tagName         : typeof options.tagName != 'undefined'  ? options.tagName : 'div',
                            url             : options.modelURL,
                            resetFn         : options.resetFn,
                            // selectFn        : options.selectFn,
                            // clearFn         : options.clearFn,
                            // copyFn          : options.copyFn,
                            // previewFn       : options.previewFn,
                            // drillDownFn     : options.drillDownFn,
                            itemArea        : options.itemArea,
                            readTemplate    : options.readTemplate
            });
            
            view.render();
            $(options.itemArea).html(view.$el);
            
            return view;
        },
        
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
        },
        
        ConflictLayout : ConflictLayout,
        Conflicts : Conflicts,
        
        createConflictCollectionView : function (collection, viewTemplate, region) {
            var collectionView = new ConflictCollectionView({
                collection : collection,
                itemViewTemplate : viewTemplate,
            });
            region.show(collectionView);
        },

        arrayToString : function(cellvalue) {
            if (cellvalue) {
                return cellvalue.join(",<br/>");
            } else {
                return '';
            }
        },

        arrayToStringSingleLine : function(cellvalue) {
            if (cellvalue) {
                return cellvalue.join(", ");
            } else {
                return '';
            }
        }
    
    };
})();
