/*
 * 
 */
var ReportBase = (function(Backbone){


        var ReportViewBase = Marionette.ItemView.extend({
            events: {
                "click .report-submit-button" : "submit",
                "click .report-csv-button" : "submitCSV",
                "click .report-xml-button" : "submitXML",
                "click .report-pdf-button" : "submitPDF",
                "click .report-xlsx-button" : "submitXLSX"
            },
            
            render : function() {
                this.$el.html($(this.template()));
                
                if (this.options.formTemplate) {
                    this.form = new this.options.form({
                        template : _.template($(this.options.formTemplate).html())
                    }).render();
                } else {
                    this.form = new this.options.form({}).render();
                }
                
                this.$el.find(".report-body").html(this.form.el);
            },
            
            submitCSV : function() {
                var errors = this.form.validate(); // To save the values from the form back into the model
                
                if (!errors) { // save if there are no errors
                    var data = this.form.getValue();
                    
                    $.download(this.options.endPoint + '.csv', data );
                }
                
                return errors; // if there are any errors
            },
            
            submitXML : function() {
                var errors = this.form.validate(); // To save the values from the form back into the model
                
                if (!errors) { // save if there are no errors
                    var data = this.form.getValue();
                    
                    $.download(this.options.endPoint + '.xml', data );
                }
                
                return errors; // if there are any errors
            },
            
            submitXLSX : function() {
                var errors = this.form.validate(); // To save the values from the form back into the model
                
                if (!errors) { // save if there are no errors
                    var data = this.form.getValue();
                    
                    $.download(this.options.endPoint + '.xlsx', data );
                }
                
                return errors; // if there are any errors
            },
            
            submitPDF : function() {
                
                var errors = this.form.validate(); // To save the values from the form back into the model
                
                if (!errors) { // save if there are no errors
                    var data = this.form.getValue();
                    
                    $.download(this.options.endPoint + '.pdf', data );
                }
                
                return errors; // if there are any errors
                
            },
            
            submit : function() {
                var errors = this.form.validate(); // To save the values from the form back into the model
                
                if (!errors) { // save if there are no errors
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
                
                return errors; // if there are any errors
            }
        });

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
                
                if (this.options.colModel) {
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
                        rowList:[10,20,50,100000000],
                        rowNum:20,
                        loadComplete: function() {
                                $("option[value=100000000]").text('All');
                            }
                        });
        
                    var grid = this.grid;
                    jQuery(window).bind('resize', function() {
                        var width = grid.parents('.ui-jqgrid').parent().width();
                        grid.setGridWidth(width);
                        grid.parents('.ui-jqgrid').css("width", width+2);
                    }).trigger('resize');
                };
                
                return this;
            }
    
        }),
        
        reportRegion : new Backbone.Marionette.Region({
            el: "#report-form-area"
        }),
        
        resultRegion : new Backbone.Marionette.Region({
            el: "#report-results-area"
        }),
    
        ReportView : ReportViewBase.extend({
            initialize : function() {
                this.template = _.template($('#report-template').html());
            }
        }),
        
        PublicationView : ReportViewBase.extend({
            initialize : function() {
                this.template = _.template($('#publication-template').html());
            }
        })
    };
        
}(Backbone));

