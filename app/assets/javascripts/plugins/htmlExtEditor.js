;(function(Form) {

/*
 * HTML field in the form that utlises the CK editor so we have rich text editor.
 */
Form.editors.HtmlExt = Form.editors.TextArea.extend({ // Backbone.Form.editors.Base.extend

    initialize: function(options) {
        this.options = options || {};
        Form.editors.TextArea.prototype.initialize.call(this, options);
    },
    
    createCkWidget : function() {
        // Add the CK editor as the field
        // /gallery_images/<type>/<gallery>
        var imagetype = this.options.schema.imagetype;
        var gallery = this.options.schema.gallery;
        this.$el.ckeditor({
            filebrowserUploadUrl : '/gallery_images/' + imagetype + '/' + gallery, // This is the URL for uploading images ...
            filebrowserBrowseUrl : '/gallery_images/' + imagetype + '/' + gallery, // The URL for browsing images
            // Prevent the translation of html elements (< and >) to encodings, so we can include "macros"
            entities : false,
            basicEntities : false,
            entities_latin : false,
            entities_additional : '',
            htmlEncodeOutput : false,
            allowedContent : {
                $1: {
                        // Use the ability to specify elements as an object.
                        elements: CKEDITOR.dtd,
                        attributes: true,
                        styles: true,
                        classes: true
                    }
                },
            disallowedContent : 'script; *[on*]',
            removePlugins : "elementspath,flash",
            height : '40em',
            enterMode : CKEDITOR.ENTER_P,
            shiftEnterMode: CKEDITOR.ENTER_BR,
            toolbar : 'CPlan',
            toolbar_CPlan : [
                { name: 'document', items : [ 'Source' ] },
                { name: 'basicstyles', items : [ 'Bold','Italic','Underline','Strike','Subscript','Superscript','-','RemoveFormat' ] },
                { name: 'paragraph', items : [ 'NumberedList','BulletedList','-','Blockquote','Outdent','Indent','CreateDiv','-','JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock',,'-','BidiLtr','BidiRtl' ] }, //
                { name: 'links', items : [ 'Link','Unlink','Anchor' ] },
                { name: 'insert', items : [ 'HorizontalRule', 'SpecialChar', 'Image', 'Table'  ]},
                // '/',
                { name: 'styles', items : [ 'Styles','Format','Font','FontSize' ] },
                { name: 'colors', items : [ 'TextColor','BGColor' ] },
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
