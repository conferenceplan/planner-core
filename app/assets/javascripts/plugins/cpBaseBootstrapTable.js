/*
 * Base table widget ...
 * 
 */
(function($) {
    
$.widget( "cp.baseBootstrapTable" , {
    /*
     * 
     */
    options : {
        root_url            : "/",              // so that sub-domains can be taken care of
        baseUrl             : "",               // HAS TO BE OVER-RIDDEN by the sub-component
        getGridData         : "",               // for getting the data (part of the URL)
        delayed             : false,
        selectNotifyMethod  : function(row, data) { return null; },
        extraClause         : null,
        cardView            : false,
        showRefresh         : false,
        search              : true,
        pagination          : true,
        pageSize            : 10,
        pageList            : [10, 25, 50, 100, 200],
        toolbar             : null,
        modelType           : null,
        modelTemplate       : null,
        showControls        : true,
        controlDiv          : 'item-control-area', // Use this if using control and multiple grids on one page
        rowStyle            : function(row, idx) {
                                            return {
                                                    classes: 'item'
                                                };
                                        },
        modal_create_title  : "Create",
        modal_edit_title    : "Edit",
        confirm_content     : "Are you sure you want to delete the selected data?",
        confirm_title       : "Confirm Deletion"
        // data-item-id=<%= "#{thing.id}"

        // pager               : '#pager',
        // clearNotifyMethod   : function() {},
        // loadNotifyMethod    : function() {},
        // multiselect         : false,
        // sortname            : null,
        // filtertoolbar       : true,
    },
    
    /*
     *
     */
    _create : function() {
        if (!this.options.delayed) {
            this.selected = this.model = null;
            this.createTable();
        }
    },
    
    render : function() {
        if (this.options.delayed) {
            this.selected = this.model = null;
            this.createTable();
            this.options.delayed = false; // because it has now been rendered
        } else {
            this.reset();
        }
    },

    reset : function() {
        var newUrl = this.createUrl();
        this.element.bootstrapTable('refresh', { url : newUrl});
    },

    refresh : function() {
        var newUrl = this.createUrl();
        this.element.bootstrapTable('refresh');//, { url : newUrl});
    },
    
    pageFrom : function() {
        this.element.bootstrapTable('pageFrom');
    },
    
    pageFrom : function() {
        this.element.bootstrapTable('pageFrom');
    },
    
    getSelected : function() {
        return this.selected;
    },

    /*
     * 
     */    
    _url : function() {
        // Determine what the URL for the table should be
        return this.options.root_url + this.options.baseUrl + this.options.getGridData;
    },
    
    /*
     * 
     */
    createUrl : function () {
        var url = this.options.root_url + this.options.baseUrl + this.options.getGridData;
        var urlArgs = "";
        if (this.options.extraClause) {
            urlArgs += '?';
            urlArgs += this.options.extraClause; 
        };
        url += urlArgs;
        return url;
    },
    
    /*
     * 
     */
    createColModel : function() {},

    /*
     * 
     */
    setControlOptions : function(options) {
        this.control.options.id = options.id;
        this.control.options.id_name = options.id_name;
    },
    
    /*
     * 
     */
    setExtraModelParams : function(arg) {
        this.options.extra_model_params = arg;
        if (this.control) {
            this.control.options.extra_model_params = arg;   
        };
    },
    
    /*
     * 
     */
    createTable : function() {
        var selectMethod = this.options.selectNotifyMethod;
        var modelType = this.options.modelType;
        var modelTemplate = this.options.modelTemplate;
        var that = this;
        var el = this.element;

        TableControlView = Backbone.Marionette.ItemView.extend({

            events : {
                "click .add-model-button"       : "newModel",
                "click .edit-model-button"      : "editModel",
                "click .delete-model-button"    : "deleteModal",
            },
        
            initialize : function(options) {
                this.options = options || {};
                this.template = _.template($('#table-control-template').html());
            },
            
            // TODO - we need a way to go to the page that the new item is on...
            // refreshGrid : function(grid, mdl) {
                // if (mdl) {
                    // // var page_to = pageTo(mdl);
                    // // var to_id = mdl.id;
                    // // mdl.clear();
                // }
            // },
            
            newModel : function() {
                var mdl = new this.options.modelType({});
                if (this.options.id) {
                    mdl.set(this.options.id_name, this.options.id);
                }
                
                // iterate though extra_model_params
                _.each(this.options.extra_model_params, function(val,key) {
                    mdl.set(key, val);
                });
            
                var grid = this.options.grid;

                var modal = new ModelModal({
                    model : mdl,
                    modal_template : modelTemplate,
                    title : this.options.modal_create_title,
                    refresh : function(mdl) {
                        grid.bootstrapTable('refresh');
                        that.model = null;
                        that.selected = null;
                        that.selected_element = null;
                    }
                });
                modal.render();
            },
        
            editModel : function() {
                var grid = this.options.grid;
                if (that.model) {
                    // Put up a modal dialog to edit the reg details
                    // This is done via the select method
                    modal = new ModelModal({
                        model : that.model, 
                        modal_template : modelTemplate,
                        title : this.options.modal_edit_title,
                        refresh : function(mdl) {
                            grid.bootstrapTable('refresh');
                        }
                    });
                    modal.render();
                };
            },
        
            deleteModal : function() {
                if (that.model) {
                    var model = that.model;
                    var grid = this.options.grid;
                    var confirm_content = this.options.confirm_content;
                    // confirmation for the model delete
                    modal = new AppUtils.ConfirmModel({
                            content : confirm_content,
                            title : this.options.confirm_title,
                            continueAction : function() {
                                model.destroy({
                                    wait: true,
                                    success : function(md, response) {
                                        that.selected = null;
                                        that.selected_element = null;
                                        grid.bootstrapTable('refresh');
                                    }
                                });
                                that.model = null;
                            },
                            closeAction : function() {
                            }
                    });
                    modal.render();
                };
            },
        });

        var grid = this.element.bootstrapTable({
                url: this.createUrl(),
                onClickRow : function(row, element) {
                        $(element).parent().find('tr').removeClass('success');
                        $(element).addClass('success');
                        that.selected = row;
                        that.selected_element = element.attr('data-index');
                        that.model = selectMethod(row.id, row); // NOTE - we may want to change to pass the whole row
                    },
                // onAll : function(name, args) {
                    // console.debug(name);
                    // return false;
                // },
                onPageChange : function(number, size) {
                    // console.debug("page change");
                    that.selected = null;
                    that.selected_element = null;
                    that.model = null;
                    return false;
                },
                onLoadSuccess : function(data) {
                    if (that.selected) {
                        if (that.selected_element) {
                            var selector = "[data-index='" + that.selected_element + "']";
                            jQuery(el).find(selector).addClass('success');
                        };
                    };
                },
                method: 'get',
                cache: false,
                striped: true,
                sidePagination: 'server',
                pagination: this.options.pagination,
                pageSize: this.options.pageSize,
                pageList: this.options.pageList,
                search: this.options.search,
                showRefresh: this.options.showRefresh,
                cardView: this.options.cardView,
                columns: this.createColModel(),
                searchAlign: 'right',
                // maintainSelected : true,
                toolbar: this.options.toolbar,
                rowAttributes       : function(row, idx) {
                                            return {
                                                'data-item-id' : row.id,
                                                'data-item-base' : (this.pageNumber -1) * this.pageSize
                                            };
                                        },
                rowStyle            : this.options.rowStyle
        });

        if (this.options.showControls) {
            // Create the control view
            this.control = control = new TableControlView({
                    id                  : this.options.id,
                    id_name             : this.options.id_name,
                    extra_model_params  : this.options.extra_model_params,
                    grid                : this.element,
                    modal_create_title  : this.options.modal_create_title,
                    modal_edit_title    : this.options.modal_edit_title,
                    confirm_content     : this.options.confirm_content,
                    confirm_title       : this.options.confirm_title,
                    modelType           : modelType,
                    view_callback       : this.options.callback
            });
            control.render();
            $("#" + this.options.controlDiv).html(control.el);
        };

    }
});

})(jQuery);
