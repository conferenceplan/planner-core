;(function(Form) {

/*
 * HTML field in the form that utlises the CK editor so we have rich text editor.
 */
Form.editors.Html = Form.editors.TextArea.extend({ // Backbone.Form.editors.Base.extend
    render: function() {
        // Add the CK editor as the field
        // TODO - add a mechanism to pass in options for the CK editor toolbar
        this.$el.ckeditor({
            removePlugins : "elementspath,flash",
            toolbar : 'CPlan',
            toolbar_CPlan : [
                { name: 'basicstyles', items : [ 'Bold','Italic','Underline','Strike','Subscript','Superscript','-','RemoveFormat' ] },
                { name: 'paragraph', items : [ 'NumberedList','BulletedList','-','Outdent','Indent','-','Blockquote','CreateDiv','-','JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock','-','BidiLtr','BidiRtl' ] },
                { name: 'links', items : [ 'Link','Unlink','Anchor' ] },
                { name: 'insert', items : [ 'Table','HorizontalRule','SpecialChar' ] }, // 'Image',
                // '/',
                // { name: 'styles', items : [ 'Styles','Format','Font','FontSize' ] },
                // { name: 'colors', items : [ 'TextColor','BGColor' ] },
                { name: 'tools', items : [ 'Maximize', 'ShowBlocks','-','About' ] }
            ]
        });

        return this;
    },
});

})(Backbone.Form);
