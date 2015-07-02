;(function(Form) {

/*
 * 
 */

Backbone.Form.editors.Select2 = Form.editors.Text.extend({
 
    /**
    * @param {Object} options.schema.config Options to pass to select2. See http://ivaynberg.github.com/select2/#documentation
    */
    initialize: function(options) {
        // Backbone.Form.editors.Base.prototype.initialize.call(this, options);
        options = options || {};
        
        Form.editors.Base.prototype.initialize.call(this, options);
        
        var schema = this.schema;
         
        this.config = schema.config || {};
    },
     
    render: function() {
        var self = this;

        this.setValue(this.value);
         
        setTimeout(function() {
            self.$el.select2(self.config);
        }, 0);
        return this;
    },
     
    getValue: function() {
        return this.$el.val();
    },
     
    setValue: function(val) {
        if (typeof val === 'object') {
            this.$el.val(JSON.stringify(val));
        } else {
            this.$el.val(val);
        }
    }
 
});

})(Backbone.Form);
