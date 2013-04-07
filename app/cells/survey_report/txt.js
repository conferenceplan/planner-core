jQuery(document).ready(function() {
    //Patch for template variables in _underscore top stop class with Rails variables in the file
    _.templateSettings = {
        interpolate : /\{\{\=(.+?)\}\}/g,
        evaluate : /\{\{(.+?)\}\}/g
    };


    //
    // Model for Query
    //
    SurveyName = Backbone.Model.extend({
        defaults : {
            name : 'name',
        },
    });

    Question = Backbone.Model.extend({
        defaults : {
            question : 'name',
        },
    }); 



    ResultRow = Backbone.Model.extend({
    });

    ResultSet = Backbone.Collection.extend({
        model : ResultRow,
        url : '/survey_reports/runReport'
    });

    SurveyNameCollection = Backbone.Collection.extend({
        model : SurveyName,
        url : '/survey_reports/surveyNames'
    });

    QuestionsCollection = Backbone.Collection.extend({
        model : Question,
        url : '/survey_reports/questions'
    });



    //
    //
    //
    SurveyQuery = Backbone.RelationalModel.extend({
        defaults : {
            name : '', // The name of the query
            operation : 'ALL' // can be ALL or ANY
        },

        // Collection predicates
        relations : [{
            type : Backbone.HasMany,
            key : 'queryPredicates',
            relatedModel : 'QueryPredicate',
            //includeInJSON: Backbone.Model.prototype.idAttribute,
            collectionType : 'PredicateCollection', // ?????
            reverseRelation : {
                key : 'surveyQuery',
            }
        }],

        // urlRoot: '/survey_query', // URL for the save or update of a survey query i.e URL for the controller using REST based semantics
    });


    //
    // The predicate for the query
    //
    QueryPredicate = Backbone.RelationalModel.extend({
        defaults : {
            question_id : '', // The id of the question from the database
            operation : '=', // The operation: =, <>, contains
            value : '' // The value that we are searching for
        }
    });

    PredicateCollection = Backbone.Collection.extend();
    // TODO - add URL method to create a URL for the whole collection

    
//
//
//


    ResultsView = Backbone.View.extend({
        el : '#query-results',

        tagName : 'div',

        template : _.template($('#query-results-template').html()),

        render : function() {
            this.$el.html(this.template());

            // surveyNameCollection
            $('.result-table').jqGrid({
                datatype: "local",
                data: [],
                colNames:['One','Two', 'Three'],
                colModel :[ 
                    {name:'One', index:'One', width:55}, 
                    {name:'Two', index:'Two', width:90}, 
                    {name:'Three', index:'Three', width:80, align:'right'}, 
                ],
              // viewrecords: true,
            });

            return this;
        },

        initialize : function() {
        },
    });





    //
    PredicateView = Backbone.View.extend({
        tagName : 'li',

        template : _.template($('#predicate-template').html()),

        events : {
            'click .questionID' : 'selectQuestion',
            'click .operator' : 'selectOperator',
            'blur .query-text' : 'selectText',
            'click .remove-button' : 'removeQuestion',
        },

        selectQuestion : function(ev) {
            this.model.set("question_id", $(ev.currentTarget).val());
        },

        selectOperator : function(ev) {
            this.model.set("operation", $(ev.currentTarget).val());
        },

        selectText : function(ev) {
            this.model.set("value", $(ev.currentTarget).val());
        },

        removeQuestion : function(ev) {
            this.$el.html("");
            this.model.destroy();
            // remove from the model - now we need to update the view
        },

        initialize : function() {
        },

        render : function() {
            this.$el.html(this.template(_.extend({
                col : questionsCollection
            }, this.model.toJSON())));
            return this;
        },
    }); 

  
  
  

    QueryView = Backbone.View.extend({
        el : '#queryapp',

        selected : 0,

        template : _.template($('#query-template').html()),

        render : function() {
            this.$el.html(this.template());
            // {col : questionsCollection, selected : this.selected}
            return this;
        },

        initialize : function() {
            this.model.on('remove:queryPredicates', this.elementRemoved, this)
        },

        elementRemoved : function(removed, related) {
            this.$('#query-list li:empty').remove();
        },

        events : {
            "click .add-button" : "addOne",
            "click .run-button" : "run"
        },

        run : function() {
            // alert(JSON.stringify(this.model.toJSON()));

            resultSet = new ResultSet();
            resultSet.fetch({
                type : 'POST',
                data : 'query=' + JSON.stringify(this.model.toJSON()),
                success : function(model) {
                    if (this.resultView) {
                        this.resultView.surveyNameCollection = model;
                        this.resultView.render();
                    } else {
                        this.resultView = new ResultsView({
                            resultsCollection : model
                        });
                        this.resultView.render();
                    }
                }
            })
        },

        addOne : function() {
            // create a new predicate add it to the collection and put it in the view
            var qp = new QueryPredicate();
            //alert(JSON.stringify(qp.toJSON()));
            qp.set({
                'surveyQuery' : this.model
            });

            var view = new PredicateView({
                model : qp,
                col : questionsCollection
            });
            $('#query-list').append(view.render().el);
        },
    }); 




    NewQueryView = Backbone.View.extend({
        tagName : 'div',
        className : 'new-query-dialog',
        id : 'new-query-dialog',

        selected : 0,

        template : _.template($('#new-query-template').html()),

        render : function() {
            var obj = this.$el.html(this.template({
                col : surveyNameCollection,
                selected : this.selected
            }));
            this.dialog = obj.dialog({
                title : 'Create Query',
                modal : true,
                // width: 600,
            });
        },

        events : {
            'click #surveyID' : 'setSelected',
            'click #save-button' : 'save',
            'click #close-button' : 'close',
        },

        createQuery : function() {
            alert("selected = " + this.selected);
        },

        setSelected : function(ev) {
            // get the questions for the given survey
            this.selected = $(ev.currentTarget).val();
        },

        save : function(ev) {
            // alert(this.selected);
            this.dialog.dialog('close');

            // instantiate the list of questions
            questionsCollection = new QuestionsCollection();
            questionsCollection.url = "/survey_reports/questions?survey=" + this.selected;
            questionsCollection.fetch({
                success : function(model) {
                    // and pass that to the next view
                    CurrentQuery = new SurveyQuery;
                    if (this.qv) {
                        //this.qv.remove;
                        this.qv.questionsCollection = model;
                        this.qv.model = CurrentQuery;
                    } else {
                        this.qv = new QueryView({
                            questionsCollection : model,
                            model : CurrentQuery
                        });
                    }

                    this.qv.render();

                    //return this.qv;
                }
            });
        },

        close : function(ev) {
            this.dialog.dialog('close');
        },

        initialize : function() {
            this.render();
        },
    });

  


    AppView = Backbone.View.extend({
        el : '#query-ctl',

        template : _.template($('#query-ctl-template').html()),

        render : function() {
            this.$el.html(this.template);
            return this;
        },

        events : {
            "click .new-query" : "newQuery"
        },

        newQuery : function() {
            surveyNameCollection = new SurveyNameCollection();
            surveyNameCollection.fetch({
                success : function(model) {
                    if (this.nq) {
                        this.nq.surveyNameCollection = model;
                        this.nq.render();
                    } else {
                        this.nq = new NewQueryView({
                            surveyNameCollection : model
                        });
                    }
                }
            });
        },

        initialize : function() {
            this.render();
        },
    });

    //
    // Routes
    //
    AppRouter = Backbone.Router.extend({
        routes : {
        },
    });

  
    var CurrentQuery = new SurveyQuery;

    //
    //
    //
    var app = new AppView();

    var app_router = new AppRouter();

    Backbone.history.start();
}); 