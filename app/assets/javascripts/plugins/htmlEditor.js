;(function(Form) {

/*
 * HTML field in the form that utlises the CK editor so we have rich text editor.
 */
Form.editors.Html = Form.editors.TextArea.extend({ // Backbone.Form.editors.Base.extend
    
    createCkWidget : function() {
        // Add the CK editor as the field
        // TODO - add a mechanism to pass in options for the CK editor toolbar
        this.$el.ckeditor({
            // Prevent the translation of html elements (< and >) to encodings, so we can include "macros"
            entities : false,
            basicEntities : false,
            entities_latin : false,
            entities_additional : '',
            htmlEncodeOutput : false,
            removePlugins : "elementspath,flash",
            toolbar : 'CPlan',
            toolbar_CPlan : [
                { name: 'document', items : [ 'Source' ] },
                { name: 'basicstyles', items : [ 'Bold','Italic','Underline','Strike','Subscript','Superscript','-','RemoveFormat' ] },
                { name: 'paragraph', items : [ 'NumberedList','BulletedList','-','Outdent','Indent','-','Blockquote','CreateDiv','-','JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock','-','BidiLtr','BidiRtl' ] },
                { name: 'links', items : [ 'Link','Unlink','Anchor' ] },
                { name: 'insert', items : [ 'HorizontalRule', 'SpecialChar' ] }, // 'Image', 'Table',
                // '/',
                // { name: 'styles', items : [ 'Styles','Format','Font','FontSize' ] },
                // { name: 'colors', items : [ 'TextColor','BGColor' ] },
                { name: 'tools', items : [ 'Maximize', 'ShowBlocks','-','About' ] }
            ]
        });
    },
    
    render: function() {
        
        this.createCkWidget();
        
        this.setValue(this.value);

        return this;
    },
});

})(Backbone.Form);
