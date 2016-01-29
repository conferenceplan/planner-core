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
        this.$el.val(val);
    }
 
});

Form.editors.DependentSelect2 = Form.editors.Select2.extend({

    initialize: function(options) {
        this.options = options || {};
        Form.editors.Select2.prototype.initialize.call(this, options);
    },

    render: function() {
        this.form.on(this.options.schema.dependsOn + ':change', this.dependsOnChanged, this );

        var self = this;

        this.setValue(this.value);

        setTimeout(function() {
            self.$el.select2(self.config);
        }, 0);
        return this;
    }

});

})(Backbone.Form);
