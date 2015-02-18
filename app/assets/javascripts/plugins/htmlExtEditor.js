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
        var baseUri = this.options.schema.baseUri ? this.options.schema.baseUri : '';
        this.$el.ckeditor({
            filebrowserUploadUrl : baseUri + '/gallery_images/' + imagetype + '/' + gallery, // This is the URL for uploading images ...
            filebrowserBrowseUrl : baseUri + '/gallery_images/' + imagetype + '/' + gallery, // The URL for browsing images
            // Prevent the translation of html elements (< and >) to encodings, so we can include "macros"
            entities : false,
            basicEntities : false,
            entities_latin : false,
            entities_additional : '',
            htmlEncodeOutput : false,
            allowedContent : true,
            extraAllowedContent : 'style[id]',
            disallowedContent : 'script; *[on*]',
            removePlugins : "elementspath,flash",
            height : '40em',
            enterMode : CKEDITOR.ENTER_P,
            extraPlugins: 'templates,htmlbuttons',
            template_files: '/assets/ckeditor/plugins/templates/templates/default.js',
            contentsCss : '/assets/grenadine/ckeditor-edit.css',
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
                { name: 'tools', items : [ 'Maximize', 'ShowBlocks','-','About' ] },
                { name: 'grenadine-templates', items : ['Templates' ] },
                { name: 'htmlbuttons', items : [
                            {
                                name:'insert-grenadine-custom-fields'
                            }
                        ] }
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
