;(function(Form) {
    Form.editors.NumberWithChange = Form.editors.Number.extend({
        initialize: function(options) {
            this.options = options || {};
            Form.editors.Number.prototype.initialize.call(this, options);
        },
        render : function() {
            this.setValue(this.value);
            var self = this;
            this.$el.on("change", function(e) {
                if (self.options.schema.changeFn) {
                    self.options.schema.changeFn.call(self, e);
                }
            });
            return this;
        }
    });
})(Backbone.Form);