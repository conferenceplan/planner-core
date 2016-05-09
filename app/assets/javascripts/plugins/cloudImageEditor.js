;(function(Form) {

/*
 * An image field for Cloudinary.
 */
Form.editors.CloudImage = Form.editors.Text.extend({
    
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
            })));
        this.setElement($el);
        this.setValue(this.value);
        
        var element = this.$el;
        var field_name = this.key;
        var image_placement = field_name + '_preview';
        var image_container = field_name + '_container';
        var image_place = $el.find("#" + image_container);

        var pargs = { cloud_name: 'grenadine',
                    upload_preset: 'cwqjqwkj', // TODO - name
                    show_powered_by: false, 
                    keep_widget_open: false,
                    theme: 'white',
                    inline_container: image_place[0],
                    cropping: 'server',
                    multiple: false,
                    thumbnails: false,
                    text: {
                      "powered_by_cloudinary": "Powered by Cloudinary - Image management in the cloud",
                      "sources.local.title": I18n.t("cloudinary.widget.sources.local.title"),
                      "sources.local.drop_file": I18n.t("cloudinary.widget.sources.local.drop_file"),
                      "sources.local.drop_files": I18n.t("cloudinary.widget.sources.local.drop_files"),
                      "sources.local.drop_or": I18n.t("cloudinary.widget.sources.local.drop_or"),
                      "sources.local.select_file": I18n.t("cloudinary.widget.sources.local.select_file"),
                      "sources.local.select_files": I18n.t("cloudinary.widget.sources.local.select_files"),
                      "sources.url.title": I18n.t("cloudinary.widget.sources.url.title"),
                      "sources.url.note": I18n.t("cloudinary.widget.sources.url.note"),
                      "sources.url.upload": I18n.t("cloudinary.widget.sources.url.upload"),
                      "sources.url.error": I18n.t("cloudinary.widget.sources.url.error"),
                      "sources.camera.title": I18n.t("cloudinary.widget.sources.camera.title"),
                      "sources.camera.note": I18n.t("cloudinary.widget.sources.camera.note"),
                      "sources.camera.capture": I18n.t("cloudinary.widget.sources.camera.capture"),
                      "progress.uploading": I18n.t("cloudinary.widget.progress.uploading"),
                      "progress.upload_cropped": I18n.t("cloudinary.widget.progress.upload_cropped"),
                      "progress.processing": I18n.t("cloudinary.widget.progress.processing"),
                      "progress.retry_upload": I18n.t("cloudinary.widget.progress.retry_upload"),
                      "progress.use_succeeded": I18n.t("cloudinary.widget.progress.use_succeeded"),
                      "progress.failed_note": I18n.t("cloudinary.widget.progress.failed_note")                        
                    }
            };

        cl_args = $.extend(pargs, this.schema.cl_args);

        var _this = this;
        element.find('#upload_widget_opener').cloudinary_upload_widget(cl_args,
            function(error, result) {
                if (!error) {
                    _this.setValue("image/upload/" + result[0].path + '#' + result[0].signature); // value
                    image_place.find('iframe').css("display","none");
                    $("#" + image_placement).html("");
                    $("#" + image_placement).html("<img src='http://res.cloudinary.com/grenadine/image/upload/c_scale,w_100/"+ result[0].path + "'>");
                } // TODO - report error to user if there is any ???
            }
        );

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
        <div class="upload_section">\
            <input id="<%= field_name %>" class="form-control" name="<%= field_name %>" type="hidden"> \
            <div class="row">\
                <div class="col-sm-12">\
                    <a href="#" id="upload_widget_opener">Upload image</a>\
                    <div id="<%= field_name %>_preview" class="pull-right"></div>\
                </div>\
            </div>\
            <div class="row">\
                <div class="col-sm-12">\
                    <div id="<%= field_name %>_container"></div>\
                </div>\
            </div>\
        </div>\
        ', null, Form.templateSettings),
});

})(Backbone.Form);
