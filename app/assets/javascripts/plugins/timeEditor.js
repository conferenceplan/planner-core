;(function(Form) {

/*
 * Time input in the form 10:15 etc.
 */
Form.editors.Time = Form.editors.Base.extend({

    events: _.extend({}, Form.editors.Text.prototype.events, {
        'keypress': 'onKeyPress',
        'change'  : 'onKeyPress'
    }),

    initialize: function(options) {
        options = options || {};
        
        Form.editors.Base.prototype.initialize.call(this, options);
        
        // this.options = _.extend({
        // }, options);
      
        this.schema = _.extend({
            minsInterval: 15
        }, options.schema || {});
        
        // Check value??
        
        //  
        this.template = options.template || this.constructor.template;
    },
  
    render: function() {
        var options = this.options,
            schema = this.schema;

        // Set the time options - set this to units of 15
        var timeOptions = _.map(_.range(0,60, schema.minsInterval), function(time) {
            return '<option value="'+time+'">' + time + '</option>';
        });
        var hourOptions = _.map(_.range(0,23, 1), function(hour) {
            return '<option value="'+hour+'">' + hour + '</option>';
        });
        
        var $el = $($.trim(this.template({
            hours: hourOptions.join(''),
            times: timeOptions.join(''),
            })));
            
        this.$time = $el.find('[data-type="time"]');
        this.$hour = $el.find('[data-type="hour"]');
        
        this.setValue(this.value);
        
        this.setElement($el);
        this.$el.attr('id', this.id);
        this.$el.attr('name', this.getName());

        if (this.hasFocus) this.trigger('blur', this);
        
        return this;
    },
  
    getValue: function() {
        return this.$hour.val() + ":" + this.$time.val(); // TODO
    },

    setValue: function(value) {
        if (value) {
            times = value.split(':');
        
            this.$hour.val(times[0]); // TODO
            this.$time.val(times[1]); // TODO
        }
    },
    focus: function() {
        if (this.hasFocus) return;

        this.$('select').first().focus();
    },

    blur: function() {
        if (!this.hasFocus) return;

        this.$('select:focus').blur();
    },

    // TODO - do we need this???
    updateHidden: function() {
    },

}, {
    // statics <div class="bbf-date-container" data-date="">
    template: _.template('\
        <div class="bbf-datetime">\
        <select data-type="hour"><%= hours %></select>\
        <select data-type="time"><%= times %></select>\
        </div>\
        ', null, Form.templateSettings),
        
});

})(Backbone.Form);

