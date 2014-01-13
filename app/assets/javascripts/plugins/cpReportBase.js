/*
 * 
 */
var ReportBase = (function(Backbone){

    return {
        ResultSet : Backbone.RelationalModel.extend({
            relations : [{
                type : Backbone.HasMany,
                key : 'rowdata',
                relatedModel : 'ResultRow',
                collectionType : 'ResultRowCollection',
            }],
        }),
        
        ResultsView : Backbone.View.extend({
            initialize : function() {
                this.template = _.template($('#query-results-template').html());
            },
            
            render : function() {
                this.$el.html($(this.template()));
                $('#report-results-area').html(this.$el);
                
                this.grid = $('.result-table').jqGrid({
                    colModel : this.options.colModel,
                    cmTemplate: {sortable:false, cellattr: function (rowId, tv, rawObject, cm, rdata) { return 'style="white-space: pre-wrap;"'; }},
                    datatype: 'jsonstring',
                    datastr: this.options.resultsCollection.toJSON(),
                    jsonReader :{
                        repeatitems : false,
                        page: "currpage",
                        records: "totalrecords",
                        root : "rowdata",
                        total: "totalpages",
                        id : "id",
                    },
                    viewrecords: true,
                    height: "auto",
                    autowidth: true,
                    ignoreCase: true,
                    gridview: true,
                    pager : '#result-pager',
                    caption: this.options.caption,
                    rowList:[10,20,50,100],
                    rowNum:50
                    });
    
                var grid = this.grid;
                jQuery(window).bind('resize', function() {
                    var width = grid.parents('.ui-jqgrid').parent().width();
                    grid.setGridWidth(width);
                    grid.parents('.ui-jqgrid').css("width", width+2);
                }).trigger('resize');
                
                return this;
            }
    
        }),
        
        reportRegion : new Backbone.Marionette.Region({
            el: "#report-form-area"
        }),
        
        resultRegion : new Backbone.Marionette.Region({
            el: "#report-results-area"
        }),
    
        ReportView : Marionette.ItemView.extend({
            events: {
                "click .report-submit-button" : "submit",
                "click .report-csv-button" : "submitCSV"
            },
            
            initialize : function() {
                this.template = _.template($('#report-template').html());
            },
            
            render : function() {
                this.$el.html($(this.template()));
                
                this.form = new this.options.form({}).render();
                
                this.$el.find(".report-body").html(this.form.el);
            },
            
            submitCSV : function() {
                var data = this.form.getValue();
                
                $.download(this.options.endPoint + '.csv', data );
            },
            
            // TODO - we want XML and CSV exports as well
            submit : function() {
                // Gather the data from the form and send it to the back end
                var data = this.form.getValue();
                var colModel = this.options.colModel;
                var caption = this.options.caption;
    
                var resultSet = new ReportBase.ResultSet();
                resultSet.fetch({
                    url : this.options.endPoint + '.json',
                    type : 'POST',
                    data : data,
                    error : function(model, response) {
                      alertMessage("ERROR: unable to get the result from the server");
                    },
                    success : function(model) {
                            resultsView = new ReportBase.ResultsView({
                                        colModel : colModel,
                                        resultsCollection : model,
                                        caption : caption
                            });
                            resultsView.render();
                    }
                });
            }
        })
    
    };
        
}(Backbone));

