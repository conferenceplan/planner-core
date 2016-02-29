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
        var $el = $($.trim(this.template({
            field_name : this.key,
            cl_image_upload_tag : this.schema.cl_image_upload_tag
            })));
        this.setElement($el);
        this.setValue(this.value);
        
        var element = this.$el;
        var field_name = this.key; 

        if (this.value) {
            if (typeof this.value == 'string') {
                var image_str = this.value;
                element.find('#' + field_name + '_preview').html(
                        $.cloudinary.image(image_str.replace("image/upload/", ""), 
                        { format: 'jpg', //, version: data.result.version, 
                            crop: 'scale', width: 100 }) );
            }
        }
        
        var that = this;
        element.find('.clear-image').click(function(ev) {
            that.setValue("");
            element.find('#' + field_name + '_preview').html("");
            element.find('.fileinput-button').show();
            return false;
        });

        element.find('.cloudinary-fileupload').cloudinary_fileupload(
        {
            start: function (e) {
                element.find('.progress_bar').css('width', '0%');
            },
            progress: function (e, data) {
                var percent = Math.round((data.loaded * 100.0) / data.total);
                element.find('.progress-bar').css('width', percent + '%');
                if (percent == 100) {
                    element.find('.progress-bar').css('width', percent + '%');
                    element.find('.fileinput-button').hide();
                }    
            },
            fail: function (e, data) {
                element.find('.status').html("Upload failed " + e);
            }
        })
        .off("cloudinarydone").on("cloudinarydone", function(e, data) {
            // Put in a preview of the image
            element.find('#' + field_name + '_preview').html(
                        $.cloudinary.image(data.result.public_id, 
                        { format: data.result.format, version: data.result.version, 
                            crop: 'scale', width: 100 }) );
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
    // cloudinary-fileupload
    template: _.template('\
            <span>\
            <div class="upload_section">\
                <div id="<%= field_name %>_preview" class="pull-left"></div>\
                <div class="upload_button_holder">\
                    <input id="<%= field_name %>" class="form-control" name="<%= field_name %>" type="hidden"> \
                    <span class="btn btn-success fileinput-button">\
                        <span>Select file...</span>\
                        <%= cl_image_upload_tag %>\
                    </span>\
                    <div class="status-area">\
                        <span class="status"></span>\
                        <div class="upload_progress">\
                            <div class="progress progress-success active"><div class="progress-bar progress-bar-success" style="width:0%;"></div></div>\
                        </div>\
                    </div>\
                </div>\
            </div>\
            <div><button class="clear-image btn btn-primary"><i class="glyphicon glyphicon-trash"></i></button></div>\
            </span>\
        ', null, Form.templateSettings),
});

})(Backbone.Form);
