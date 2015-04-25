/*
 * Base table widget ...
 * 
 */
(function($) {
    
$.widget( "cp.baseTable" , {
    /*
     * 
     */
    options : {
        pager               : '#pager',
        root_url            : "/",              // so that sub-domains can be taken care of
        baseUrl             : "",               // HAS TO BE OVER-RIDDEN by the sub-component
        getGridData         : "",               // for getting the data (part of the URL)
        caption             : "My Table",
        selectNotifyMethod  : function(ids) {},
        clearNotifyMethod   : function() {},
        loadNotifyMethod    : function() {},
        multiselect         : false,
        extraClause         : null,
        sortname            : null,
        filtertoolbar       : true,
        showControls        : true,
        controlDiv          : 'item-control-area', // Use this if using control and multiple grids on one page
        modelType           : null, // Should be provided by the caller
        modelTemplate       : null,
        delayed             : false,
        confirm_content     : "Are you sure you want to delete the selected data?",
        confirm_title       : "Confirm Deletion",
        translations        : {}
    },

    translate : function(str) {
        return this.options.translations[str] ? this.options.translations[str] : str;
    },
    
    /*
     *
     */
    _create : function() {
        if (!this.options.delayed) {
            this.createTable();
            var width = this.element.parents('.ui-jqgrid').css("width");
            width = (parseInt(width) + 2) + "px";
            this.element.parents('.ui-jqgrid').css("width", width);
            this.handleResize();
        }
    },
    
    render : function() {
        if (this.options.delayed) {
            this.createTable();
            var width = this.element.parents('.ui-jqgrid').css("width");
            width = (parseInt(width) + 2) + "px";
            this.element.parents('.ui-jqgrid').css("width", width);
            this.options.delayed = false; // because it has now been rendered
            this.handleResize();
        }
    },
    
    resize_grid : function() {
        var grid = this.element;
        var width = grid.parents('.ui-jqgrid').parent().width();
        grid.setGridWidth(width);
        grid.parents('.ui-jqgrid').css("width", width+2);
    },
    
    handleResize : function() {
        var grid = this.element;
        jQuery(window).bind('resize', function() {
            var width = grid.parents('.ui-jqgrid').parent().width();
            grid.setGridWidth(width);
            grid.parents('.ui-jqgrid').css("width", width+2);
        }).trigger('resize');
    },
    
    /*
     * 
     */
    createTable : function() {
        var selectMethod = this.options.selectNotifyMethod;
        var loadNotifyMethod = this.options.loadNotifyMethod;
        var pageToMethod = this.pageTo;
        var clearNotifyMethod = this.options.clearNotifyMethod;
        var base_url = this.options.root_url + this.options.baseUrl;
        var modelType = this.options.modelType;
        var modelTemplate = this.options.modelTemplate;
        var control = null;
        var pageTo = this.pageTo;
        
        // View type for controls
        TableControlView = Backbone.Marionette.ItemView.extend({

            events : {
                "click .add-model-button"       : "newModel",
                "click .edit-model-button"      : "editModel",
                "click .delete-model-button"    : "deleteModal",
            },
        
            initialize : function(options) {
                this.options = options || {};
                // this.template = _.template(this.templateStr);
                this.template = _.template($('#table-control-template').html()); //_.template(_model_html); //
            },
            
            refreshGrid : function(grid, mdl) {
                if (mdl) {
                    var page_to = pageTo(mdl);
                    var to_id = mdl.id;
                    mdl.clear();
                    grid.jqGrid('setGridParam', {
                        postData : {
                            page_to : page_to, // make sure that the current page contains the selected element
                            filters : {},
                            current_selection : to_id // to pass back for the selection
                        },
                    });
                }
                grid.trigger("reloadGrid");
            },
            
            newModel : function() {
                var mdl = new this.options.modelType({});
                if (this.options.id) {
                    mdl.set(this.options.id_name, this.options.id);
                }
            
                // var refreshEvent = this.options.view_refresh_event;
                // var callback = this.options.view_callback;
                var grid = this.options.grid;
                var refreshGridFn = this.refreshGrid;

                var modal = new ModelModal({
                    model : mdl,
                    modal_template : modelTemplate,
                    title : this.options.modal_create_title,
                    refresh : function(mdl) {
                        // if (refreshEvent) {
                            // eventAggregator.trigger(refreshEvent); 
                        // }
                        // ------------------
                        // Refresh the grid - goto the page with the new item and make that the current selection
                        // ------------------
                        refreshGridFn(grid, mdl);
                    }
                });
                modal.render();
            },
        
            editModel : function() {
                if (this.model) {
                    var grid = this.options.grid;
                    var refreshGridFn = this.refreshGrid;
                    // Put up a modal dialog to edit the reg details
                    // This is done via the select method
                    modal = new ModelModal({
                        model : this.model, 
                        modal_template : modelTemplate,
                        title : this.options.modal_edit_title,
                        refresh : function(mdl) {
                            grid.jqGrid('setGridParam', {
                            loadComplete: function(data) {
                                    grid.jqGrid('setSelection', mdl.id); // when load is complete the selection is called...
                                    // load complete is called every time... only want it once, so remove it after it has been used...
                                    grid.jqGrid('setGridParam', { loadComplete: function() {} });
                                }
                            });
                            grid.trigger("reloadGrid");
                        }
                    });
                    modal.render();
                };
            },
        
            deleteModal : function() {
                if (this.model) {
                    var model = this.model;
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
                                        // TODO - we need a method to call to ensure that selected is nilled out before the grid reload etc
                                        grid.jqGrid('setGridParam', {
                                        loadComplete: function(data) {
                                                grid.jqGrid('resetSelection');
                                                grid.jqGrid('setGridParam', { loadComplete: function() {} });
                                            }
                                        });
                                        grid.trigger("reloadGrid");
                                        clearNotifyMethod();
                                    }
                                });
                                model = null;
                            },
                            closeAction : function() {
                            }
                    });
                    modal.render();
                };
            },
        });

        // create the grid that is associated with the element
        var grid = this.element.jqGrid({
                url             : this.createUrl(),
                datatype        : 'JSON',
                jsonReader      : {
                        repeatitems : false,
                        page        : "currpage",
                        records     : "totalrecords",
                        root        : "rowdata",
                        total       : "totalpages",
                        id          : "id",
                },
                mtype           : 'POST',
                postData        : {'namesearch' : 'true'},
                colModel        : this.createColModel(),
                multiselect     : this.options.multiselect,
                pager           : jQuery(this.options.pager),
                rowNum          : 10,
                autowidth       : true,
                shrinkToFit     : true,
                height          : "100%",
                rowList         : [10, 20, 30, 60],
                sortname        : this.options.sortname,
                sortorder       : "asc",
                viewrecords     : true,
                imgpath         : 'stylesheets/custom-theme/images', // Check if this is needed
                caption         : this.options.caption,
                editurl         : this.editUrl(),
                onSelectRow     : function(ids) {
                    var _model = selectMethod(ids); // get the current model and put it in the controller view
                    
                    if (_model) {
                        control.model = _model;
                    }
                    
                    return false;
                },
                loadComplete    : function(data) {
                    // $("option[value=100000000]").text('All');
                    if (data.currentSelection) {
                        grid.setSelection(data.currentSelection);
                    };
                    grid.setGridParam({
                         postData : {page_to : null, current_selection : null},
                    });
                },
                gridComplete    : function() {
                    // Call back - to call when the load has been done
                    loadNotifyMethod();
                }
        });

        /*
         * 
         */
        this.element.navGrid(this.options.pager, {
                view    : false, //this.options.view,
                search  : false, //this.options.search,
                del     : false, //this.options.del,
                edit    : false, //this.options.edit,
                add     : false, //this.options.add,
                refresh : false, //this.options.refresh,
        });
            
        /*
         * 
         */
        if (this.options.filtertoolbar) {
            this.element.jqGrid('filterToolbar', {
                stringResult    : true,
                searchOnEnter   : false,
            });
        };
        
        /*
         * Put in the mechanism to add and remove elements using the Marionnette modals instead
         */
        this.element.navGrid(this.options.pager).navButtonAdd(
                this.options.pager,{
                    caption         : "<div id='" + this.options.controlDiv + "'></div>", // this should be passed into the widget
                    buttonicon      : "hidden", 
                    onClickButton   : null,
                    position        : "last",
                    title           : null,
                    cursor          : "pointer"
        });
        
        if (this.options.showControls) {
            // Create the control view
            this.control = control = new TableControlView({
                    id                  : this.options.id,
                    id_name             : this.options.id_name,
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
        }
    },
    
    setControlOptions : function(options) {
        this.control.options.id = options.id;
        this.control.options.id_name = options.id_name;
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
    tagQuery : function(options) {
        this.options.extraClause = options.tagQuery;
        
        if (!this.options.delayed) {
            var newUrl = this.createUrl();
            
            if (newUrl.indexOf("?") != -1) {
                newUrl += "&";
            } else {
                newUrl += "?";
            };
            newUrl += options.tagQuery;
                
            this.element.jqGrid('setGridParam', {
                url: newUrl,
                contentType : 'application/x-www-form-urlencoded; charset=UTF-8'
            }).trigger("reloadGrid");
        }
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
        }
        url += urlArgs;
        return url;
    },

    /*
     * 
     */
    editUrl : function () {
        return "";
    },
    
    /*
     * 
     */
    createColModel : function() {
    },
    
    /*
     * 
     */
    pageTo : function (data) {
        return "";
    }
});

})(jQuery);
