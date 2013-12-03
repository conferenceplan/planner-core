;(function(Form) {

/*
 * Turn a text field into a color editor with a color picker.
 */
Form.editors.Color = Form.editors.Text.extend({

//<input id="c4_title_background" type="text" name="title_background" style="background-color: rgb(82, 92, 35); opacity: 1;">
    
    render: function() {
        this.setValue(this.value);
        var element = this.$el;
        var id = element[0].id;
        
        var cp = element.colorpicker({
            okOnEnter: true,
            alpha : true,
            colorFormat: 'RGBA',
            altField: "#" + id,
            altProperties: 'background-color',
            altAlpha: true,
            select: function(event, color) {
                element.trigger('blur', element);
            }
        }); 

        // var myColor = new jscolor.color(element[0], {
            // hash                : true,
            // onImmediateChange   : function(color) {
            // }
        // });

        return this;
    },
});

})(Backbone.Form);
