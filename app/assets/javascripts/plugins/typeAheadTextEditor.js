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
    
})(Backbone.Form);

