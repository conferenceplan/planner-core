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
                    show_powered_by: false, 
                    keep_widget_open: false,
                    // theme: 'minimal',
                    inline_container: image_place[0],
                    upload_preset: 'cwqjqwkj', // TODO - name
                    cropping: 'server',
                    multiple: false,
                    thumbnails: false,
                    // thumbnails: '#' + image_placement,
                    // thumbnail_transformation: {
                              // format: 'jpg',
                              // crop: 'scale', 
                              // width: 100 
                    // }
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
            <div>\
                <a href="#" id="upload_widget_opener">Upload image</a>\
                <div id="<%= field_name %>_preview" class="pull-right"></div>\
            </div>\
            <div>\
                <div id="<%= field_name %>_container"></div>\
            </div>\
        </div>\
        ', null, Form.templateSettings),
});

})(Backbone.Form);
