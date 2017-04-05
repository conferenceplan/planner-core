/*
 * 
 */
;(function(Form) {
    
    Form.editors.TypeAheadText = Form.editors.Text.extend({
        initialize: function(options) {
            options = options || {};
            
            Form.editors.Text.prototype.initialize.call(this, options);
            
            var schema = this.schema;
             
            this.config = schema.config || {};
        },
    
        render: function() {
            var self = this;
            this.setValue(this.value);

            setTimeout(function() {
                self.$el.typeahead(null, self.config);
            }, 0);
    
            return this;
        }
    });

    Form.editors.DependentTypeAheadText = Form.editors.TypeAheadText.extend({

        initialize: function(options) {
            this.options = options || {};
            Form.editors.TypeAheadText.prototype.initialize.call(this, options);
        },

        render: function() {
            this.form.on(this.options.schema.dependsOn + ':change', this.dependsOnChanged, this );

            var self = this;
            this.setValue(this.value);

            setTimeout(function() {
                self.$el.typeahead(null, self.config);

                self.$el.on("change", function (e) { 
                    self.form.trigger(self.key + ":change", self, self);

                    if (self.options.schema.changeFn) {
                        self.options.schema.changeFn.call(self, e);
                    }
                });
                
                if (self.options.schema.afterInitFn) {
                    self.options.schema.afterInitFn.call(self);
                };

            }, 0);

            this.dependInit(this.form);

            return this;
        }

    });
    
})(Backbone.Form);

