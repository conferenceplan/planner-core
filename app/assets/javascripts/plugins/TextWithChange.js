;(function(Form) {
    Form.editors.TextWithChange = Form.editors.Text.extend({
        initialize: function(options) {
            this.options = options || {};
            Form.editors.Text.prototype.initialize.call(this, options);
        },
        render : function() {
            this.setValue(this.value);
            var self = this;
            this.on("change", function(e) {
                if (self.options.schema.changeFn) {
                    self.options.schema.changeFn.call(self, e);
                }
            });
            this.on("blur", function(e) {
                if (self.options.schema.blurFn) {
                    self.options.schema.blurFn.call(self, e);
                }
            });

            if (this.options.schema.afterInitFn) {
                this.options.schema.afterInitFn.call(this);
            };

            return this;
        }
    });
})(Backbone.Form);