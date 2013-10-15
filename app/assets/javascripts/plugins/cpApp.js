/*
 * 
 */

var TabUtils = (function(){

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
    
}());
