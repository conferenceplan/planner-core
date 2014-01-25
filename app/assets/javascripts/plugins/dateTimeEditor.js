;(function(Form) {

/*
 * Wraps the backbone datetime widget.
 * 
 * NOTE: need a mechanism to take the string but use UTC plus App's TZ offset as the TZ instead of the browser TZ. How?
 */
Form.editors.Datetime = Form.editors.Text.extend({ //Form.editors.Base.extend ({ //
    
    initialize: function(options) {
        options = options || {};
        
        Form.editors.Base.prototype.initialize.call(this, options);
        
        // console.debug(options.schema);
        this.schema = _.extend({ // Pass in extra options for the datetime as part of the schema
        }, options.schema || {});
        
        this.template = options.template || this.constructor.template;
    },
    
    render: function() {
        var options = this.options,
            schema = this.schema,
            ctl = this;

        var $el = $($.trim(this.template({})));
        
        this.setElement($el);
        
        var element = this.$el;
        
        this.picker = element.find('.datetimefield').datetimepicker(this.schema.picker);
        this.setInitialValue(this.value);
        
        return this;
    },
    
    // We need to convert to the correct timezone without changing the date and time when sending to the server
    // and convert to browser TZ on the way back
    // can we do this by overloading the get and set?
    getValue: function() {
        var offset = this.schema.tz_offset;
        var val = this.picker.data("DateTimePicker").getDate(); // date the datetime from the widget
        valStr = val.format('YYYY-MM-DD HH:mm'); // create a string without the timezone
        valStr += offset.toString(); // add in the time offset for the convention i.e. " -0500";
        return valStr; // and that is what we will send to the backend
    },

    setInitialValue: function(value) {
        // fix the display value, i.e. remove the TZ info
        var dispValue = moment(value.substr(0,value.length-6));
        this.picker.data("DateTimePicker").setDate(dispValue); // Fix for initial value ...
    }
}, {
    template: _.template('\
        <div class="bbf-datetime form-group">\
            <div class="input-group date datetimefield">\
                <input type="text" class="form-control" />\
                <span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>\
            </div>\
        </div>\
        ', null, Form.templateSettings),
});

})(Backbone.Form);
