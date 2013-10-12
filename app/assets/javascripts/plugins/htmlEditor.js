;(function(Form) {

/*
 * Time input in the form 10:15 etc.
 */
Form.editors.Html = Form.editors.TextArea.extend({ // Backbone.Form.editors.Base.extend
    // TODO - add the logic so that CK Editor is added to the field.
    
    render: function() {

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
    
    remove : function() {

        console.debug("gg");        
        // delete CKEDITOR.instances[this.$el.id];
            // $(el).find('textarea.rte').each(function() {
                // // alert($(this)[0].id);
                // try {
                    // if(CKEDITOR.instances[$(this)[0].id] != null) {
                        // delete CKEDITOR.instances[$(this)[0].id];
                    // }
                // } catch(e){
                // }
            // });
    }
    
});


})(Backbone.Form);
