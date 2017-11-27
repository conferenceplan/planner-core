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
        this.$el.data("attr_model", this.model);
        this.init_callback = schema.init;
    },
     
    render: function() {
        var self = this;

        this.setValue(this.value);
        
        var key = this.key;
        var form = this.form;
        var init = this.init_callback;

        setTimeout(function() {
            self.$el.select2(self.config);
            self.$el.on("change", function (e) {
                self.form.trigger(key + ":change", self, self);

                if (self.schema.changeFn) {
                    self.schema.changeFn.call(self, e);
                }
            });

            if (self.schema.afterInitFn) {
                self.schema.afterInitFn.call(self);
            };
            
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
        var key = this.key;
        var form = this.form;
        var init = this.init_callback;

        this.setValue(this.value);

        setTimeout(function() {
            self.$el.select2(self.config);

            self.$el.on("change", function (e) { 
                self.form.trigger(key + ":change", self, self);

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
