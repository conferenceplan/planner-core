;(function(Form) {

/*
 * Turn a text field into a color editor with a color picker.
 */
Form.editors.Color = Form.editors.Text.extend({

//<input id="c4_title_background" type="text" name="title_background" style="background-color: rgb(82, 92, 35); opacity: 1;">
    
    initialize: function(options) {
        options = options || {};
        
        Form.editors.Base.prototype.initialize.call(this, options);
        
        this.schema = _.extend({ // Pass in extra options for the datetime as part of the schema
        }, options.schema || {});
        
        this.template = options.template || this.constructor.template;
    },
    
    render: function() {
        var $el = $($.trim(this.template({
            field_name : this.key
            })));
        this.setElement($el);
        
        this.setValue(this.value);
        
        var element = this.$el;
        var id = "#c2_" + this.key;
        
        var cp = element.find(id).colorpicker({
            okOnEnter       : true,
            alpha           : false,
            altAlpha        : false,
            colorFormat     : 'RGBA',
            buttonImage     : null,
            buttonText      : ' ',
            showOn          : 'both',
            buttonClass     : "color-control",
            buttonColorize  : true,
            showNoneButton  : true,
            select: function(event, color) {
                element.trigger('blur', element);
            }
        }); 

        return this;
    },
    
    getValue: function() {
        return this.$el.find("#c2_" + this.key).val();
    },
     
    setValue: function(val) {
        this.$el.find("#c2_" + this.key).val(val);
    }
    
}, {
    template: _.template('\
            <span>\
            <input id="c2_<%= field_name %>" class="form-control" name="<%= field_name %>" type="hidden"> \
            </span>\
        ', null, Form.templateSettings),
});

})(Backbone.Form);
