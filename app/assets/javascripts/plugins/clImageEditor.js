;(function(Form) {

/*
 * An image field for Cloudinary.
 */
Form.editors.CLImage = Form.editors.Text.extend({
    
    initialize: function(options) {
        options = options || {};
        
        Form.editors.Base.prototype.initialize.call(this, options);
        
        this.schema = _.extend({ // Pass in extra options for the datetime as part of the schema
        }, options.schema || {});
        
        this.template = options.template || this.constructor.template;
    },
    
    render: function() {
        // TODO - test to see that the cloudinary config has been setup, if not then display an error message
        
        var $el = $($.trim(this.template({
            field_name : this.key,
            cl_image_upload_tag : this.schema.cl_image_upload_tag
            })));
        this.setElement($el);
        this.setValue(this.value);
        
        var element = this.$el;
        var field_name = this.key;
        element.find('.cloudinary-fileupload').cloudinary_fileupload({
            start: function (e) {
                element.find('.status').html("Starting upload ....");
            },
            progress: function (e, data) {
                element.find('.status').html("Uploading... " + Math.round((data.loaded * 100.0) / data.total) + "%");
            },
            fail: function (e, data) {
                element.find('.status').html("Upload failed " + e);
            }
        }).off("cloudinarydone").on("cloudinarydone", function(e, data) {
            // Put in a preview of the image
            element.find('#' + field_name + '_preview').html(
                        $.cloudinary.image(data.result.public_id, 
                        { format: data.result.format, version: data.result.version, 
                            crop: 'scale', width: 100 }) );
            // and hide the upload button...
            element.find('.cloudinary-fileupload').hide();
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
    template: _.template('\
            <span>\
            <div class="upload_button_holder">\
                <input id="<%= field_name %>" class="form-control" name="<%= field_name %>" type="hidden"> \
                <%= cl_image_upload_tag %>\
                <span class="status"></span>\
                <div id="<%= field_name %>_preview"></div>\
            </div>\
            </span>\
        ', null, Form.templateSettings),
});

})(Backbone.Form);
