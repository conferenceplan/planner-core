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
        var self = this;
        var options = this.options,
            schema = this.schema,
            ctl = this;

        var $el = $($.trim(this.template({})));
        
        this.setElement($el);
        
        var element = this.$el;
        var default_date = this.schema.defaultDate;
        this.picker = element.find('.datetimefield').datetimepicker(this.schema.picker);
        var picker = this.picker;
        
        picker.on('dp.show', function(e) {
            if (typeof default_date != 'undefined') {
                element.find('.datetimefield').data("DateTimePicker").defaultDate(moment(default_date));
            };

            if (schema.showFn) {
                schema.showFn.call(self, e);
            }
        }).on("dp.change", function(e) {
            if (schema.changeFn) {
                schema.changeFn.call(self, e);
            }
        });
        this.setInitialValue(this.value);
        
        return this;
    },
    
    lpad : function(orig, padString, length) {
        var str = orig;
        while (str.length < length)
            str = padString + str;
        return str;
    },
    
    // We need to convert to the correct timezone without changing the date and time when sending to the server
    // and convert to browser TZ on the way back
    // can we do this by overloading the get and set?
    getValue: function() {
        var offset = (typeof this.schema.tz_offset != 'undefined') ? this.schema.tz_offset : 0;
        var val = this.picker.data("DateTimePicker").date(); // date the datetime from the widget
        var valStr = "";
        if (val) {
            if (this.schema.date_only) {
                valStr = val.format('YYYY-MM-DD'); // create a string without the timezone
            } else {
                valStr = val.format('YYYY-MM-DD HH:mm'); // create a string without the timezone
                if (offset < 0) {
                    valStr += ' -';
                } else {
                    valStr += ' +';
                }
                var hours = Math.floor(offset / 60);
                var minutes = offset % 60;
                valStr += this.lpad(Math.abs(hours.toString()), "0",2) + this.lpad(Math.abs(minutes).toString(), "0",2); // add in the time offset for the convention i.e. " -0500";
            }
        }
        return valStr; // and that is what we will send to the backend
    },

    setInitialValue: function(value) {
        // fix the display value, i.e. remove the TZ info
        if (value) {
            var dispValue;
            if ((typeof this.schema !== 'undefined') && this.schema.date_only) {
                if (value.length > 10) { // 2015-02-13T00:00:00-05:00
                    dispValue = (value.length > 0) ? moment(value.substr(0,value.length-6)) : '';
                } else {
                    dispValue = moment(value);
                }
            } else {
                dispValue = (value.length > 0) ? moment(value.substr(0,value.length-6)) : '';
            };

            this.picker.data("DateTimePicker").date(dispValue); // Fix for initial value ...
        }
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
