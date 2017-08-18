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
        clickToSelect       : false,
        checkbox            : false,
        singleSelect        : true,
        delayed             : false,
        selectNotifyMethod  : function(row, data) { return null; },
        onloadMethod        : function() { return null; },
        deleteNotifyMethod  : function() { return null; },
        extraClause         : null,
        cardView            : false,
        
        showRefresh         : false,
        search              : true,
        pagination          : true,
        pageSize            : 25,
        pageList            : [25, 50, 100, 200, 500, 1000],
        toolbar             : null,
        modelType           : null,
        modelTemplate       : null,
        showControls        : true,
        disableControls     : false,
        filterControl       : false,
        filterShowClear     : false,
        controlDiv          : 'item-control-area', // Use this if using control and multiple grids on one page
        rowStyle            : function(row, idx) {
                                            return {
                                                    classes: 'item'
                                                };
                                        },
        modal_create_title  : "Create",
        modal_edit_title    : "Edit",
        confirm_content     : "Are you sure you want to delete the selected data?",
        confirm_title       : "Confirm Deletion",
        translations        : {},
        extra_options       : {},
        modalType           : ModelModal,
        filterShowClear     : false,
        detailView          : false,
        detailFormatter     : function(index, row) { return ""; },
        showHeader          : true,
        showFooter          : false,
        striped             : true,
        onExpandRow         : function(index, row, detail) {},
        onCollapseRow       : function(index, row) {},
        sortOrder           : 'asc',
        sortName            : 'id',
        ctl_template        : '#table-control-template',
        extra_button        : false,
        extra_button_title  : "extra",
        extra_modal_action  : function() {},
    },

    /*
     *
     */
    translate : function(str) {
        return this.options.translations[str] ? this.options.translations[str] : str;
    },
    
    /*
     * 
     */
    extra_option : function(str) {
        return this.options.extra_options[str] ? this.options.extra_options[str] : '';
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

    _destroy : function() {
        this.element.bootstrapTable('destroy');
    },

    getData : function() {
        return this.element.bootstrapTable('getData');
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

    removeAll : function() {
        this.element.bootstrapTable('removeAll');
    },

    pageFrom : function() {
        this.element.bootstrapTable('pageFrom');
    },

    getSelected : function() {
        return this.selected;
    },

    getModel : function() {
        return this.model;
    },

    /*
     *
     */
    root_url : function() {
        return this.options.root_url;
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
        this.options.id = options.id;
        this.options.id_name = options.id_name;
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
    unSelect : function() {
        this.model = null;
        this.selected = null;
        this.selected_element = null;
    },

    /*
     *
     */
    newModel : function(callback) {
        var modelTemplate = this.options.modelTemplate;
        var selectMethod = this.options.selectNotifyMethod;
        var that = this;

        var mdl = new this.options.modelType({});
        if (this.options.id) {
            mdl.set(this.options.id_name, this.options.id);
        }

        // iterate though extra_model_params
        _.each(this.options.extra_model_params, function(val,key) {
            mdl.set(key, val);
        });

        var grid = this.element.bootstrapTable(); //this.options.grid;

        var modal = new this.options.modalType({
            model : mdl,
            modal_template : modelTemplate,
            title : this.options.modal_create_title,
            refresh : function(mdl) {
                var opts = grid.bootstrapTable('getOptions');
                if (typeof opts.sortName !== 'undefined') {
                    var params = {
                        search: opts.searchText,
                        sort:   opts.sortName ? opts.sortName : 'name',
                        order:  opts.sortOrder,
                        limit : opts.pageSize
                    };
                    jQuery.ajax( opts.url + '/find_page/' + mdl.get(opts.sortName),{
                             data : params,
                             error : function(response) {
                                that.selected_element = mdl.id;
                                grid.bootstrapTable('refresh');
                                selectMethod(mdl.id);
                             },
                             success : function(data, status, xhr) {
                                grid.bootstrapTable('selectPage', data);
                                that.selected_element = mdl.id;
                                grid.bootstrapTable('refresh');
                                selectMethod(mdl.id);
                             }
                         });
                } else {
                    that.selected_element = mdl.id;
                    grid.bootstrapTable('refresh');
                    selectMethod(mdl.id);
                }

                if (callback) {
                    callback();
                }
            }
        });
        modal.render();
    },

    /*
     *
     */
    editModel : function() {
        var modelTemplate = this.options.modelTemplate;
        var grid = this.element.bootstrapTable(); //this.options.grid;
        var that = this;
        var selectMethod = this.options.selectNotifyMethod;

        if (this.model) {
            // Put up a modal dialog to edit the reg details
            // This is done via the select method
            modal = new ModelModal({
                model : this.model,
                modal_template : modelTemplate,
                title : this.options.modal_edit_title,
                refresh : function(mdl) {
                    grid.bootstrapTable('refresh');
                    that.model = selectMethod(mdl.id);
                }
            });
            modal.render();
        };
    },

    /*
     *
     */
    deleteModel : function() {
        if (this.model) {
            var model = this.model;
            var grid = this.element.bootstrapTable(); //this.options.grid;
            var confirm_content = this.options.confirm_content;
            var that = this;
            var deleteNotifyMethod = this.options.deleteNotifyMethod;
            // confirmation for the model delete
            modal = new AppUtils.ConfirmModel({
                    content : confirm_content,
                    title : this.options.confirm_title,
                    continueAction : function() {
                        model.destroy({
                            wait: true,
                            success : function(md, response) {
                                that.model = null;
                                that.selected = null;
                                that.selected_element = null;
                                grid.bootstrapTable('refresh');
                                deleteNotifyMethod();
                            },
                            customError : function(response) {
                              AppUtils.setMessage({
                                text : response.responseText,
                                style : 'error',
                                renderLocation : ($('.modal').length > 0 ? 'modal' : 'main-layout'),
                                fade : true,
                                fadeTimeout : 10000
                              });
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

    /*
     *
     */
    createTable : function() {
        var selectMethod = this.options.selectNotifyMethod;
        var onloadMethod = this.options.onloadMethod;
        var modelType = this.options.modelType;
        var modelTemplate = this.options.modelTemplate;
        var that = this;
        var el = this.element;

        TableControlView = Backbone.Marionette.ItemView.extend({
            events : {
                "click .add-model-button"       : "newModel",
                "click .edit-model-button"      : "editModel",
                "click .delete-model-button"    : "deleteModal",
                "click .extra-action-model-button"  : "extraAction"
            },

            templateHelpers: function(){
              return {
                display: that.options.extra_button,
                label: that.options.extra_button_title
              }
            },

            initialize : function(options) {
              this.options = options || {};
              var ctl_template = '#table-control-template'
              this.template = _.template($(ctl_template).html());
            },

            extraAction : function() {
                that.options.extra_modal_action();
            },

            newModel : function(e) {
                e.stopPropagation();
                e.preventDefault();

                that.newModel(function() {
                    // that.model = null;
                    // that.selected = null;
                    // that.selected_element = null;
                });
            },

            editModel : function(e) {
                e.stopPropagation();
                e.preventDefault();
                that.editModel();
            },

            deleteModal : function(e) {
                e.stopPropagation();
                e.preventDefault();
                that.deleteModel();
            },
        });

        var grid = this.element.bootstrapTable({
                url: this.createUrl(),
                onClickRow : function(row, element) {
                        $(element).parent().find('tr').removeClass('success');
                        $(element).addClass('success');
                        that.selected = row;
                        that.selected_element = element.attr('data-item-id');
                        that.model = selectMethod(row.id, row); // NOTE - we may want to change to pass the whole row
                    },
                onPageChange : function(number, size) {
                    that.selected = null;
                    that.selected_element = null;
                    that.model = null;
                    return false;
                },
                onLoadSuccess : function(data) {
                    if (that.selected_element) {
                        var selector = "[data-item-id='" + that.selected_element + "']";
                        jQuery(el).find(selector).addClass('success');
                        
                    };
                    onloadMethod();
                    jQuery(el).find("[data-toggle='tooltip']").tooltip();
                    jQuery(el).find("[data-toggle='popover']").popover();
                },
                method: 'get',
                cache: false,
                clickToSelect   :  this.options.clickToSelect,
                checkbox :  this.options.checkbox,
                singleSelect:  this.options.singleSelect,
                striped: this.options.striped,
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
                filterControl       : this.options.filterControl,
                filterShowClear     : this.options.filterShowClear,
                rowAttributes       : function(row, idx) {
                                            return {
                                                'data-item-id' : row.id,
                                                'data-item-base' : (this.pageNumber -1) * this.pageSize
                                            };
                                        },
                filterShowClear     : this.options.filterShowClear,
                rowStyle            : this.options.rowStyle,
                detailView          : this.options.detailView,
                detailFormatter     : this.options.detailFormatter,
                showHeader          : this.options.showHeader,
                showFooter          : this.options.showFooter,
                onExpandRow         : this.options.onExpandRow,
                onCollapseRow       : this.options.onCollapseRow,
                sortOrder           : this.options.sortOrder,
                sortName            : this.options.sortName,
                uniqueId            : this.options.uniqueId,
                onCheck             : this.options.onCheck,
                onUncheck           : this.options.onUncheck,
                // ctl_template        : this.options.ctl_template
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
                    modalType           : this.options.modalType,
                    view_callback       : this.options.callback,
                    ctl_template        : this.options.ctl_template,
                    disableControls     : this.options.disableControls
            });
            control.render();
            $("#" + this.options.controlDiv).html(control.el);

            if (this.options.disableControls) {
                control.$(':button').prop('disabled', true);
            }
        };

    }
});

})(jQuery);
