;(function(Form) {

/*
 * An image field for Cloudinary.
 */
Form.editors.FileUpload = Form.editors.Text.extend({
    
    initialize: function(options) {
        options = options || {};
        
        Form.editors.Base.prototype.initialize.call(this, options);
        
        this.schema = _.extend({ // Pass in extra options for the datetime as part of the schema
        }, options.schema || {});
        
        this.template = options.template || this.constructor.template;
    },
    
    render: function() {
        var $el = $($.trim(this.template({
                field_name : this.key,
                handler : this.schema.handler
            })));
        this.setElement($el);
        // this.setValue(this.value);
        
        var element = this.$el;
        var field_name = this.key;
        element.find('#' + field_name + '_preview').text(this.value);
        
        element.find('#' + field_name).fileupload({
            dataType: 'json',
            replaceFileInput : false,
            // TODO - good to show a progress or waiting image
            // TODO - what URL to send the file to???
            add : function(e, data) {
                data.context = element.find('#' + field_name + '_preview').text('Uploading...'); //.appendTo(document.body);
                data.submit();
            },
            done: function (e, data) {
                $.each(data.files, function (index, file) {
                    element.find('#' + field_name + '_preview').text(file.name); //.appendTo(file);
                });
            }
        });

        return this;
    },
    
    getValue: function() {
        return this.$el.find("#" + this.key).val();
    },
     
    setValue: function(val) {
        this.$el.find("#" + this.key).val(val);
    }
    
}, {
    // TODO - do we need a data-url in here?
    // also what about multiple???
    template: _.template('\
            <span>\
            <div class="upload_button_holder">\
                <input id="<%= field_name %>" type="file" name="files[]" data-url="<%= handler %>" >\
                <span class="status"></span>\
                <div id="<%= field_name %>_preview"></div>\
            </div>\
            </span>\
        ', null, Form.templateSettings),
});

})(Backbone.Form);
