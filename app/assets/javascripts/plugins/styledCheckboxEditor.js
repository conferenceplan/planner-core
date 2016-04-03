;(function(Form) {

/*
 * 
 */

Form.editors.StyledCheckbox = Form.editors.Checkbox.extend({
    initialize: function(options) {
        options = options || {};
        
        this.schema = _.extend({ // Pass in extra options for the datetime as part of the schema
        }, options.schema || {});
        
        this.template = options.template || this.constructor.template;

        Form.editors.Checkbox.prototype.initialize.call(this, options);
    },

    render: function() {
        var $el = $($.trim(this.template({
                field_name : this.key,
                checked_icon : this.schema.checked_icon,
                unchecked_icon : this.schema.unchecked_icon,
            })));

        this.setElement($el);
        Form.editors.Checkbox.prototype.render.call(this);
       
        return this;
    }
}, {
    template: _.template('\
            <div style="width: 50%;">\
            <label class="styled-checkbox" style="float: right;">\
                <input id="c2_<%= field_name %>" class="form-control" name="<%= field_name %>" type="checkbox"> \
                <i class="<%= unchecked_icon %> unchecked"></i>\
                <i class="<%= checked_icon %> checked"></i>\
                </label>\
            </div>\
        ', null, Form.templateSettings),
});

Form.editors.DependentStyledCheckbox = Form.editors.StyledCheckbox.extend({
    initialize: function(options) {
        this.options = options || {};
        Form.editors.StyledCheckbox.prototype.initialize.call(this, options);
    },
    
    render: function() {
        this.form.on(this.options.schema.dependsOn + ':change', this.dependsOnChanged, this );
       
        this.setValue(this.value);

        this.dependInit(this.form);
        
        return this;
    }
});

})(Backbone.Form);
